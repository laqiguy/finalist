#!/usr/bin/env ruby

require 'find'
require 'json'

# require_relative 'ModuleClass'

def findPod(dir)
	podPaths = []
	Find.find(dir) do |path|
		podPaths << path if path =~ /.*\.podspec$/
	end
	puts podPaths
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

arg = ""

if ARGV.count >= 1 then
	arg = ARGV[0]
end

dir = Dir.pwd

modPath = findModule(dir)
podPath = findPod(dir)

if modPath != nil && podPath != nil&& modPath.split('/').count == dir.split('/').count + 1 && modPath.split('/').count == modPath.split('/').count then
	mod = Module.new()
	file = File.read(modPath)
	data_hash = JSON.parse(file) rescue nil
	puts data_hash
	if data_hash != nil then
		mod.fill(data_hash)
		if mod.name != "" then
		end
	end
else
	puts "Find no module manifest or multiple manifests"
end

/var \D[^ \.\,\<\>\?\/\:\;\!\*\@\"\'\#\%\^\&\(\)\+\-\=]*:(| *\n*)\D[^ \.\,\<\>\?\/\:\;\!\*\@\"\'\#\%\^\&\(\)\+\-\=]*(| *\n*){get(( | *\n)set)?}/
/protocol \D[^ \.\,\<\>\?\/\:\;\!\*\@\"\'\#\%\^\&\(\)\+\-\=]*(| *\n*)(:(| *\n*)\D[^ \.\<\>\?\/\:\;\!\*\@\"\'\#\%\^\&\(\)\+\-\=]*)*(| *\n*){/
/class \D[^ \.\,\<\>\?\/\:\;\!\*\@\"\'\#\%\^\&\(\)\+\-\=]*(| *\n*)(:\D[^ \.\<\>\?\/\:\;\!\*\@\"\'\#\%\^\&\(\)\+\-\=]*)*(| *\n*){/
