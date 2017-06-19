#!/usr/bin/env ruby

class ModuleProto

	attr_accessor :name,
	:vars

	def initialize()
		@name = ""
		@vars = Hash.new()
	end
end