#!/usr/bin/env ruby

require_relative 'ModuleClass'
require 'find'
require 'json'

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
			puts "Which file?"
			for i in 0..modulepaths.count-1
				puts i.to_s + ". " + modulepaths[i]
			end
			input = STDIN.gets.chomp
			b = Integer(input) rescue -1
			while input != "q" && (b < 0 || b >= modulepaths.count) do
				input = STDIN.gets.chomp
				b = Integer(input) rescue -1
			end
			path = modulepaths[b]
			return path
		end
	end
	return nil
end

def findPodXproj (dir)
	podPaths = []
	Find.find(dir) do |path|
		podPaths << path if path =~ /.*\.podspec$/
	end
	xPaths = []
	Find.find(dir) do |path|
		xPaths << path if path =~ /_Pods\.xcodeproj|$/ && !xPaths.include?(path)
	end
	if podPaths.count > 0 then 
		podfile = ""
		if podPaths.count > 1 then
			puts "Which podspec file is main?"
			for i in 0..podPaths.count-1
				puts i.to_s + ". " + podPaths[i]
			end
			input = STDIN.gets.chomp
			b = Integer(input) rescue -1
			while b < 0 || b >= podPaths.count do
				input = STDIN.gets.chomp
				b = Integer(input) rescue -1
			end
			podfile = podPaths[b] 
		else
			podfile = podPaths[0]
		end
		podArray = podfile.split("/")
		podFolder = podArray[0..podArray.count-2].join("/")
		projArray = []
		for path in xPaths do
			xarr = path.split("/")
			xFolder = xarr[0..xarr.count-2].join("/")
			if xFolder == podFolder then
				projArray << path
			end
		end
		return podfile if projArray.count != 0
	end
	return nil
end

def install(dir)
	folderPath = findPodXproj(dir)
	modulePath = findModule(dir)
	if folderPath != nil && modulePath != nil then
		# Server needed
	end
end

def update(dir)
	folderPath = findPodXproj(dir)
	modulePath = findModule(dir)
	if folderPath != nil && modulePath != nil then
		# Server needed
	end
end

def create(dir)
	folderPath = findPodXproj(dir)
	folderPath = folderPath.split("/")[0..folderPath.split("/").count-2].join("/")
	folderName = folderPath.split("/")[folderPath.split("/").count-2]
	if folderPath != nil then
		podfile = folderPath + "/Podfile"
		mod = Module.new()
		puts "Write you module name (enter will set name \"#{folderName}\"): "
		name = STDIN.gets.chomp
		mod.name = name == "" ? folderName : name
		out_file = File.new(folderPath + "/" + name + ".module", "w")
		puts "Module type: 0. System, 1. View"
		input = STDIN.gets.chomp
		typenum = Integer(input) rescue -1
		while typenum != 0 && typenum != 1 do
			input = STDIN.gets.chomp
			b = Integer(input) rescue -1
		end
		type = typenum == 0 ? "sys" : "view"
		mod.type = type		
		out_file.puts(mod.to_json)
		out_file.close
	end
end

def validate(dir)
	modulePath = findModule(dir)
	if modulePath != nil then
		mod = Module.new()
		file = File.read(modulePath)
		data_hash = JSON.parse(file)
		mod.fill(data_hash)
		if mod.name != "" then
			#Запрос к серверу. Сообщение валидации
		end
	end
end

arg = ""

if ARGV.count >= 1 then
	arg = ARGV[0]
end

dir = Dir.pwd

case arg
when "install" then 
	install(dir)
when "update" then
	update(dir)
when "create" then
	create(dir)
when "validate" then
	validate(dir)
else
	puts "error"
end

# ARGV.each do|a|
#   puts "Argument: #{a}"
# end