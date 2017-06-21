#!/usr/bin/env ruby

require 'webrick'

class Modules < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
	response.status = 200
	response['Content-Type'] = 'text/plain'
	response.body = 'Hello, World!'
  end
end

class Validation < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
	response.status = 200
	response['Content-Type'] = 'text/plain'
	response.body = 'Hello, World!'
  end
end

class AppManifest < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
	response.status = 200
	response['Content-Type'] = 'text/plain'
	response.body = 'Hello, World!'
  end
end

class Update < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
	response.status = 200
	body = request.body
	name = body.split('/').last.split('.').first
	puts name
	exec("git clone /home/git/#{name}.git")
	dir = "~/#{name}"
	path = "git@174.138.58.175:#{name}.git"
	commit = exec('git rev-parse HEAD')

	response['Content-Type'] = 'text/plain'
    response.body = 'Hello, World!'
  end
end

server = WEBrick::HTTPServer.new :Port => 8000

server.mount_proc '/' do |req, res|
	res.body = 'Hello, world!'
end

server.mount '/update', Update
server.mount '/modules', Modules
server.mount '/validation', Validation
server.mount '/app', AppManifest


trap 'INT' do server.shutdown end

server.start