#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path('..', __dir__)
Dir.chdir(ROOT)

failures = []

docs_plans = Dir['docs/plans/*.md'].sort
canonical_plan = 'docs/plans/2026-06-08-rubyimpjson-baseline.md'
fuzzer_count_plan = 'docs/plans/2026-06-09-fuzzer-count-validation.md'
local_server_plan = 'docs/plans/2026-06-10-local-server-loopback.md'
hosted_validation_plan = 'docs/plans/2026-06-10-hosted-archive-validation.md'
hosted_validation_workflow = '.github/workflows/check.yml'
failures << "#{canonical_plan} is missing" unless File.exist?(canonical_plan)
failures << "#{fuzzer_count_plan} is missing" unless File.exist?(fuzzer_count_plan)
failures << "#{local_server_plan} is missing" unless File.exist?(local_server_plan)
failures << "#{hosted_validation_plan} is missing" unless File.exist?(hosted_validation_plan)
failures << "#{hosted_validation_workflow} is missing" unless File.exist?(hosted_validation_workflow)
failures << 'docs/plans must contain at least one completed plan' if docs_plans.empty?

docs_plans.each do |plan_path|
  plan = File.read(plan_path)
  unless plan.include?('Status: Completed') && plan.include?('make check')
    failures << "#{plan_path} must record completed status and make check verification"
  end
end

if File.exist?(hosted_validation_workflow)
  workflow = File.read(hosted_validation_workflow)
  [
    'runs-on: ubuntu-24.04',
    'permissions:',
    'contents: read',
    'ruby:2.7@sha256:2347de892e419c7160fc21dec721d5952736909f8c3fbb7f84cb4a07aaf9ce7d',
    'uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10',
    'run: make check'
  ].each do |fragment|
    failures << "#{hosted_validation_workflow} must include #{fragment.inspect}" unless workflow.include?(fragment)
  end
  workflow.scan(/^\s*uses:\s*([^@\s]+)@([^\s#]+)/).each do |action, revision|
    unless revision.match?(/\A[a-f0-9]{40}\z/)
      failures << "#{hosted_validation_workflow} action #{action} must be pinned to a full commit SHA"
    end
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

fixture_test = File.read('tests/test_json_fixtures.rb')
unless fixture_test.include?('File.basename(filename)') &&
       fixture_test.include?("'/tmp/second-pass/fixtures/fail1.json'")
  failures << 'tests/test_json_fixtures.rb must classify fixtures by basename, not parent paths'
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
unless server.include?(":BindAddress  => '127.0.0.1'") &&
       server.include?('"http://127.0.0.1:#{port}"') &&
       server.include?('if $PROGRAM_NAME == __FILE__') &&
       !server.include?('Socket.gethostname')
  failures << 'tools/server.rb must keep the historical HTTP demo bound to loopback'
end

server_test = 'tests/test_server.rb'
if File.exist?(server_test)
  server_test_source = File.read(server_test)
  unless server_test_source.include?("server.config[:BindAddress] == '127.0.0.1'") &&
         server_test_source.include?("server.listeners.first.addr[3] == '127.0.0.1'")
    failures << "#{server_test} must verify the configured and listening loopback addresses"
  end
else
  failures << "#{server_test} is missing"
end

fuzzer = File.read('tools/fuzz.rb')
unless fuzzer.include?('r = rand') && fuzzer.include?('f.include? r')
  failures << 'tools/fuzz.rb must use the sampled random value when selecting frequency buckets'
end
if fuzzer.include?('f.include? rand')
  failures << 'tools/fuzz.rb must not resample random values while selecting a frequency bucket'
end
unless fuzzer.include?('def parse_count(value)') &&
       fuzzer.include?('Integer(value || 500)') &&
       fuzzer.include?('count < 1') &&
       fuzzer.include?('n = parse_count(ARGV.shift)')
  failures << 'tools/fuzz.rb must validate positive integer fuzzer counts before generating payloads'
end

readme = File.read('README.md')
failures << 'README.md must document make verify' unless readme.include?('make verify')
failures << 'README.md must document the JSON=pure test variant' unless readme.include?('JSON=pure')
failures << 'README.md must link ARCHIVE_STATUS.md' unless readme.include?('ARCHIVE_STATUS.md')
failures << "README.md must document archived version #{version}" unless readme.include?("Archived version: #{version}")
failures << 'README.md must document the local-only HTTP example server' unless readme.include?('local-only HTTP')
failures << 'README.md must clarify parseQuery/parseObject are not Parse SDK integrations' unless readme.include?('not Parse SDK')
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
  failures << 'ARCHIVE_STATUS.md must document local-only HTTP server scope' unless archive_status.include?('local-only HTTP')
else
  failures << 'ARCHIVE_STATUS.md is missing'
end

security = File.read('SECURITY.md')
failures << 'SECURITY.md must document local-only HTTP server scope' unless security.include?('local-only HTTP')
failures << 'SECURITY.md must clarify parser/prototype names are not Parse SDK integrations' unless security.include?('not Parse SDK')

if failures.empty?
  puts 'Archive metadata checks passed'
else
  warn "Archive metadata checks failed:\n- #{failures.join("\n- ")}"
  exit 1
end
