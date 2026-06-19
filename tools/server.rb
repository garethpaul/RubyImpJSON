#!/usr/bin/env ruby
# encoding: utf-8

require 'webrick'
include WEBrick
archive_root = File.expand_path('..', __dir__)
$:.unshift File.join(archive_root, 'ext')
$:.unshift File.join(archive_root, 'lib')
require 'json'

MAX_STATIC_FILE_BYTES = 1024 * 1024

def raw_request_path(req)
  request_target = req.request_line.to_s.split(' ', 3)[1]
  raise HTTPStatus::BadRequest, 'missing request target' unless request_target

  request_target.split('?', 2).first
end

def validate_document_root(dir)
  expanded = File.expand_path(dir)
  stat = File.lstat(expanded)
  unless stat.directory? && !stat.symlink?
    raise ArgumentError, "document root must be a real directory: #{expanded}"
  end
  File.realpath(expanded)
rescue Errno::ENOENT, Errno::EACCES, Errno::ENOTDIR
  raise ArgumentError, "document root is unavailable: #{expanded}"
end

def validate_document_path(root, path, type)
  expanded = File.expand_path(path)
  stat = File.lstat(expanded)
  real = File.realpath(expanded)
  inside_root = real == root || real.start_with?(root + File::SEPARATOR)
  valid_type = type == :directory ? stat.directory? : stat.file?

  raise HTTPStatus::NotFound unless inside_root && real == expanded && !stat.symlink? && valid_type
  if type == :file && stat.size > MAX_STATIC_FILE_BYTES
    raise HTTPStatus::RequestEntityTooLarge, 'static demo file is too large'
  end
rescue Errno::ENOENT, Errno::EACCES, Errno::ELOOP, Errno::ENOTDIR
  raise HTTPStatus::NotFound
end

class JSONServlet < HTTPServlet::AbstractServlet
  @@count = 1

  def do_GET(req, res)
    raise HTTPStatus::NotFound unless req.path == '/json'

    obj = {
      "TIME" => Time.now.strftime("%FT%T"),
      "foo" => "Bär",
      "bar" => "© ≠ €!",
      'a' => 2,
      'b' => 3.141,
      'COUNT' => @@count += 1,
      'c' => 'c',
      'd' => [ 1, "b", 3.14 ],
      'e' => { 'foo' => 'bar' },
      'g' => "松本行弘",
      'h' => 1000.0,
      'i' => 0.001,
      'j' => "\xf0\xa0\x80\x81",
    }
    res.body = JSON.generate obj
    res['Content-Type'] = "application/json; charset=utf-8"
    res['Cache-Control'] = "no-store"
    res['X-Content-Type-Options'] = "nosniff"
  end
end

def create_server(err, dir, port)
  dir = validate_document_root(dir)
  err.puts "Local JSON demo:", "http://127.0.0.1:#{port}"

  request_callback = proc do |req, res|
    res['Cache-Control'] = 'no-store'
    res['X-Content-Type-Options'] = 'nosniff'
    res['Referrer-Policy'] = 'no-referrer'

    path = raw_request_path(req)
    decoded_path = HTTPUtils.unescape(path)
    if path != '/json' && (req.path == '/json' || decoded_path.start_with?('/json'))
      raise HTTPStatus::NotFound
    end
  end

  directory_callback = proc do |_req, res|
    validate_document_path(dir, res.filename, :directory)
  end

  file_callback = proc do |_req, res|
    validate_document_path(dir, res.filename, :file)
  end

  s = HTTPServer.new(
    :Port         => port,
    :BindAddress  => '127.0.0.1',
    :DocumentRoot => dir,
    :DocumentRootOptions => {
      :DirectoryCallback => directory_callback,
      :FileCallback      => file_callback
    },
    :RequestCallback => request_callback,
    :Logger       => WEBrick::Log.new(err),
    :AccessLog    => [
      [ err, WEBrick::AccessLog::COMMON_LOG_FORMAT  ],
      [ err, WEBrick::AccessLog::REFERER_LOG_FORMAT ],
      [ err, WEBrick::AccessLog::AGENT_LOG_FORMAT   ]
    ]
  )
  s.mount("/json", JSONServlet)
  s
end

def parse_port(value)
  port = Integer(value || 6666)
  abort "port must be between 1 and 65535" if port < 1 || port > 65535
  port
rescue ArgumentError
  abort "port must be an integer"
end

if $PROGRAM_NAME == __FILE__
  default_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'data'))
  dir = ARGV.shift || default_dir
  port = parse_port(ARGV.shift)
  s = create_server(STDERR, dir, port)
  t = Thread.new { s.start }
  trap(:INT) do
    s.shutdown
    t.join
    exit
  end
  sleep
end
