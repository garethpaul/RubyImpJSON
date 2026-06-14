require 'open3'
require 'rbconfig'
require 'test/unit'
require 'tmpdir'

class TestServer < Test::Unit::TestCase
  def test_absolute_server_load_uses_archived_json_outside_checkout
    server_path = File.expand_path('../tools/server.rb', __dir__)
    archive_lib = File.expand_path('../lib', __dir__)
    script = <<RUBY
require #{server_path.dump}
raise "unexpected JSON version \#{JSON::VERSION}" unless JSON::VERSION == '1.7.5'
version_feature = $LOADED_FEATURES.find { |feature| feature.end_with?('/json/version.rb') }
raise "unexpected JSON feature \#{version_feature}" unless version_feature.start_with?(#{archive_lib.dump})
RUBY

    _stdout, stderr, status = Open3.capture3(
      { 'JSON' => 'pure' },
      RbConfig.ruby,
      '-e',
      script,
      :chdir => Dir.tmpdir
    )

    assert_predicate status, :success?, stderr
  end

  def test_create_server_binds_only_to_ipv4_loopback
    script = <<'RUBY'
require 'stringio'
require './tools/server'

server = create_server(StringIO.new, File.expand_path('data'), 0)
begin
  raise 'configured address is not loopback' unless server.config[:BindAddress] == '127.0.0.1'
  raise 'listening address is not loopback' unless server.listeners.first.addr[3] == '127.0.0.1'
ensure
  server.shutdown
end
RUBY

    _stdout, stderr, status = Open3.capture3(
      { 'JSON' => 'pure' },
      RbConfig.ruby,
      '-Ilib',
      '-e',
      script,
      :chdir => File.expand_path('..', __dir__)
    )

    assert_predicate status, :success?, stderr
  end

  def test_json_endpoint_serves_a_valid_local_payload
    script = <<'RUBY'
require 'json'
require 'net/http'
require 'stringio'
require './tools/server'

server = create_server(StringIO.new, File.expand_path('data'), 0)
thread = Thread.new { server.start }
begin
  port = server.listeners.first.addr[1]
  http = Net::HTTP.new('127.0.0.1', port, nil)
  response = http.get('/json?source=test')
  raise "unexpected status #{response.code}" unless response.code == '200'
  raise 'unexpected content type' unless response['Content-Type'] == 'application/json; charset=utf-8'
  raise 'response must not be cached' unless response['Cache-Control'] == 'no-store'
  raise 'response must disable MIME sniffing' unless response['X-Content-Type-Options'] == 'nosniff'

  payload = JSON.parse(response.body)
  raise 'missing timestamp' unless payload['TIME'].is_a?(String)
  raise 'missing counter' unless payload['COUNT'].is_a?(Integer)
  raise 'unicode payload changed' unless payload['foo'] == 'Bär' && payload['g'] == '松本行弘'

  descendant = http.get('/json/extra')
  raise "unexpected descendant status #{descendant.code}" unless descendant.code == '404'
  raise 'descendant must not be JSON' if descendant['Content-Type'].to_s.start_with?('application/json')

  next_payload = JSON.parse(http.get('/json').body)
  raise 'rejected descendant incremented the counter' unless next_payload['COUNT'] == payload['COUNT'] + 1
ensure
  server.shutdown
  thread.join
end
RUBY

    _stdout, stderr, status = Open3.capture3(
      { 'JSON' => 'pure' },
      RbConfig.ruby,
      '-Ilib',
      '-e',
      script,
      :chdir => File.expand_path('..', __dir__)
    )

    assert_predicate status, :success?, stderr
  end
end
