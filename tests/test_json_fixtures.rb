#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'test/unit'
require File.join(File.dirname(__FILE__), 'setup_variant')

class TestJSONFixtures < Test::Unit::TestCase
  def passing_fixture?(filename)
    File.basename(filename) =~ /\Apass/
  end

  def setup
    fixtures = File.join(File.dirname(__FILE__), 'fixtures/*.json')
    passed, failed = Dir[fixtures].partition { |f| passing_fixture?(f) }
    @passed = passed.inject([]) { |a, f| a << [ f, File.read(f) ] }.sort
    @failed = failed.inject([]) { |a, f| a << [ f, File.read(f) ] }.sort
  end

  def test_fixture_classification_ignores_parent_directories
    assert passing_fixture?('/tmp/archive/fixtures/pass1.json')
    assert !passing_fixture?('/tmp/second-pass/fixtures/fail1.json')
  end

  def test_invalid_utf8_after_escape_fixture
    fixture = File.join(File.dirname(__FILE__), 'fixtures/fail30.json')
    source = File.open(fixture, 'rb') { |file| file.read }
    assert_equal [0x5b, 0x22, 0x5c, 0xe5, 0x22, 0x5d], source.bytes.to_a
    assert_raises(JSON::ParserError) { JSON.parse(source) }
  end

  def test_passing
    for name, source in @passed
      begin
        assert JSON.parse(source),
          "Did not pass for fixture '#{name}': #{source.inspect}"
      rescue => e
        warn "\nCaught #{e.class}(#{e}) for fixture '#{name}': #{source.inspect}\n#{e.backtrace * "\n"}"
        raise e
      end
    end
  end

  def test_failing
    for name, source in @failed
      assert_raises(JSON::ParserError, JSON::NestingError,
        "Did not fail for fixture '#{name}': #{source.inspect}") do
        JSON.parse(source)
      end
    end
  end
end
