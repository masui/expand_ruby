# -*- coding: utf-8 -*-

class ExpandRubyTest < Minitest::Test
  def setup
  end
    
  def teardown
  end
    
  def test_1
    s = ExpandRuby::Scanner.new('a*d')
    assert_equal s.gettoken, 'a'
    assert_equal s.gettoken, '*'
    assert_equal s.gettoken, 'd'
    end
  
  def test_2
    s = ExpandRuby::Scanner.new('a+d')
    assert_equal s.gettoken, 'a'
    assert_equal s.gettoken, '+'
    assert_equal s.gettoken, 'd'
  end
    
  def test_3
    s = ExpandRuby::Scanner.new('ab*cd')
    assert_equal s.gettoken, 'ab'
    assert_equal s.gettoken, '*'
    assert_equal s.gettoken, 'cd'
  end
    
  def test_4
    s = ExpandRuby::Scanner.new("(a\tb|c\td)")
    assert_equal s.gettoken, "("
    assert_equal s.gettoken, "a\tb"
    assert_equal s.gettoken, '|'
    assert_equal s.gettoken, "c\td"
    assert_equal s.gettoken, ')'
  end
end

