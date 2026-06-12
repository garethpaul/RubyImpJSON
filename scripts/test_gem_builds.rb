#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'
require 'pathname'
require 'rbconfig'
require 'rubygems/package'
require 'tmpdir'

ROOT = Pathname.new(__dir__).parent.expand_path
VERSION = ROOT.join('VERSION').read.strip
PACKAGES = [
  {
    :gemspec => 'json.gemspec',
    :output => 'json-native.gem',
    :name => 'json',
    :platform => 'ruby',
    :required => ['lib/json.rb', 'tests/fixtures/fail29.json', 'ext/json/ext/parser/parser.c']
  },
  {
    :gemspec => 'json_pure.gemspec',
    :output => 'json-pure.gem',
    :name => 'json_pure',
    :platform => 'ruby',
    :required => ['lib/json.rb', 'lib/json/pure/parser.rb', 'tests/fixtures/fail29.json']
  },
  {
    :gemspec => 'json-java.gemspec',
    :output => 'json-java.gem',
    :name => 'json',
    :platform => 'java',
    :required => ['lib/json.rb', 'lib/json/ext.rb', 'tests/fixtures/fail29.json']
  }
].freeze

def validate_contents(gemspec, contents, required)
  abort "#{gemspec} package must not be empty" if contents.empty?
  abort "#{gemspec} package must not duplicate archive entries" unless contents.uniq == contents

  contents.each do |entry|
    path = Pathname.new(entry)
    components = path.each_filename.to_a
    unsafe = entry.empty? || entry.include?('\\') || path.absolute? ||
             components.include?('.') || components.include?('..') ||
             path.cleanpath.to_s != entry
    if unsafe
      abort "#{gemspec} package contains unsafe archive entry #{entry.inspect}"
    end
  end

  missing = required - contents
  abort "#{gemspec} package is missing #{missing.join(', ')}" unless missing.empty?
end

def validate_gemspec_source(gemspec)
  source = ROOT.join(gemspec).read
  if source.match?(/["']\.\//)
    abort "#{gemspec} must use canonical manifest paths without ./ aliases"
  end
end

repository_gems_before = Dir[ROOT.join('*.gem').to_s].sort

Dir.mktmpdir('rubyimpjson-gems') do |directory|
  PACKAGES.each do |expected|
    validate_gemspec_source(expected[:gemspec])
    output = File.join(directory, expected[:output])
    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      '-S',
      'gem',
      'build',
      expected[:gemspec],
      '--output',
      output,
      :chdir => ROOT.to_s
    )
    abort "#{expected[:gemspec]} build failed:\n#{stdout}#{stderr}" unless status.success?
    abort "#{expected[:gemspec]} did not create #{output}" unless File.file?(output)

    package = Gem::Package.new(output)
    specification = package.spec
    abort "#{expected[:gemspec]} built unexpected name #{specification.name}" unless specification.name == expected[:name]
    abort "#{expected[:gemspec]} built unexpected version #{specification.version}" unless specification.version.to_s == VERSION
    abort "#{expected[:gemspec]} built unexpected platform #{specification.platform}" unless specification.platform.to_s == expected[:platform]

    validate_contents(expected[:gemspec], package.contents, expected[:required])
  end
end

repository_gems_after = Dir[ROOT.join('*.gem').to_s].sort
abort 'gem build validation must not leave repository artifacts' unless repository_gems_after == repository_gems_before

puts "Gem package build tests passed (#{PACKAGES.length} packages)."
