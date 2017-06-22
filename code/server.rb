#!/usr/bin/env ruby

require 'webrick'
require 'sqlite3'
require 'json'
require 'set'
require_relative 'AppClass'
require_relative 'ModuleClass'

class Tree
	attr_accessor :name,
	:commit,
	:path,
	:protocol,
	:manifest,
	:branches

	def initialize()
		@name = ""
		@branches = []
		@commit = ""
		@path = ""
		@protocol = ""
		@manifest = Hash.new()
	end
end

class Modules < WEBrick::HTTPServlet::AbstractServlet
	def do_GET(request, response)
		response.status = 200
		response['Content-Type'] = 'application/json'
		result = Hash.new()
		keys = ['name','protocol','commitHash','path']
		db = SQLite3::Database.new("./module.db")
		rows = db.execute("select * from module")
		modules = []
		rows.each { |elem|
			temp = Hash.new()
			for i in 0..keys.count-1
				temp[keys[i]] = elem[i]
			end
			modules.push(temp)
		}
		result["modules"] = modules
		response.body = result.to_json
	end
end

class Validation < WEBrick::HTTPServlet::AbstractServlet
	def do_GET(request, response)
		response.status = 200
		name = request.query().keys.first
		response['Content-Type'] = 'application/json'
		puts request.query().keys.first
		if name != nil then
			db = SQLite3::Database.new("./module.db")
			rows = db.execute("select * from validationReport where moduleName = '#{name}'")
			if rows.count == 1 then
				response.body = '{"msg": "#{rows[0][1]}"}'
			else
				response.body = '{"error": "not validation msg found for that module"}'
			end
		else
			response.body = '{"error": "invalid name"}'
		end
	end
end

class AppManifest < WEBrick::HTTPServlet::AbstractServlet
	def do_POST(request, response)
		response.status = 200
		body = request.body
		data = JSON.parse(body) rescue nil
		if data != nil
			app = Application.new()
			app.fill(data)
			gottenModules = Set.new(app.modules)
			db = SQLite3::Database.new("./module.db")

			def getDeps(name, tree)
				rows = db.execute("select * from module where name = '#{name}'")
				if rows.count == 1 then
					tree = Tree.new()
					tree.name = name
					tree.protocol = rows[1]
					tree.commit = rows[2]
					tree.path = rows[3]
					gottenModules.add(name)
					path = "/home/git/#{name}/#{name}.modfst"
					file = File.new(path, "w")
					modjson =  JSON.parse(file) rescue nil
					if modjson != nil then
						tree.manifest = modjson
						mod = Module.new()
						mod.fill(modjson)
						mod.strongDependencies.each { |dep|
							if !gottenModules.include?(dep) then
								tempTree = getDeps(dep, tree)
								if tempTree != nil then
									tree.branches.push(tempTree)
								end 
							end
						}
					end
					return tree
				end
				return nil
			end

			def depth(tree, array)
				locArray = array
				data = Hash.new()
				data["name"] = tree.name
				data["protocol"] = tree.protocol
				data["commit"] = tree.commit
				data["path"] = tree.path
				data["manifest"] = tree.manifest
				if tree.branches.count == 0 then
					locArray.push(data)
				else
					tree.branches.each { |br|
						locArray = locArray + depth(br, array) 
					}
				end
				return locArray
			end

			rows = db.execute("select * from module where name = '#{app.rootModule}'")
			if rows.count == 1 then
				tree = Tree.new()
				tree.protocol = rows[1]
				tree.commit = rows[2]
				tree.path = rows[3]
				Tree.name = app.rootModule
				gottenModules.add(app.rootModule)
				path = "/home/git/#{app.rootModule}/#{app.rootModule}.modfst"
				file = File.new(path, "w")
				modjson =  JSON.parse(file) rescue nil
				if modjson != nil then
					tree.manifest = modjson
					mod = Module.new()
					mod.fill(modjson)
					mod.strongDependencies.each { |dep|
						if !gottenModules.include?(dep) then
							tempTree = getDeps(dep, tree)
							if tempTree != nil then
								tree.branches.push(tempTree)
							end 
						end
					}
				end
			end

			resultArray = depth(tree)
			result["modules"] = resultArray
			response['Content-Type'] = 'application/json'
			response.body = result.to_json
		else
			response['Content-Type'] = 'application/json'
			response.body = '{"error": "invalid name"}'
		end
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
		commit = exec('git rev-parse HEAD')
		exec('./validate.rb #{dir} #{commit}')
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