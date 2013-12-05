#!/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require File.join(File.dirname(__FILE__), 'bundle/bundler/setup')

require 'boom'

command = ARGV.shift

if command == 'filter'
  require './lib/boom/list'
  require './lib/boom/item'
  require './lib/boom/storage/base'

  require 'alfred'
  require './lib/alfred/feedback/item'
  require './lib/alfred/feedback/file_item'

  require './lib/boom/alfred'
  require './lib/boom/alfred/filter'
else
  require './lib/boom/alfred/action'
end

Boom::Alfred.const_get(command.capitalize).execute(*ARGV)
