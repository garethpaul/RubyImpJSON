#!/usr/bin/env ruby
# frozen_string_literal: true

failures = []

docs_plans = Dir['docs/plans/*.md'].sort
canonical_plan = 'docs/plans/2026-06-08-rubyimpjson-baseline.md'
failures << "#{canonical_plan} is missing" unless File.exist?(canonical_plan)
failures << 'docs/plans must contain at least one completed plan' if docs_plans.empty?

docs_plans.each do |plan_path|
  plan = File.read(plan_path)
  unless plan.include?('Status: Completed') && plan.include?('make check')
    failures << "#{plan_path} must record completed status and make check verification"
  end
end

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
failures << 'README.md must link ARCHIVE_STATUS.md' unless readme.include?('ARCHIVE_STATUS.md')

if File.exist?('ARCHIVE_STATUS.md')
  archive_status = File.read('ARCHIVE_STATUS.md')
  failures << 'ARCHIVE_STATUS.md must declare historical snapshot status' unless archive_status.include?('historical snapshot')
  failures << "ARCHIVE_STATUS.md must document version #{version}" unless archive_status.include?("Version: #{version}")
  failures << 'ARCHIVE_STATUS.md must document JSON=pure verification' unless archive_status.include?('JSON=pure')
  failures << 'ARCHIVE_STATUS.md must preserve security-relevant parser fixtures' unless archive_status.include?('security-relevant parser fixtures')
else
  failures << 'ARCHIVE_STATUS.md is missing'
end

if failures.empty?
  puts 'Archive metadata checks passed'
else
  warn "Archive metadata checks failed:\n- #{failures.join("\n- ")}"
  exit 1
end
