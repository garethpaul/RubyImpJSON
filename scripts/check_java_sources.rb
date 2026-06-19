#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require 'fileutils'
require 'open3'
require 'rubygems'
require 'tmpdir'

ROOT = File.expand_path('..', __dir__)
JRUBY_JARS_VERSION = '1.7.27'
JRUBY_CORE_SHA256 = '0e68235b2d500020cbcbda807e60eb8d75ecd732e3e618726e84db78f02cc60d'
EXPECTED_SOURCES = %w[
  ByteListTranscoder.java
  Generator.java
  GeneratorMethods.java
  GeneratorService.java
  GeneratorState.java
  OptionsReader.java
  Parser.java
  ParserService.java
  RuntimeInfo.java
  StringDecoder.java
  StringEncoder.java
  Utils.java
].freeze

def fail_check(message)
  warn "Java source compile check failed: #{message}"
  exit 1
end

def jruby_core_jar
  override = ENV['JRUBY_CORE_JAR']
  return File.expand_path(override) unless override.nil? || override.empty?

  specification = Gem::Specification.find_by_name('jruby-jars', "= #{JRUBY_JARS_VERSION}")
  File.join(specification.full_gem_path, 'lib', "jruby-core-#{JRUBY_JARS_VERSION}.jar")
rescue Gem::MissingSpecError
  fail_check("install jruby-jars #{JRUBY_JARS_VERSION} or set JRUBY_CORE_JAR")
end

javac = ENV.fetch('JAVAC', 'javac')
jar = jruby_core_jar
fail_check("JRuby core jar is missing: #{jar}") unless File.file?(jar)

actual_sha256 = Digest::SHA256.file(jar).hexdigest
unless actual_sha256 == JRUBY_CORE_SHA256
  fail_check("JRuby core jar SHA-256 must be #{JRUBY_CORE_SHA256}, received #{actual_sha256}")
end

source_dir = File.join(ROOT, 'java', 'src', 'json', 'ext')
sources = Dir[File.join(source_dir, '*.java')].sort
actual_sources = sources.map { |path| File.basename(path) }
unless actual_sources == EXPECTED_SOURCES
  fail_check("expected Java sources #{EXPECTED_SOURCES.join(', ')}, received #{actual_sources.join(', ')}")
end

unless Dir[File.join(ROOT, 'java', 'src', '**', '*.class')].empty?
  fail_check('compiled class files must not exist in the checkout')
end

Dir.mktmpdir('rubyimpjson-java-check-') do |output_dir|
  command = [
    javac,
    '-source', '1.5',
    '-target', '1.5',
    '-classpath', [jar, File.join(ROOT, 'java', 'src')].join(File::PATH_SEPARATOR),
    '-d', output_dir,
    *sources
  ]
  begin
    stdout, stderr, status = Open3.capture3(*command)
  rescue Errno::ENOENT
    fail_check("compiler command not found: #{javac}")
  end
  $stdout.write(stdout)
  $stderr.write(stderr)
  fail_check("javac exited with status #{status.exitstatus}") unless status.success?

  missing_classes = EXPECTED_SOURCES.filter_map do |source|
    class_name = source.sub(/\.java\z/, '.class')
    class_name unless File.file?(File.join(output_dir, 'json', 'ext', class_name))
  end
  fail_check("primary class output is missing: #{missing_classes.join(', ')}") unless missing_classes.empty?

  class_count = Dir[File.join(output_dir, '**', '*.class')].length
  fail_check('javac produced no class files') if class_count.zero?
  puts "Compiled #{sources.length} Java sources into #{class_count} temporary class files with JRuby #{JRUBY_JARS_VERSION}."
end

unless Dir[File.join(ROOT, 'java', 'src', '**', '*.class')].empty?
  fail_check('compiler output escaped the temporary directory')
end
