#!/usr/bin/env ruby

require 'find'
require 'json'
require 'sqlite3'

require_relative 'ModuleClass'
require_relative 'ModuleProtoClass'

def findPod(dir)
	podPaths = []
	Find.find(dir) do |path|
		podPaths << path if path =~ /.*\.podspec$/
	end
	if podPaths.count == 1 then 
		return podPaths[0]
	end
	return nil
end

def findModule (dir)
	modulepaths = []
	Find.find(dir) do |path|
		modulepaths << path if path =~ /.*\.modfst$/
	end
	if modulepaths.count == 1 then
		return modulepaths[0]
	end
	return nil
end

def sendReport (name, msg)
	puts msg
	db = SQLite3::Database.new "module.db"
	db.execute("INSERT INTO validationReport (moduleName, msg) 
            VALUES (?, ?)", [name, msg])
	exit
end


arg = ""

if ARGV.count != 2 then
	exit
end

dir = ARGV[0]
commit = ARGV[1]

# puts dir

posName = dir.split('/').last.split('.').first
path = "git@dioc:#{posName}"

modPath = findModule(dir)
podPath = findPod(dir)

if modPath == nil || podPath == nil then
		sendReport(posName, "module manifest or podspec didnt found")
end

if modPath.split('/').count != dir.split('/').count + 1 || modPath.split('/').count != modPath.split('/').count then
		sendReport(posName, "module manifest and podspec must be in same folder")
end

mod = Module.new()
file = File.read(modPath)
data_hash = JSON.parse(file) rescue nil

if data_hash == nil then
		sendReport(posName,"Manifest file has wrong fromat (has to be pure json)")
end

mod.fill(data_hash)

if !mod.validate then
		sendReport(mod.name == "" ? posName : mod.name,"Not all \"must have\" fields are filled in module manifest")
end

protoUrl = mod.protocolUrl.split('/')
protoUrl[0] = dir
protoUrl = protoUrl.join('/')

classUrl = mod.rootUrl.split('/')
classUrl[0] = dir
classUrl = classUrl.join('/')

proto = File.read(protoUrl) rescue nil
classRel = File.read(classUrl) rescue nil

if proto == nil then
		sendReport(mod.name,"didnt find protocol in module")
end
if classRel == nil then
		sendReport(mod.name,"didnt find class realisation")
end

protHead = proto.gsub(/protocol #{mod.protocolName}(| *\n*)(: \D[^ \.\<\>\?\/\:\;\!\*\@\"\'\#\%\^\&\(\)\+\-\=]*)*{/i)

if protHead.count != 1 then
		sendReport(mod.name,"wrong protocol format or multiple protocols")
end

protHead = protHead.each.next
protocol = ModuleProto.new()

protocol.name = protHead.split(' ')[1].split(':')[0].split('{')[0]
vars = proto.gsub(/var \D[^ \.\,\<\>\?\/\:\;\!\*\@\"\'\#\%\^\&\(\)\+\-\=\[\]]*(| *\n*)*\:(| *\n*)*\D[^ \.\,\<\>\?\/\:\;\!\*\@\"\'\#\%\^\&\(\)\+\-\=]*(|\?|\!)+ {get( set)?}/i)
vars.each do |str|
	name = str.split(' ')[1].split(':')[0]
	type = str.split(':')[1].split('{')[0].strip
	protocol.vars[name] = type
end
puts protocol.vars

classHead = classRel.gsub(/class #{mod.rootClass}(| *\n*)*(:\D[^ \.\<\>\?\/\:\;\!\*\@\"\'\#\%\^\&\(\)\+\-\=]*((| *\n*)*,(| *\n*)*\D[^ \.\<\>\?\/\:\;\!\*\@\"\'\#\%\^\&\(\)\+\-\=]*)*)*(| *\n*)*{/i)
puts classHead.count

if classHead.count != 1 then
		sendReport(mod.name,"wrong class format or multiple classes")
end

classHead = classHead.each.next
classInh = classHead.split(':')[1].split('{').first.split(',').map.with_index{ |x, i| x.strip }
if !(classInh.include? protocol.name) then 
		sendReport(mod.name,"class does not release protocol")
end

classinit = classRel.gsub(/func #{mod.rootInitialize}(| *\n*)*\(\)(| *\n*)*{/i)

if classinit.count == 0 then
		sendReport(mod.name,"no initialize method realized in root class")
end

db = SQLite3::Database.new("./module.db")
mod.strongDependencies.each do |key, value|
	modules = db.execute("select * from module where name = '#{value}'")
	if modules.count == 1 then
		protocolName = modules[0][1]
		if !protocol.vars.include?(key) then
			sendReport(mod.name,"no variable #{key} in protocol")
		end

		if !protocol.vars[key].include?(protocolName)
			sendReport(mod.name,"wrong protocol for variable #{key}")
		end

		if protocol.vars[key].include?('?') then
			sendReport(mod.name,"variable #{key} must be not optional")
		end
	else
		sendReport(mod.name,"dependency #{value} does not exist")
	end
end

mod.weakDependencies.each do |key, value|
	modules = db.execute("select * from module where name = '#{value}'")
	if modules.count == 1 then
		protocolName = modules[0][1]
		if !protocol.vars.include?(key) then
			sendReport(mod.name,"no variable #{key} in protocol")
		end

		if !protocol.vars[key].include?(protocolName)
			sendReport(mod.name,"wrong protocol for variable #{key}")
		end

		if !protocol.vars[key].include?('?') then
			sendReport(mod.name,"variable #{key} must be optional")
		end
	else
		sendReport(mod.name,"dependency #{value} does not exist")
	end
end

if db.execute("select * from module where name = '#{mod.name}'").count == 1 then
	db.execute("UPDATE module SET commitHash = '#{commit}'")
else
	db.execute("INSERT INTO module (name, protocol, commitHash, path) 
            VALUES (?, ?, ?, ?)", [mod.name, protocol.name, commit, path])
end

