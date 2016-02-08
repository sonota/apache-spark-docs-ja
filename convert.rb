# -*- coding: utf-8 -*-

BUILD_DIR = "build"

def parse src
  # TODO
end

def convert nodes
  # TODO
end

Dir.glob("docs_ja/*") do |path|
  next if /~$/ =~ path
  src = File.read(path)

  open(File.join(BUILD_DIR, File.basename(path)), "w") do |f|
    nodes = parse(src)
    f.print convert(nodes)
  end
end
