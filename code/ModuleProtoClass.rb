#!/usr/bin/env ruby

class Application

	attr_accessor :name,
	:modules,
	:rootModule

	def initialize()
		@name = ""
		@modules = []
		@rootModule = ""
	end

	def fill(json)
		@name = json["name"]
		@modules = json["modules"]
		@rootModule = json["rootModule"]


      	@name ||= ""
		@modules ||= []
		@rootModule ||=  ""
	end
end