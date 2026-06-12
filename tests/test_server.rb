require 'open3'
require 'rbconfig'
require 'test/unit'

class TestServer < Test::Unit::TestCase
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
end
