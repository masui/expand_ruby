# -*- coding: utf-8 -*-
#
# Scanner.rb
#
# 文字列から1トークンずつ取得
#
$KCODE = 'utf8' if RUBY_VERSION < "1.9"

module ExpandRuby
  class Scanner
    def initialize(s)
      @s = s
      @a = s.split(//)
      @p = 0
      @t = ''
      @u = ''
    end
    
    def gettoken
      if @u != '' then
        @t = @u
        @u = ''
        return @t
      end
      if @p >= @a.length then
        @t = ''
        return ''
      end
      @t = @a[@p]
      if @t =~ /^[\(\|\)\*\+\?\[\]]$/ then
        @p += 1
        return @t
      elsif @t == '\\' then
        @p += 1
        @t = @a[@p]
        @t = "\n" if @t == 'n'
        @t = "\t" if @t == 't'
        @p += 1
        return @t
      else
        @p += 1
        while @p < @a.length && @a[@p] !~ /^[\(\|\)\*\+\?\[\]\\]$/ do
          @t += @a[@p]
          @p += 1
        end
        return @t
      end
    end
    
    def ungettoken
      if @u == '' then
        @u = @t
      else
        puts "Can't ungettoken(#{token})"
      end
    end
    
    def nexttoken
      return @t
    end
  end
end
