# -*- coding: utf-8 -*-
require 'test/unit'
require './convert'

LF = "\n"


class TestConvert < Test::Unit::TestCase

  def get_indent(line)
    /^( *)/ =~ line
    $1.size
  end

  def strip_margin(text)
    ends_with_nl = (/\n\Z/ =~ text)
    lines = text.chomp.split(LF)

    min0 = get_indent(lines[0])
    min = lines.inject(min0) do |_min, line|
      [_min, get_indent(line)].min
    end

    stripped_lines = lines.map do |line|
      line[min .. -1]
    end

    stripped_lines.join(LF) + (ends_with_nl ? LF : "")
  end

  def parse_and_convert(src)
    nodes = parse(src)
    convert(nodes)
  end


  sub_test_case "段落" do

    test "前後あり" do
      expected = strip_margin(<<-EOB)
        a
        <span lang="en">
        en
        <br /></span><span lang="ja">
        日
        </span>
        b
      EOB

      src = strip_margin(<<-EOB)
        a
        <!-- en -->
        en
        <!-- /en --><!-- ja -->
        日
        <!-- /ja -->
        b
      EOB

      assert_equal(expected, parse_and_convert(src))
    end

    test "前後なし" do
      expected = strip_margin(<<-EOB)
        <span lang="en">
        en
        <br /></span><span lang="ja">
        日
        </span>
      EOB

      src = strip_margin(<<-EOB)
        <!-- en -->
        en
        <!-- /en --><!-- ja -->
        日
        <!-- /ja -->
      EOB

      assert_equal(expected, parse_and_convert(src))
    end

    test "インデントあり" do
      expected = strip_margin(<<-EOB)
        - <span lang="en">
          en
          </span><br /><span lang="ja">
          日
          </span>
        - a
      EOB

      src = strip_margin(<<-EOB)
        - <!-- en -->
          en
          <!-- /en --><!-- ja -->
          日
          <!-- /ja -->
        - a
      EOB

      assert_equal(expected, parse_and_convert(src))
    end

  end


  sub_test_case "見出し" do

    test "見出し 前後あり" do
      expected = strip_margin(<<-EOB)
        a
        # 日 <span lang='en'>(en)</span>
        b
      EOB

      src = strip_margin(<<-EOB)
        a
        # en // 日
        b
      EOB

      assert_equal(expected, parse_and_convert(src))
    end

    test "見出し 前後なし" do
      expected = strip_margin(<<-EOB)
        # 日 <span lang='en'>(en)</span>
      EOB

      src = strip_margin(<<-EOB)
        # en // 日
      EOB

      assert_equal(expected, parse_and_convert(src))
    end

    test "見出し level2" do
      expected = strip_margin(<<-EOB)
        ## 日 <span lang='en'>(en)</span>
      EOB

      src = strip_margin(<<-EOB)
        ## en // 日
      EOB

      assert_equal(expected, parse_and_convert(src))
    end

  end


  sub_test_case "複合" do

    test "段落 → 見出し" do
      expected = strip_margin(<<-EOB)
        <span lang=\"en\">
        en
        <br /></span><span lang=\"ja\">
        日
        </span>
        # 日 <span lang='en'>(en)</span>
      EOB

      src = strip_margin(<<-EOB)
        <!-- en -->
        en
        <!-- /en --><!-- ja -->
        日
        <!-- /ja -->
        # en // 日
      EOB

      assert_equal(expected, parse_and_convert(src))
    end

    test "見出し → 段落" do
      expected = strip_margin(<<-EOB)
        # 日 <span lang='en'>(en)</span>
        <span lang=\"en\">
        en
        <br /></span><span lang=\"ja\">
        日
        </span>
      EOB

      src = strip_margin(<<-EOB)
        # en // 日
        <!-- en -->
        en
        <!-- /en --><!-- ja -->
        日
        <!-- /ja -->
      EOB

      assert_equal(expected, parse_and_convert(src))
    end

  end

end
