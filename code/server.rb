#!/usr/bin/env ruby

require 'webrick'
require 'sqlite3'

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

server = WEBrick::HTTPServer.new :Port => 8000

server.mount_proc '/' do |req, res|
	res.body = 'Hello, world!'
end

server.mount '/modules', Modules
server.mount '/validation', Validation
server.mount '/app', AppManifest


trap 'INT' do server.shutdown end

server.start

CREATE TABLE main.module(
	ID INT NOT NULL,
	NAME TEXT NOT NULL,
	VERSION TEXT,
	COMMIT TEXT,
	IS_CURRENT INT NOT NULL,
	PATH_TO_MAN TEXT,
	PATH_TO_MOD TEXT,
	PRIMARY KEY (ID, NAME)
);