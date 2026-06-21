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
vulnerability_review_plan = 'docs/plans/2026-06-12-archive-vulnerability-review.md'
gem_build_plan = 'docs/plans/2026-06-12-gem-package-build-contract.md'
gem_metadata_plan = 'docs/plans/2026-06-12-gem-license-dependency-metadata.md'
make_root_plan = 'docs/plans/2026-06-14-make-root-override-protection.md'
server_load_path_plan = 'docs/plans/2026-06-14-server-repository-load-path.md'
java_compile_plan = 'docs/plans/2026-06-16-java-source-compile-gate.md'
java_compile_check = 'scripts/check_java_sources.rb'
hosted_validation_workflow = '.github/workflows/check.yml'
failures << "#{canonical_plan} is missing" unless File.exist?(canonical_plan)
failures << "#{fuzzer_count_plan} is missing" unless File.exist?(fuzzer_count_plan)
failures << "#{local_server_plan} is missing" unless File.exist?(local_server_plan)
failures << "#{hosted_validation_plan} is missing" unless File.exist?(hosted_validation_plan)
failures << "#{vulnerability_review_plan} is missing" unless File.exist?(vulnerability_review_plan)
failures << "#{gem_build_plan} is missing" unless File.exist?(gem_build_plan)
failures << "#{gem_metadata_plan} is missing" unless File.exist?(gem_metadata_plan)
failures << "#{make_root_plan} is missing" unless File.exist?(make_root_plan)
failures << "#{server_load_path_plan} is missing" unless File.exist?(server_load_path_plan)
failures << "#{java_compile_plan} is missing" unless File.exist?(java_compile_plan)
failures << "#{java_compile_check} is missing" unless File.exist?(java_compile_check)
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
    'uses: actions/checkout@9f698171ed81b15d1823a05fc7211befd50c8ae0',
    'persist-credentials: false',
    'timeout-minutes: 10',
    'cancel-in-progress: true',
    'run: make check',
    'java-archive:',
    'name: Java 8 archived source compilation',
    'uses: actions/setup-java@ad2b38190b15e4d6bdf0c97fb4fca8412226d287',
    'distribution: temurin',
    "java-version: '8'",
    'run: gem install --user-install --no-document jruby-jars -v 1.7.27',
    'run: make java-check'
  ].each do |fragment|
    failures << "#{hosted_validation_workflow} must include #{fragment.inspect}" unless workflow.include?(fragment)
  end
  actions = workflow.scan(/^\s*(?:-\s*)?uses:\s*([^@\s]+)@([^\s#]+)/)
  expected_actions = [
    ['actions/checkout', '9f698171ed81b15d1823a05fc7211befd50c8ae0'],
    ['actions/checkout', '9f698171ed81b15d1823a05fc7211befd50c8ae0'],
    ['actions/setup-java', 'ad2b38190b15e4d6bdf0c97fb4fca8412226d287']
  ]
  failures << "#{hosted_validation_workflow} must use only the approved checkout and Java setup actions" unless actions == expected_actions

  actions.each do |action, revision|
    unless revision.match?(/\A[a-f0-9]{40}\z/)
      failures << "#{hosted_validation_workflow} action #{action} must be pinned to a full commit SHA"
    end
  end
  unless workflow.scan(/^permissions:$/).length == 1 &&
         !workflow.match?(/^\s+[A-Za-z0-9_-]+:\s*write\s*$/)
    failures << "#{hosted_validation_workflow} must keep exactly one read-only permissions block"
  end
  unless workflow.scan(/persist-credentials:\s*false/).length == 2
    failures << "#{hosted_validation_workflow} must disable persisted checkout credentials for both jobs"
  end
  %w[push: pull_request: workflow_dispatch:].each do |trigger|
    failures << "#{hosted_validation_workflow} must include #{trigger}" unless workflow.match?(/^  #{Regexp.escape(trigger)}$/)
  end
  if workflow.include?('pull_request_target:')
    failures << "#{hosted_validation_workflow} must not use pull_request_target"
  end
  if workflow.match?(/^\s+branches:/)
    failures << "#{hosted_validation_workflow} must run push validation on every branch"
  end
  approved_java_install = 'gem install --user-install --no-document jruby-jars -v 1.7.27'
  unless workflow.scan(approved_java_install).length == 1
    failures << "#{hosted_validation_workflow} must install the pinned JRuby compile API exactly once"
  end
  dependency_commands = workflow.gsub(approved_java_install, '')
  if dependency_commands.match?(/\b(?:bundle|gem)\s+(?:install|update)\b/)
    failures << "#{hosted_validation_workflow} must keep archive validation dependency-free"
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
unless server.include?('res[\'Content-Type\'] = "application/json; charset=utf-8"') &&
       server.include?('res[\'Cache-Control\'] = "no-store"') &&
       server.include?('res[\'X-Content-Type-Options\'] = "nosniff"')
  failures << 'tools/server.rb must keep explicit local JSON response headers'
end
unless server.include?("raise HTTPStatus::NotFound unless req.path == '/json'")
  failures << 'tools/server.rb must keep the local JSON servlet on the exact /json path'
end
unless server.include?("archive_root = File.expand_path('..', __dir__)") &&
       server.include?("$:.unshift File.join(archive_root, 'ext')") &&
       server.include?("$:.unshift File.join(archive_root, 'lib')")
  failures << 'tools/server.rb must load archived JSON relative to itself'
end

server_test = 'tests/test_server.rb'
if File.exist?(server_test)
  server_test_source = File.read(server_test)
  unless server_test_source.include?("server.config[:BindAddress] == '127.0.0.1'") &&
         server_test_source.include?("server.listeners.first.addr[3] == '127.0.0.1'") &&
         server_test_source.include?("http.get('/json')") &&
         server_test_source.include?("response['Content-Type'] == 'application/json; charset=utf-8'") &&
         server_test_source.include?("response['Cache-Control'] == 'no-store'") &&
         server_test_source.include?("response['X-Content-Type-Options'] == 'nosniff'") &&
         server_test_source.include?("JSON.parse(response.body)") &&
         server_test_source.include?("http.get('/json?source=test')") &&
         server_test_source.include?("http.get('/json/extra')") &&
         server_test_source.include?("descendant.code == '404'") &&
         server_test_source.include?("descendant must not be JSON") &&
         server_test_source.include?("rejected descendant incremented the counter") &&
         server_test_source.include?('test_absolute_server_load_uses_archived_json_outside_checkout') &&
         server_test_source.include?("JSON::VERSION == '1.7.5'") &&
         server_test_source.include?(':chdir => Dir.tmpdir')
    failures << "#{server_test} must verify loopback binding and the JSON endpoint response"
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

gem_build_test = 'scripts/test_gem_builds.rb'
if File.exist?(gem_build_test)
  gem_build_source = File.read(gem_build_test)
  [
    "'json.gemspec'",
    "'json_pure.gemspec'",
    "'json-java.gemspec'",
    ["require 'rubygems/", "package'"].join,
    "entry.include?('\\\\')",
    ["components.include?('", ".')"].join,
    ["components.include?('", "..')"].join,
    ['path.cleanpath.to_s ', '!= entry'].join,
    'canonical manifest paths without ./ aliases',
    "'GPL-2.0-only', 'Ruby'",
    "'open-ended dependency on permutation'",
    "permutation.requirement.to_s == expected[:permutation]",
    'Rakefile gemspec generators must preserve dual-license metadata',
    'Rakefile gemspec generators must preserve bounded permutation metadata',
    ['repository_gems_after == ', 'repository_gems_before'].join,
    'Gem package build tests passed'
  ].each do |fragment|
    failures << "#{gem_build_test} must include #{fragment.inspect}" unless gem_build_source.include?(fragment)
  end
else
  failures << "#{gem_build_test} is missing"
end

%w[json.gemspec json_pure.gemspec json-java.gemspec].each do |gemspec|
  source = File.read(gemspec)
  unless source.include?('s.licenses = ["Ruby", "GPL-2.0-only"]')
    failures << "#{gemspec} must declare the preserved Ruby or GPL-2.0-only license boundary"
  end
end

%w[json.gemspec json_pure.gemspec].each do |gemspec|
  source = File.read(gemspec)
  failures << "#{gemspec} must bound permutation to ~> 0.1" unless source.scan('["~> 0.1"]').length == 3
  failures << "#{gemspec} must not retain open-ended permutation requirements" if source.include?('permutation>, [">= 0"]')
end

java_gemspec = File.read('json-java.gemspec')
unless java_gemspec.include?('["COPYING-json-jruby", "GPL"]')
  failures << 'json-java.gemspec must package both preserved license texts'
end

rakefile_source = File.read('Rakefile')
unless rakefile_source.scan("s.licenses = ['Ruby', 'GPL-2.0-only']").length == 2
  failures << 'Rakefile gemspec generators must declare the preserved dual-license metadata'
end
unless rakefile_source.scan("s.add_development_dependency 'permutation', '~> 0.1'").length == 2
  failures << 'Rakefile gemspec generators must bound permutation to ~> 0.1'
end
unless rakefile_source.scan("s.add_development_dependency 'rake', '~> 13.4.2'").length == 1
  failures << 'Rakefile pure gem generator must bound rake to patched ~> 13.4.2'
end

pure_gemspec = File.read('json_pure.gemspec')
unless pure_gemspec.scan('["~> 13.4.2"]').length == 3
  failures << 'json_pure.gemspec must bound every rake dependency branch to patched ~> 13.4.2'
end

makefile = File.read('Makefile')
[
  'override SHELL := /bin/sh',
  'override .SHELLFLAGS := -c',
  '.SECONDEXPANSION:',
  'override RUBY := ruby',
  'override JAVAC := javac',
  '$(error MAKEFILES must be empty; repository verification requires this Makefile to be loaded alone)',
  '$(error MAKEFILE_LIST must not be overridden)',
  'override ROOT := $(shell sed_path=/usr/bin/sed;',
  '[ -f "$$path" ] || exit 1',
  'export ROOT',
  '$(error repository Makefile path could not be resolved)',
  '$(error repository Makefile must be loaded alone)',
  '"$$ROOT/scripts/test-makefile-root.sh"'
].each do |fragment|
  failures << "Makefile must preserve authority contract #{fragment.inspect}" unless makefile.include?(fragment)
end
unless makefile.include?('cd "$$ROOT" && $(RUBY) scripts/test_gem_builds.rb')
  failures << 'Makefile build must run the gem package build contract from ROOT'
end
unless makefile.include?('java-check:') &&
       makefile.include?('override JAVAC := javac') &&
       makefile.include?('cd "$$ROOT" && JAVAC="$(JAVAC)" $(RUBY) scripts/check_java_sources.rb')
  failures << 'Makefile must expose the repository-rooted Java source compile gate'
end

root_test = File.read('scripts/test-makefile-root.sh')
['77 executed target/authority cases', '2 MAKEFILE_LIST rejections', 'detected MAKEFILES preload startup', '2 multi-Makefile rejections', '1 dollar-path fail-closed case'].each do |fragment|
  failures << "Makefile root test must preserve #{fragment.inspect}" unless root_test.include?(fragment)
end

if File.exist?(java_compile_check)
  java_compile_source = File.read(java_compile_check)
  [
    "JRUBY_JARS_VERSION = '1.7.27'",
    "JRUBY_CORE_SHA256 = '0e68235b2d500020cbcbda807e60eb8d75ecd732e3e618726e84db78f02cc60d'",
    "'-source', '1.5'",
    "'-target', '1.5'",
    "Dir.mktmpdir('rubyimpjson-java-check-')",
    'rescue Errno::ENOENT',
    "File.join(ROOT, 'java', 'src', '**', '*.class')"
  ].each do |fragment|
    failures << "#{java_compile_check} must include #{fragment.inspect}" unless java_compile_source.include?(fragment)
  end
  expected_java_sources = Dir['java/src/json/ext/*.java'].map { |path| File.basename(path) }.sort
  expected_java_sources.each do |source|
    failures << "#{java_compile_check} must require #{source}" unless java_compile_source.include?(source)
  end
end

readme = File.read('README.md')
failures << 'README.md must document make verify' unless readme.include?('make verify')
failures << 'README.md must document the JSON=pure test variant' unless readme.include?('JSON=pure')
failures << 'README.md must link ARCHIVE_STATUS.md' unless readme.include?('ARCHIVE_STATUS.md')
failures << "README.md must document archived version #{version}" unless readme.include?("Archived version: #{version}")
failures << 'README.md must document the local-only HTTP example server' unless readme.include?('local-only HTTP')
failures << 'README.md must clarify parseQuery/parseObject are not Parse SDK integrations' unless readme.include?('not Parse SDK')
failures << 'README.md must document the gem package build contract' unless readme.include?('gem package build contract')
failures << 'README.md must document gem license and dependency metadata checks' unless readme.include?('license and dependency metadata')
failures << 'README.md must document make java-check' unless readme.include?('make java-check')
failures << 'README.md must document jruby-jars 1.7.27' unless readme.include?('jruby-jars 1.7.27')
docs_plans.each do |plan_path|
  failures << "README.md must reference #{plan_path}" unless readme.include?(plan_path)
end
readme.scan(%r{docs/plans/[-\w.]+\.md}).each do |plan_path|
  failures << "README.md references missing plan #{plan_path}" unless File.exist?(plan_path)
end

if File.exist?(make_root_plan)
  root_plan = File.read(make_root_plan)
  [
    'Status: Completed',
    '`make ROOT=/tmp check` passed',
    'all five public Make aliases passed',
    'Six hostile mutations were rejected',
    'digest-pinned Ruby 2.7'
  ].each do |evidence|
    failures << "#{make_root_plan} must record verification evidence #{evidence.inspect}" unless root_plan.include?(evidence)
  end
end

safe_make_plan = 'docs/plans/2026-06-21-safe-make-authority.md'
if File.exist?(safe_make_plan)
  evidence = File.read(safe_make_plan)
  ['77 executed target, root, shell, Ruby, and Java authority cases', 'Both `MAKEFILE_LIST` override channels', 'parsed `MAKEFILES` preload', 'preceding and trailing multiple-Makefile invocations failed'].each do |fragment|
    failures << "#{safe_make_plan} must record #{fragment.inspect}" unless evidence.include?(fragment)
  end
else
  failures << "#{safe_make_plan} is missing"
end

if File.exist?(server_load_path_plan)
  server_load_path_evidence = File.read(server_load_path_plan)
  [
    'Status: Completed',
    'external-directory server test passed',
    'repository and external-directory `make check` passed',
    'hostile load-path mutations were rejected'
  ].each do |evidence|
    failures << "#{server_load_path_plan} must record verification evidence #{evidence.inspect}" unless server_load_path_evidence.include?(evidence)
  end
end

if File.exist?(java_compile_plan)
  java_compile_evidence = File.read(java_compile_plan)
  [
    'Status: Completed',
    'repository and external-directory `make java-check` passed',
    'repository and external-directory `make check` passed',
    'hostile compiler-gate mutations were rejected',
    'JRuby extension runtime was not executed'
  ].each do |evidence|
    failures << "#{java_compile_plan} must record verification evidence #{evidence.inspect}" unless java_compile_evidence.include?(evidence)
  end
end

archive_status = ''
if File.exist?('ARCHIVE_STATUS.md')
  archive_status = File.read('ARCHIVE_STATUS.md')
  failures << 'ARCHIVE_STATUS.md must declare historical snapshot status' unless archive_status.include?('historical snapshot')
  failures << "ARCHIVE_STATUS.md must document version #{version}" unless archive_status.include?("Version: #{version}")
  failures << 'ARCHIVE_STATUS.md must document JSON=pure verification' unless archive_status.include?('JSON=pure')
  failures << 'ARCHIVE_STATUS.md must preserve security-relevant parser fixtures' unless archive_status.include?('security-relevant parser fixtures')
  failures << 'ARCHIVE_STATUS.md must mention the unterminated block comment fixture' unless archive_status.include?('unterminated block comment')
  failures << 'ARCHIVE_STATUS.md must document local-only HTTP server scope' unless archive_status.include?('local-only HTTP')
  failures << 'ARCHIVE_STATUS.md must document bounded permutation metadata' unless archive_status.include?('permutation ~> 0.1')
else
  failures << 'ARCHIVE_STATUS.md is missing'
end

security = File.read('SECURITY.md')
failures << 'SECURITY.md must document local-only HTTP server scope' unless security.include?('local-only HTTP')
failures << 'SECURITY.md must clarify parser/prototype names are not Parse SDK integrations' unless security.include?('not Parse SDK')

%w[README.md SECURITY.md VISION.md CHANGES.md].each do |path|
  failures << "#{path} must document the Java source compile gate" unless File.read(path).include?('Java source compile gate')
end

[readme, archive_status, security, File.read('VISION.md'), File.read('CHANGES.md')].each_with_index do |document, index|
  failures << "archive document #{index + 1} must mention the gem package build contract" unless document.include?('gem package build contract')
  failures << "archive document #{index + 1} must mention the dual-license metadata" unless document.include?('Ruby or GPL-2.0-only')
end

response_header_docs = {
  'README.md' => ['explicit UTF-8', 'no-store', 'nosniff'],
  'ARCHIVE_STATUS.md' => ['UTF-8', 'no-store', 'nosniff response headers'],
  'SECURITY.md' => ['explicit UTF-8', 'Cache-Control: no-store', 'X-Content-Type-Options: nosniff'],
  'VISION.md' => ['explicit UTF-8', 'no-store', 'nosniff headers'],
  'CHANGES.md' => ['explicit UTF-8', 'no-store', 'nosniff headers']
}
response_header_docs.each do |path, fragments|
  document = File.read(path).delete('`')
  fragments.each do |fragment|
    failures << "#{path} must document #{fragment.inspect}" unless document.include?(fragment)
  end
end

%w[README.md VISION.md CHANGES.md].each do |path|
  unless File.read(path).delete('`').include?('exact /json path')
    failures << "#{path} must document the exact /json path"
  end
end

archive_risk_docs = [readme, archive_status, security, File.read('VISION.md')]
%w[CVE-2013-0269 CVE-2020-10663].each do |advisory|
  unless archive_risk_docs.all? { |document| document.include?(advisory) }
    failures << "archive risk documentation must mention #{advisory}"
  end
end

if File.exist?(vulnerability_review_plan)
  review = File.read(vulnerability_review_plan)
  unless review.include?('json_pure') &&
         review.include?('gem build json.gemspec') &&
         review.include?('gem build json_pure.gemspec') &&
         review.include?('Do not deploy')
    failures << "#{vulnerability_review_plan} must record package queries, builds, and non-production policy"
  end
end

if failures.empty?
  puts 'Archive metadata checks passed'
else
  warn "Archive metadata checks failed:\n- #{failures.join("\n- ")}"
  exit 1
end
