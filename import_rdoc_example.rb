#!/usr/bin/env ruby

require 'open3'

def bitclust_path
  File.expand_path('~/.bitclust/rubydoc')
end

def builtin_path
  File.join(bitclust_path, 'refm', 'api', 'src', '_builtin')
end

def builtin_class_path(klass)
  File.join(builtin_path, klass.gsub('::', '__'))
end

def add_example_for(sig)
  klass, method = sig.split('#')
  path = builtin_class_path(klass)
  lines = File.readlines(path)
  method_index = lines.index do |l|
    l.start_with?("--- #{method}") && (l.start_with?("--- #{method}(") || l.start_with?("--- #{method} "))
  end

  unless method_index
    puts "Entry not found: " + sig
    return
  end

  n_line = lines.drop(method_index).drop_while { |l| l.start_with?('--- ') }.take_while { |l| !l.start_with?('---') }.size

  o, _s = Open3.capture2('ri', '--no-pager', '--no-site', '--no-gems', '--no-home', sig)
  desc = o.split(/^-+\n/).last
  examples = desc.each_line.chunk { |l| l.start_with?(' ') }.map {|(k, v)| "例:\n" + v.join if k }.compact
  lines[method_index + n_line, 0] = examples.join
  File.write(path, lines.join)
end

# prepare rdoc.txt by find_rdoc_examples
File.foreach('rdoc.txt') do |sig|
  add_example_for(sig.chomp)
end
