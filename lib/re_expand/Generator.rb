# -*- coding: utf-8 -*-
#
# Generator.rb
#
# Created by Toshiyuki Masui on 2011/02/26.
# Modified by Toshiyuki Masui on 2012/05/??
# Modified by Toshiyuki Masui on 2016/04/24
# Copyright 2011-2016 Pitecan Systems. All rights reserved.
#
#          ( (  )  )  ( (    ) (  (  )  ) (   )  )  | (  (  )  )
#  pars   [1]     
#           [1,2]
#                    [3]
#                     [3,4]
#                             [3,5]

require 're_expand/Scanner'
require 're_expand/Node'

require 'asearch' # これはGem

module ExpandRuby
  class GenNode
    def initialize(id, state=[], s="", substrings=[], accept=false)
      @id = id
      @s = s
      @substrings = substrings
      @accept = accept
      @state = state
    end
    attr_accessor :id,:s,:substrings,:accept,:state
  end
  
  class Generator
    def initialize(s = nil)
      @s = (s ? [s] : [])
      @matchedlist = []
      @par = 0
      @commands = []
    end
    
    def add(pat,command)
      @s << pat
      @commands << command
    end
    
    def delete
      @s.pop
      @commands.pop
    end
    
    #
    # ルールを解析して状態遷移機械を作成し、patにマッチするもののリストを返す
    #
    def generate(pat, blockambig=0)
      res = [[],[],[]] # 曖昧度0,1,2のマッチ結果
      patterns = pat.split.map { |p| p.downcase }
      
      @asearch = Asearch.new(pat)
      scanner = Scanner.new(@s.join('|'))
      
      # HelpDataで指定した状態遷移機械全体を生成
      # (少し時間がかかる)
      (startnode, endnode) = regexp(scanner,true) # top level
      
      #
      # 状態遷移機械からDepth-Firstで文字列を生成する
      # n個のノードを経由して生成される状態の集合をlists[n]に入れる
      # 生成しながらマッチングも計算する
      #
      lists = []
      listed = [{},{},{}]
      block_listed = {}
      #
      # 初期状態
      #
      list = []
      list[0] = GenNode.new(startnode.id, @asearch.initstate)
      lists[0] = list
      #
      loopcount = 0
      (0..1000).each { |length|
      #loop do 
      #  length = loopcount
        list = lists[length]
        newlist = []
        # puts "#{length} - #{list.length}"
        list.each { |entry|
          srcnode = Node.node(entry.id)
          if list.length * srcnode.trans.length < 10000 then
            srcnode.trans.each { |trans|
              ss = entry.substrings.dup
              srcnode.pars.each { |i|
                ss[i-1] = ss[i-1].to_s + trans.arg
              }
              newstate = @asearch.state(entry.state, trans.str) # 新しいマッチング状態を計算してノードに保存
              s = entry.s + trans.str
              acceptno = trans.dest.accept
              newlist << GenNode.new(trans.dest.id, newstate, s, ss, acceptno)
              #
              # この時点で、マッチしているかどうかをstateとacceptpatで判断できる
              # マッチしてたら出力リストに加える
              #
              if acceptno then
                if block_given? then
                  (0..blockambig).each { |ambig|
                    if !block_listed[s] then
                      if (newstate[ambig] & @asearch.acceptpat) != 0 then # マッチ
                        block_listed[s] = true
                        yield [s] + ss
                      end
                    end
                  }
                else
                  maxambig = 2
                  (0..maxambig).each { |ambig|
                    if !listed[ambig][s] then
                      if (newstate[ambig] & @asearch.acceptpat) != 0 then # マッチ
                        maxambig = ambig if ambig < maxambig # 曖昧度0でマッチすれば曖昧度1の検索は不要
                        listed[ambig][s] = true
                        sslen = ss.length
                        if sslen > 0 then
                          # patstr = "(.*)\t" * (sslen-1) + "(.*)"
                          patstr = (["(.*)"] * sslen).join("\t")
                          /#{patstr}/ =~ ss.join("\t")
                        end
                        # 'set date #{$2}' のような記述の$変数にsubstringの値を代入
                        res[ambig] << [s, eval('%('+@commands[acceptno]+')')]
                      end
                    end
                  }
                end
              end
            }
          end
        }
        break if newlist.length == 0
        lists << newlist
        break if res[0].length > 100
      # loopcount += 1
      #end
      }
      [res[0], res[1], res[2]]
    end
    
    #
    # 正規表現をパースして状態遷移機械を作る
    #
    private
    #            n1     n2
    #        +-->□.....□--+
    # start /                \  end
    #     □ --->□.....□---> □
    #       \                /
    #        +-->□.....□--+
    #
    def regexp(s,toplevel=false) # regcat { '|' regcat }
      startnode = Node.new
      endnode = Node.new
      if toplevel then
        @pars = []
        @parno = 0
        @ruleid = 0
      end
      startnode.pars = @pars
      endnode.pars = @pars
      (n1, n2) = regcat(s)
      startnode.addTrans('',n1)
      if toplevel then
        n2.accept = @ruleid
      end
      n2.addTrans('',endnode)
      while s.gettoken == '|' && s.nexttoken != '' do
        if toplevel then
          @pars = []
          @parno = 0
          @ruleid += 1
        end
        (n1, n2) = regcat(s)
        startnode.addTrans('',n1)
        if toplevel then
          n2.accept = @ruleid
        end
        n2.addTrans('',endnode)
      end
      s.ungettoken
      return [startnode, endnode]
    end
    
    def regcat(s) # regfactor { regfactor }
      (startnode, endnode) = regfactor(s)
      while s.gettoken !~ /^[\)\]\|]$/ && s.nexttoken != '' do
        s.ungettoken
        (n1, n2) = regfactor(s)
        endnode.addTrans('',n1)
        endnode = n2
      end
      s.ungettoken
      return [startnode, endnode]
    end
    
    def regfactor(s) # regterm [ '?' | '+' | '*' ]
      (startnode, endnode) = regterm(s)
      t = s.gettoken
      if t =~ /^[\?]$/ then
        startnode.addTrans('',endnode)
      elsif t =~ /^[\+]$/ then
        endnode.addTrans('',startnode)
      elsif t =~ /^[\*]$/ then
        n = Node.new
        startnode.addTrans('',endnode)
        endnode.addTrans('',n)
        n.addTrans('',startnode)

        # ループがあるとマズいのか? 上のように修正すると動くようなのだが
        #startnode.addTrans('',endnode)
        #endnode.addTrans('',startnode)
      else
        s.ungettoken
      end
      return [startnode,endnode]
    end
    
    def regterm(s) # '(' regexp ')' | token
      t = s.gettoken
      if t == '(' then
        @parno += 1
        @pars.push(@parno)
        (n1, n2) = regexp(s)
        n1.pars = @pars.dup
        t = s.gettoken
        if t == ')' then
          @pars.pop
          n2.pars = @pars.dup
          return [n1, n2]
        else
          puts 'missing )'
          exit
        end
      else
        startnode = Node.new
        startnode.pars = @pars.dup
        endnode = Node.new
        endnode.pars = @pars.dup
        startnode.addTrans(t,endnode)
        return [startnode, endnode]
      end
    end
  end
  
end

