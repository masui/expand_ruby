# coding: utf-8
require "re_expand/version"

module ExpandRuby
  # Your code goes here...
end

require 're_expand/Generator'
require 're_expand/Node'
require 're_expand/Scanner'
 
class String
  #
  # restr.expand { |a| ... }
  # restr.expand(' abc '){ |a| ... }    パタンを指定
  # restr.expand(' abc ',1){ |a| ... }  許容曖昧度を指定
  #
  def expand(filterpat=' ',ambig=0,&block)
    g = ExpandRuby::Generator.new
    g.add(self,'')
    strings = []

    if block_given? then
      g.generate(filterpat,ambig,&block)
    else
      m = g.generate(filterpat)
      matched = m[0].length > 0 ? m[0] : m[1].length > 0 ? m[1] : m[2]
      strings = matched.collect { |r|
        r[0]
      }
    end
  end
end
