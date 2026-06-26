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
    :licenses => ['GPL-2.0-only', 'Ruby'],
    :permutation => '~> 0.1',
    :rake => nil,
    :required => ['lib/json.rb', 'tests/fixtures/fail29.json', 'tests/fixtures/fail30.json', 'ext/json/ext/parser/parser.c']
  },
  {
    :gemspec => 'json_pure.gemspec',
    :output => 'json-pure.gem',
    :name => 'json_pure',
    :platform => 'ruby',
    :licenses => ['GPL-2.0-only', 'Ruby'],
    :permutation => '~> 0.1',
    :rake => '~> 13.4.2',
    :required => ['lib/json.rb', 'lib/json/pure/parser.rb', 'tests/fixtures/fail29.json', 'tests/fixtures/fail30.json']
  },
  {
    :gemspec => 'json-java.gemspec',
    :output => 'json-java.gem',
    :name => 'json',
    :platform => 'java',
    :licenses => ['GPL-2.0-only', 'Ruby'],
    :permutation => nil,
    :rake => nil,
    :required => ['lib/json.rb', 'lib/json/ext.rb', 'tests/fixtures/fail29.json', 'tests/fixtures/fail30.json', 'COPYING-json-jruby', 'GPL']
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

def validate_generator_source
  source = ROOT.join('Rakefile').read
  licenses = "s.licenses = ['Ruby', 'GPL-2.0-only']"
  permutation = "s.add_development_dependency 'permutation', '~> 0.1'"
  rake = "s.add_development_dependency 'rake', '~> 13.4.2'"
  abort 'Rakefile gemspec generators must preserve dual-license metadata' unless source.scan(licenses).length == 2
  abort 'Rakefile gemspec generators must preserve bounded permutation metadata' unless source.scan(permutation).length == 2
  abort 'Rakefile pure gem generator must preserve patched bounded rake metadata' unless source.scan(rake).length == 1
end

repository_gems_before = Dir[ROOT.join('*.gem').to_s].sort
validate_generator_source

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
    build_output = stdout + stderr
    ['licenses is empty', 'open-ended dependency on permutation'].each do |warning|
      abort "#{expected[:gemspec]} build emitted remediated warning #{warning.inspect}" if build_output.include?(warning)
    end
    abort "#{expected[:gemspec]} did not create #{output}" unless File.file?(output)

    package = Gem::Package.new(output)
    specification = package.spec
    abort "#{expected[:gemspec]} built unexpected name #{specification.name}" unless specification.name == expected[:name]
    abort "#{expected[:gemspec]} built unexpected version #{specification.version}" unless specification.version.to_s == VERSION
    abort "#{expected[:gemspec]} built unexpected platform #{specification.platform}" unless specification.platform.to_s == expected[:platform]
    abort "#{expected[:gemspec]} built unexpected licenses #{specification.licenses.inspect}" unless specification.licenses.sort == expected[:licenses]

    permutation = specification.dependencies.find { |dependency| dependency.name == 'permutation' }
    if expected[:permutation]
      unless permutation && permutation.type == :development && permutation.requirement.to_s == expected[:permutation]
        abort "#{expected[:gemspec]} must retain bounded development dependency permutation #{expected[:permutation]}"
      end
    elsif permutation
      abort "#{expected[:gemspec]} must not add a permutation dependency"
    end

    rake = specification.dependencies.find { |dependency| dependency.name == 'rake' }
    if expected[:rake]
      unless rake && rake.type == :development && rake.requirement.to_s == expected[:rake]
        abort "#{expected[:gemspec]} must retain patched bounded development dependency rake #{expected[:rake]}"
      end
    elsif rake
      abort "#{expected[:gemspec]} must not add a rake dependency"
    end

    validate_contents(expected[:gemspec], package.contents, expected[:required])
  end
end

repository_gems_after = Dir[ROOT.join('*.gem').to_s].sort
abort 'gem build validation must not leave repository artifacts' unless repository_gems_after == repository_gems_before

puts "Gem package build tests passed (#{PACKAGES.length} packages)."
