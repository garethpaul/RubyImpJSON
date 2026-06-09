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

fixture_paths = Dir['tests/fixtures/*.json'].sort
%w[json.gemspec json_pure.gemspec].each do |gemspec|
  source = File.read(gemspec)
  missing_fixtures = fixture_paths.reject { |fixture| source.include?("\"#{fixture}\"") }
  unless missing_fixtures.empty?
    failures << "#{gemspec} must include fixture files: #{missing_fixtures.join(', ')}"
  end
end

unterminated_comment_fixture = 'tests/fixtures/fail29.json'
if File.exist?(unterminated_comment_fixture)
  fixture = File.read(unterminated_comment_fixture)
  unless fixture.include?('Unterminated block comment') && fixture.include?('/* missing close')
    failures << "#{unterminated_comment_fixture} must document an unterminated block comment"
  end
else
  failures << "#{unterminated_comment_fixture} is missing"
end

rakefile = File.read('Rakefile')
failures << 'Rakefile must define do_test_pure' unless rakefile.include?("t.name = 'do_test_pure'")

server = File.read('tools/server.rb')
unless server.include?('def parse_port(value)') &&
       server.include?('Integer(value || 6666)') &&
       server.include?('port < 1 || port > 65535') &&
       server.include?('port = parse_port(ARGV.shift)') &&
       server.include?('s = create_server(STDERR, dir, port)')
  failures << 'tools/server.rb must validate and pass the parsed command-line port to create_server'
end

fuzzer = File.read('tools/fuzz.rb')
unless fuzzer.include?('r = rand') && fuzzer.include?('f.include? r')
  failures << 'tools/fuzz.rb must use the sampled random value when selecting frequency buckets'
end
if fuzzer.include?('f.include? rand')
  failures << 'tools/fuzz.rb must not resample random values while selecting a frequency bucket'
end

readme = File.read('README.md')
failures << 'README.md must document make verify' unless readme.include?('make verify')
failures << 'README.md must document the JSON=pure test variant' unless readme.include?('JSON=pure')
failures << 'README.md must link ARCHIVE_STATUS.md' unless readme.include?('ARCHIVE_STATUS.md')
failures << "README.md must document archived version #{version}" unless readme.include?("Archived version: #{version}")
docs_plans.each do |plan_path|
  failures << "README.md must reference #{plan_path}" unless readme.include?(plan_path)
end
readme.scan(%r{docs/plans/[-\w.]+\.md}).each do |plan_path|
  failures << "README.md references missing plan #{plan_path}" unless File.exist?(plan_path)
end

if File.exist?('ARCHIVE_STATUS.md')
  archive_status = File.read('ARCHIVE_STATUS.md')
  failures << 'ARCHIVE_STATUS.md must declare historical snapshot status' unless archive_status.include?('historical snapshot')
  failures << "ARCHIVE_STATUS.md must document version #{version}" unless archive_status.include?("Version: #{version}")
  failures << 'ARCHIVE_STATUS.md must document JSON=pure verification' unless archive_status.include?('JSON=pure')
  failures << 'ARCHIVE_STATUS.md must preserve security-relevant parser fixtures' unless archive_status.include?('security-relevant parser fixtures')
  failures << 'ARCHIVE_STATUS.md must mention the unterminated block comment fixture' unless archive_status.include?('unterminated block comment')
else
  failures << 'ARCHIVE_STATUS.md is missing'
end

if failures.empty?
  puts 'Archive metadata checks passed'
else
  warn "Archive metadata checks failed:\n- #{failures.join("\n- ")}"
  exit 1
end
