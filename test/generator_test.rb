# -*- coding: utf-8 -*-
#
# Ruby2.0用に書き換え 2016/04/24 11:54:27
#

class ExpandRubyTest < Minitest::Test
  def setup
  end
    
  def teardown
  end
    
  def test_clock
    g = ExpandRuby::Generator.new
    g.add '(時計|時間|時刻)を(0|1|2|3|4|5|6|7|8|9|10|11|12)時に(セットする|設定する|あわせる)', 'set time #{$2}:00'
    res = g.generate(' 10 ')
    assert res[0].member?(['時刻を10時に設定する','set time 10:00'])
    assert res[0].member?(['時計を10時にセットする','set time 10:00'])
    assert !res[0].member?(['時計を8時にセットする','set time 8:00'])
  end
    
  def test_substring
    g = ExpandRuby::Generator.new
    g.add '(a)bcd(e(fg)h)i(jk)', '#{$1}/#{$2}/#{$3}/#{$4}'
    res = g.generate(' b ')
    assert res[0].member?(['abcdefghijk', 'a/efgh/fg/jk'])
    assert !res[0].member?(['abcdefghijk', 'a/fgh/fg/jk'])
    g.add '(ab|cd)efg(hij|klm)n', '#{$1}/#{$2}'
    res = g.generate(' ef ')
    assert res[0].member?(['abefghijn', 'ab/hij'])
    assert res[0].member?(['cdefgklmn', 'cd/klm'])
  end

  def test_substitute
    g = ExpandRuby::Generator.new
    g.add "(a\taaa|b\tbbb)(c|d)", '#{$1}/#{$2}'
    res = g.generate(' a ')
    assert res[0].member?(['ac', 'aaa/c'])
    assert res[0].member?(['ad', 'aaa/d'])
    assert !res[0].member?(['bc', 'bbb/c'])
    assert !res[0].member?(['bd', 'bbb/d'])
  end
end
