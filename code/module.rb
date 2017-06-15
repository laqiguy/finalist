#!/usr/bin/env ruby

require 'find'
require 'set'
require 'json'

class Module

	attr_accessor :name,:description,:type,:rootClass,:rootInitialize,:protocolName,:protocolUrl,:strongDependencies,:weakDependencies

	def initialize()
		@name = ""
		@description = "My brand new module"
		@type = ""
		@rootClass = ""
		@rootInitialize = ""
		@protocolName = ""
		@protocolUrl = ""
		@strongDependencies = Hash.new()
		@weakDependencies = Hash.new()
	end

	def fill(json)
      	@name = json["name"]
		@description = json["name"]
		@type = json["name"]
		@rootClass = json["name"]
		@rootInitialize = json["name"]
		@protocolName = json["name"] 
		@protocolUrl = json["name"] 
		@strongDependencies = json["name"]
		@weakDependencies = json["name"]

      	@name ||= ""
		@description ||= ""
		@type ||= ""
		@rootClass ||= ""
		@rootInitialize ||= ""
		@protocolName ||= ""
		@protocolUrl ||= ""
		@strongDependencies ||=  Hash.new()
		@weakDependencies ||=  Hash.new()
	end

	def to_json()
		mod = Hash.new()
		mod["name"] = @name
		mod["description"] = @description
		mod["type"] = @type
		mod["rootClass"] = @rootClass
		mod["rootInitialize"] = @rootInitialize
		mod["protocolName"] = @protocolName
		mod["protocolUrl"] = @protocolUrl
		mod["strongDependencies"] = @strongDependencies
		mod["weakDependencies"] = @weakDependencies
		return mod
	end
end

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
			puts "Which file? (type 'q' to exit)"
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
		podPaths << path if path =~ /Podfile/
	end
	xPaths = []
	Find.find(dir) do |path|
		xPaths << path if path =~ /.*\.(xcodeproj|xcworkspace)$/ && !xPaths.include?(path)
	end
	if podPaths.count > 0 then 
		if podPaths.count == 1 then
			podfile = podPaths[0]
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
			return podFolder if projArray.count != 0 
		else
			puts "Error. Podfile is only one for one project"
		end
	end

	return nil
end

def install(dir)
	# puts findModule(dir)
end

def update(dir)
end

def create(dir)
	folderPath = findPodXproj(dir)
	if folderPath != nil then
		podfile = folderPath + "/Podfile"
		mod = Module.new()
		puts "Write you module name:"
		name = STDIN.gets.chomp
		mod.name = name
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
	puts 4
end

arg = "empty"

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