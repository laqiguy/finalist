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
		return mod.to_json()
	end
end