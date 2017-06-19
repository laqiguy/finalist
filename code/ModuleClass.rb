#!/usr/bin/env ruby

class Module

	attr_accessor :name,
	:description,
	:type,
	:rootClass,
	:rootUrl,
	:rootInitialize,
	:protocolName,
	:protocolUrl,
	:mockUrl,
	:strongDependencies,
	:weakDependencies

	def initialize()
		@name = ""
		@description = "My brand new module"
		@type = ""
		@rootClass = ""
		@rootUrl = ""
		@rootInitialize = ""
		@protocolName = ""
		@protocolUrl = ""
		@mockUrl = nil
		@strongDependencies = Hash.new()
		@weakDependencies = Hash.new()
	end

	def fill(json)
      	@name = json["name"]
		@description = json["description"]
		@type = json["type"]
		@rootClass = json["rootClass"]
		@rootUrl = json["rootUrl"]
		@rootInitialize = json["rootInitialize"]
		@protocolName = json["protocolName"] 
		@protocolUrl = json["protocolUrl"] 
		@mockUrl = json["mockUrl"]
		@strongDependencies = json["strongDependencies"]
		@weakDependencies = json["weakDependencies"]

      	@name ||= ""
		@description ||= ""
		@type ||= ""
		@rootClass ||= ""
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
		mod["rootUrl"] = @rootUrl
		mod["rootInitialize"] = @rootInitialize
		mod["protocolName"] = @protocolName
		mod["protocolUrl"] = @protocolUrl
		mod["mockUrl"] = @mockUrl
		mod["strongDependencies"] = @strongDependencies
		mod["weakDependencies"] = @weakDependencies
		return mod.to_json()
	end

	def validate()
		return @name != "" && @description != "" && @type != "" && @rootClass != "" && @rootUrl != "" && @rootInitialize != "" && @protocolName != "" && @protocolUrl != "" 
	end
end