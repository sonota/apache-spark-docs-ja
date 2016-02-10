# -*- coding: utf-8 -*-
require 'strscan'

BUILD_DIR = "build"


class Node
  attr_accessor :en, :ja
end

class ParagraphNode < Node
  attr_accessor :col

  def initialize(src, col)
    if /<!-- en -->(.+)<!-- \/en --><!-- ja -->(.+)<!-- \/ja -->/m =~ src
      @en, @ja = $1, $2
      @col = col
    else
      raise "invalid src (#{src})"
    end
  end

  def to_s_both
    if indented?
      indent = " " * @col
      [ '<span lang="en">',
        indent + @en.strip,
        indent + '</span><br /><span lang="ja">',
        indent + @ja.strip,
        indent + "</span>"
      ].join("\n")
    else
      [ '<span lang="en">',
        @en.strip,
        '<br /></span><span lang="ja">',
        @ja.strip.gsub("\n", ""),
        "</span>"
      ].join("\n")
    end
  end

  def indented?
    @col > 0
  end
end

class HeadingNode < Node
  attr_accessor :lv

  def initialize(src)
    if /(#+)(.+) \/\/ (.+)$/ =~ src
      @lv = $1.size
      @en, @ja = $2.strip, $3.strip
    else
      raise "invalid src (#{src})"
    end
  end

  def to_s_both
    ("#" * @lv) + " #{@ja} <span lang='en'>(#{@en})</span>"
  end
end


def byteslice(str, pos_from, pos_to)
  str.byteslice(pos_from, pos_to - pos_from)
end

def parse(src)
  nodes = []
  ss = StringScanner.new(src)
  pos_from = ss.pos
  pos_prev = ss.pos
  pos_last_bol = ss.pos

  while not ss.eos?
    # マッチを行う前に開始位置を保存
    pos_prev = ss.pos

    case
    when ss.bol?
      pos_last_bol = ss.pos
      case
      when ss.scan( /(\#+)(.+) \/\/ (.+)$/ )
        nodes << byteslice(ss.string, pos_from, pos_prev)
        nodes << HeadingNode.new(ss.matched.strip)
        pos_from = ss.pos
      when ss.scan( /<!-- en -->.+?<!-- \/ja -->/m )
        nodes << byteslice(ss.string, pos_from, pos_prev)
        nodes << ParagraphNode.new(ss.matched, 0)
        pos_from = ss.pos
      else
        ss.pos += 1
      end
    when ss.scan( /<!-- en -->.+?<!-- \/ja -->/m )
      nodes << byteslice(ss.string, pos_from, pos_prev)
      col = pos_prev - pos_last_bol
      nodes << ParagraphNode.new(ss.matched, col)
      pos_from = ss.pos
    else
      ss.pos += 1
    end
  end
  nodes << byteslice(ss.string, pos_from, ss.string.bytesize)

  nodes.reject{|node| node.is_a?(String) && node.empty? }
end

def convert(nodes)
  out = ""
  nodes.each do |node|
    case node
    when String
      out << node
    else
      out << node.to_s_both
    end
  end
  out
end

Dir.glob("docs_ja/*") do |path|
  next if /~$/ =~ path
  src = File.read(path)

  open(File.join(BUILD_DIR, File.basename(path)), "w") do |f|
    nodes = parse(src)
    f.print convert(nodes)
  end
end
