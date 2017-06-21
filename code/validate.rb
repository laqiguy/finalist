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
	## Write in db 
end

arg = ""

if ARGV.count != 3 then
	exit
end

dir = ARGV[0]
path = ARGV[1]
commit = ARGV[2]

puts dir

posName = dir.split('/').last.split('.').first

modPath = findModule(dir)
podPath = findPod(dir)

if modPath == nil || podPath == nil then
	at_exit {
		sendReport(posName, "module manifest or podspec didnt found")
	}
	exit
end

if modPath.split('/').count != dir.split('/').count + 1 || modPath.split('/').count != modPath.split('/').count then
	at_exit {
		sendReport(posName, "module manifest and podspec must be in same folder")
	}
	exit
end

mod = Module.new()
file = File.read(modPath)
data_hash = JSON.parse(file) rescue nil

if data_hash == nil then
	at_exit {
		sendReport(posName,"Manifest file has wrong fromat (has to be pure json)")
	}
	exit
end

mod.fill(data_hash)

if !mod.validate then
	at_exit {
		sendReport(mod.name == "" ? posName : mod.name,"Not all \"must have\" fields are filled in module manifest")
	}
	exit
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
	at_exit {
		sendReport(mod.name,"didnt find protocol in module")
	}
	exit
end
if classRel == nil then
	at_exit {
		sendReport(mod.name,"didnt find class realisation")
	}
	exit
end

protHead = proto.gsub(/protocol #{mod.protocolName}(| *\n*)(: \D[^ \.\<\>\?\/\:\;\!\*\@\"\'\#\%\^\&\(\)\+\-\=]*)*{/i)

if protHead.count != 1 then
	at_exit {
		sendReport(mod.name,"wrong protocol format or multiple protocols")
	}
	exit
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
	at_exit {
		sendReport(mod.name,"wrong class format or multiple classes")
	}
	exit
end

classHead = classHead.each.next
classInh = classHead.split(':')[1].split('{').first.split(',').map.with_index{ |x, i| x.strip }
if !(classInh.include? protocol.name) then 
	at_exit {
		sendReport(mod.name,"class does not release protocol")
	}
	exit
end

classinit = classRel.gsub(/func #{mod.rootInitialize}(| *\n*)*\(\)(| *\n*)*{/i)

if classinit.count == 0 then
	at_exit {
		sendReport(mod.name,"no initialize method realized in root class")
	}
	exit
end

db = SQLite3::Database.new "./module.db"
mod.strongDependencies.each do |key, value|

end

mod.weakDependencies.each do |key, valuse|

end

# create table module(name text,
# 					protocol text,
# 					commit text,
# 					version text, 
# 					manifest text, 
# 					podspec text,
# 					thin_podspec text);


## Write in db 

/func \D[^ \.\,\<\>\?\/\:\;\!\*\@\"\'\#\%\^\&\(\)\+\-\=\[\]]*()/
/var \D[^ \.\,\<\>\?\/\:\;\!\*\@\"\'\#\%\^\&\(\)\+\-\=\[\]]*\: \D[^ \.\,\<\>\?\/\:\;\!\*\@\"\'\#\%\^\&\(\)\+\-\=]*(|\?|\!)+ {get( set)?}/
/protocol \D[^ \.\,\<\>\?\/\:\;\!\*\@\"\'\#\%\^\&\(\)\+\-\=]*(| *\n*)(:(| *\n*)\D[^ \.\<\>\?\/\:\;\!\*\@\"\'\#\%\^\&\(\)\+\-\=]*)*(| *\n*){/
/class \D[^ \.\,\<\>\?\/\:\;\!\*\@\"\'\#\%\^\&\(\)\+\-\=]*(| *\n*)(:\D[^ \.\<\>\?\/\:\;\!\*\@\"\'\#\%\^\&\(\)\+\-\=]*)*(| *\n*){/
