require 'open3'
require 'rbconfig'
require 'socket'
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
  raise 'response must not leak referrers' unless response['Referrer-Policy'] == 'no-referrer'
  raise 'response framing mismatch' unless response['Content-Length'].to_i == response.body.bytesize

  payload = JSON.parse(response.body)
  raise 'missing timestamp' unless payload['TIME'].is_a?(String)
  raise 'missing counter' unless payload['COUNT'].is_a?(Integer)
  raise 'unicode payload changed' unless payload['foo'] == 'Bär' && payload['g'] == '松本行弘'

  descendant = http.get('/json/extra')
  raise "unexpected descendant status #{descendant.code}" unless descendant.code == '404'
  raise 'descendant must not be JSON' if descendant['Content-Type'].to_s.start_with?('application/json')
  raise 'descendant response is cacheable' unless descendant['Cache-Control'] == 'no-store'
  raise 'descendant response allows sniffing' unless descendant['X-Content-Type-Options'] == 'nosniff'

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

  def test_local_demo_does_not_log_request_metadata
    script = <<'RUBY'
require 'net/http'
require 'stringio'
require './tools/server'

log = StringIO.new
server = create_server(log, File.expand_path('data'), 0)
thread = Thread.new { server.start }
begin
  port = server.listeners.first.addr[1]
  http = Net::HTTP.new('127.0.0.1', port, nil)
  request = Net::HTTP::Get.new('/json?token=private-query-value')
  request['Referer'] = 'https://private.example/account'
  request['User-Agent'] = 'private-agent-value'
  response = http.request(request)
  raise "unexpected status #{response.code}" unless response.code == '200'
ensure
  server.shutdown
  thread.join
end

output = log.string
['private-query-value', 'private.example', 'private-agent-value'].each do |secret|
  raise "request metadata leaked to the local log: #{secret}" if output.include?(secret)
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

  def test_json_endpoint_rejects_noncanonical_request_targets
    script = <<'RUBY'
require 'json'
require 'net/http'
require 'socket'
require 'stringio'
require './tools/server'

def raw_get(port, target)
  socket = TCPSocket.new('127.0.0.1', port)
  socket.write("GET #{target} HTTP/1.1\r\nHost: 127.0.0.1\r\nConnection: close\r\n\r\n")
  response = socket.read
  socket.close
  response
end

server = create_server(StringIO.new, File.expand_path('data'), 0)
thread = Thread.new { server.start }
begin
  port = server.listeners.first.addr[1]
  http = Net::HTTP.new('127.0.0.1', port, nil)
  first_count = JSON.parse(http.get('/json?source=canonical').body)['COUNT']

  ['/json/..', '/json%2F..', '/%6ason', '//json', '/json%00'].each do |target|
    response = raw_get(port, target)
    status = response.lines.first.to_s
    headers, body = response.split("\r\n\r\n", 2)
    raise "#{target} was not rejected: #{status}" unless status.include?(' 404 ')
    raise "#{target} returned JSON" if headers.to_s.downcase.include?('content-type: application/json')
    raise "#{target} error response is cacheable" unless headers.to_s.downcase.include?("cache-control: no-store")
    raise "#{target} error response allows sniffing" unless headers.to_s.downcase.include?("x-content-type-options: nosniff")
    raise "#{target} returned an empty error" if body.to_s.empty?
  end

  next_count = JSON.parse(http.get('/json').body)['COUNT']
  raise 'rejected aliases mutated the JSON counter' unless next_count == first_count + 1
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

  def test_static_server_rejects_symlinks_and_oversized_files
    script = <<'RUBY'
require 'net/http'
require 'stringio'
require 'tmpdir'
require './tools/server'

Dir.mktmpdir do |outside|
  Dir.mktmpdir do |root|
    secret = File.join(outside, 'secret.txt')
    File.binwrite(secret, 'not for the demo')
    File.binwrite(File.join(root, 'index.html'), '<h1>demo</h1>')
    File.binwrite(File.join(root, 'large.bin'), 'x' * 1_048_577)
    File.symlink(secret, File.join(root, 'leak.txt'))

    server = create_server(StringIO.new, root, 0)
    thread = Thread.new { server.start }
    begin
      port = server.listeners.first.addr[1]
      http = Net::HTTP.new('127.0.0.1', port, nil)

      index = http.get('/')
      raise "unexpected index status #{index.code}" unless index.code == '200'
      raise 'index framing mismatch' unless index['Content-Length'].to_i == index.body.bytesize
      raise 'index response is cacheable' unless index['Cache-Control'] == 'no-store'
      raise 'index response allows sniffing' unless index['X-Content-Type-Options'] == 'nosniff'
      raise 'index response leaks referrers' unless index['Referrer-Policy'] == 'no-referrer'

      leak = http.get('/leak.txt')
      raise "symlink was served: #{leak.code}" unless leak.code == '404'
      raise 'symlink target leaked' if leak.body.include?('not for the demo')

      large = http.get('/large.bin')
      raise "oversized file was served: #{large.code}" unless large.code == '413'
      raise 'oversized body was returned' if large.body.bytesize > 1024
    ensure
      server.shutdown
      thread.join
    end
  end
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

  def test_create_server_rejects_invalid_document_roots
    script = <<'RUBY'
require 'stringio'
require 'tmpdir'
require './tools/server'

Dir.mktmpdir do |parent|
  directory = File.join(parent, 'data')
  Dir.mkdir(directory)
  file = File.join(parent, 'file')
  File.binwrite(file, 'not a directory')
  link = File.join(parent, 'link')
  File.symlink(directory, link)

  [file, File.join(file, 'child'), link, File.join(parent, 'missing')].each do |root|
    begin
      server = create_server(StringIO.new, root, 0)
      server.shutdown
      raise "invalid document root was accepted: #{root}"
    rescue ArgumentError
    end
  end
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
