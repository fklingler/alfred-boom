#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require 'bundle/bundler/setup'
require 'alfred'

require 'boom'

Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each {|file| require file }

Boom::Alfred.execute(*ARGV)
