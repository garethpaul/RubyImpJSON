#!/usr/bin/env jruby
require "rubygems"

spec = Gem::Specification.new do |s|
  s.name = "json"
  s.version = File.read("VERSION").chomp
  s.summary = "JSON implementation for JRuby"
  s.description = "A JSON implementation as a JRuby extension."
  s.author = "Daniel Luz"
  s.email = "dev+ruby@mernen.com"
  s.homepage = "http://json-jruby.rubyforge.org/"
  s.licenses = ["Ruby", "GPL-2.0-only"]
  s.platform = 'java'
  s.rubyforge_project = "json-jruby"

  s.files = Dir["{docs,lib,tests}/**/*"] + ["COPYING-json-jruby", "GPL"]
end

if $0 == __FILE__
  Gem::Builder.new(spec).build
else
  spec
end
