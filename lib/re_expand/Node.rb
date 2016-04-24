# -*- coding: utf-8 -*-
#
# Node.rb
#
#  ノードとノード間遷移
#
#  (self)  pat     dest
#    ■ ----------> □
#       ----------> □
#       ----------> □
#

module ExpandRuby
  class Trans
    def initialize(pat,dest)
      # pat にマッチしたら dest に遷移
      @pat = pat
      @dest = dest
    end
    
    attr_reader :pat, :dest
    
    def str
      @pat.split(/\t/)[0].to_s
    end
    
    def arg
      if @pat =~ /^(.*)\t(.*)$/ then
        return $2
      else
        return @pat
      end
    end
  end
  
  class Node
    @@id = 1
    @@nodes = {}
    
    def initialize
      @accept = nil
      @trans = []
      @id = @@id
      @@nodes[@id] = self
      @@id += 1
      @pars = []
    end
    
    attr_reader :id
    attr_reader :trans
    attr_accessor :accept,:pars
    
    def addTrans(pat,dest)
      t = Trans.new(pat,dest)
      @trans << t
    end
    
    def Node.node(id) # ノードidからノードを取得
      @@nodes[id.to_i]
    end
    
    def Node.nodes
      @@nodes.values
    end
  end
end
