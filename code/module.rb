#!/usr/bin/env ruby

require 'find'
require 'set'

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
			return podfile if projArray.count != 0 
		else
			puts "Error. Podfile is only one for one project"
		end
	end

	return nil
end

def install(dir)
	# puts findModule(dir)
	puts findPodXproj(dir)
end

def update(dir)
end

def create(dir, args)
	puts args
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
	create(dir, ARGV)
when "validate" then
	validate(dir)
else
	puts "error"
end

# ARGV.each do|a|
#   puts "Argument: #{a}"
# end