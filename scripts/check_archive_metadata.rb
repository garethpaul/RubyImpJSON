#!/usr/bin/env ruby
# frozen_string_literal: true

failures = []

version = File.read('VERSION').strip
version_source = File.read('lib/json/version.rb')
unless version_source.include?("VERSION         = '#{version}'")
  failures << "lib/json/version.rb must match VERSION #{version}"
end

%w[json.gemspec json_pure.gemspec].each do |gemspec|
  source = File.read(gemspec)
  failures << "#{gemspec} must declare version #{version}" unless source.include?("s.version = \"#{version}\"")
end

java_gemspec = File.read('json-java.gemspec')
unless java_gemspec.include?('File.read("VERSION").chomp')
  failures << 'json-java.gemspec must derive its version from VERSION'
end

fixture_counts = {
  'passing fixture' => Dir['tests/fixtures/pass*.json'].length,
  'failing fixture' => Dir['tests/fixtures/fail*.json'].length
}
fixture_counts.each do |label, count|
  failures << "expected at least one #{label}" if count.zero?
end

rakefile = File.read('Rakefile')
failures << 'Rakefile must define do_test_pure' unless rakefile.include?("t.name = 'do_test_pure'")

readme = File.read('README.md')
failures << 'README.md must document make verify' unless readme.include?('make verify')
failures << 'README.md must document the JSON=pure test variant' unless readme.include?('JSON=pure')

if failures.empty?
  puts 'Archive metadata checks passed'
else
  warn "Archive metadata checks failed:\n- #{failures.join("\n- ")}"
  exit 1
end
