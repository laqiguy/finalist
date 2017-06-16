#!/usr/bin/env ruby

require 'find'
require 'json'
require_relative 'ModuleClass'

def findModule (dir)
	modulepaths = []
	Find.find(dir) do |path|
		modulepaths << path if path =~ /.*\.module$/
	end
	if modulepaths.count > 0 then 
		if modulepaths.count == 1 then
			puts modulepaths[0]
			return modulepaths[0]
		else
			index = -1
			short = 10000
			for i in 0..modulepaths.count-1
				if modulepaths[i].split("/").count < short then
					short = modulepaths[i].split("/").count
					index = i
				end
			end
			path = modulepaths[index]
			return path
		end
	end
	return nil
end

arg = ""

if ARGV.count >= 1 then
	arg = ARGV[0]
end

dir = Dir.pwd

modPath = findModule(dir)

if modPath != nil then
	mod = Module.new()
	file = File.read(modulePath)
	data_hash = JSON.parse(file)
	mod.fill(data_hash)
	if mod.name != "" then
		#Валидация
	end
end

