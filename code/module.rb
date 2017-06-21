#!/usr/bin/env ruby

require_relative 'ModuleClass'
require 'find'
require 'json'

def jsonToPodpec (hash)
	result = "Pod::Spec.new do |s|
	"
	hash.each do |key, value|
		if value.is_a?(String) then
			result += "s.#{key} = '#{value}', \n"
		else
			if key != "authors" then
				tempres = "s.#{key} = {"
				value.each do |tkey, tval|
					tempres += ":#{tkey} => '#{tval}',"
				end
				tempres += "},"
			else
				tempres = "s.authors = {"
				value.each do |tkey, tval|
					tempres += ":#{tkey} => '#{tval}',"
				end
				tempres += "},"
			end
			tempres.sub!(",}", "}")
			result+=tempres + "\n"
		end
	end
	result += "\nend"
end

def findModule (dir)
	modulepaths = []
	Find.find(dir) do |path|
		modulepaths << path if path =~ /.*\.modfst$/
	end
	if modulepaths.count == 1 && modulepaths.split('/').count - 1 == dir.split('/').count then
		puts modulepaths[0]
		return modulepaths[0]
	else
		return nil
	end
end

def findPod (dir)
	podPaths = []
	Find.find(dir) do |path|
		podPaths << path if path =~ /.*\.podspec$/
	end
	if podPaths.count == 1 then 
		podfile = podPaths[0]
		return podfile
	end
	return nil
end

def install(dir)
	folderPath = findPod(dir)
	modulePath = findModule(dir)
	if folderPath != nil && modulePath != nil then
		# Server needed
	end
end

def update(dir)
	folderPath = findPod(dir)
	modulePath = findModule(dir)
	if folderPath != nil && modulePath != nil then
		# Server needed
	end
end

def create(dir)
	folderPath = findPod(dir)
	folderPath = folderPath.split("/")[0..folderPath.split("/").count-2].join("/")
	folderName = folderPath.split("/")[folderPath.split("/").count-2]
	if folderPath != nil then
		podfile = folderPath + "/Podfile"
		mod = Module.new()
		puts "Write you module name (enter will set name \"#{folderName}\"): "
		name = STDIN.gets.chomp
		mod.name = name == "" ? folderName : name
		out_file = File.new(folderPath + "/" + name + ".modfst", "w")
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

system('pod ipc spec ~/projects/sample1/sample2.podspec > ./pod')
puts res
file = File.read('pod')
json = JSON.parse(file) rescue nil
puts jsonToPodpec(json)

# case arg
# when "install" then 
# 	install(dir)
# when "update" then
# 	update(dir)
# when "create" then
# 	create(dir)
# when "validate" then
# 	validate(dir)
# else
# 	puts "error"
# end

# ARGV.each do|a|
#   puts "Argument: #{a}"
# end