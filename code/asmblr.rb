#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'
require_relative 'ModuleClass'

if ARGV.count >= 1 then
	arg = ARGV[0]
end

dir = arg

uri = URI.parse("174.138.58.175/app")

# Full control
http = Net::HTTP.new(uri.host, uri.port)

request = Net::HTTP::Post.new(uri.request_uri)
request.body = File.open("#{dir}",'r')

appMan = JSON.parse(request.body) rescue nil
appName = appMan["name"]

response = http.request(request)
body = response.body

if body != nil then
	data = JSON.parse(body) rescue nil
	if data != nil then
		vcName = ""
		usedVars = Hash.new()
		appDelDecl = "var assembler: Assembler!"
		appDelCode = "window = UIWindow(frame: UIScreen.main.bounds)\n
				self.assembler = Assembler.init(window: UIWindow)"

		declString = "import UIKit\nimport Foundation\n\nclass Assembler {\n"
		initString = "\tfunc init(){\n"

		podString = "source 'https://github.com/CocoaPods/Specs.git'\n
		platform :ios, '8.0'\n
		use_frameworks!
		\ninhibit_all_warnings!
		\ntarget '#{appMan["appName"]}' do\n"

		data["modules"].each { |mod|
			name = mod["name"]
			man = Module.new()
			man.fill(mod["manifest"])
			commit = mod["commit"]
			path = mod["path"]
			protocol = mod["protocol"]
			podString += "pod '#{name}' :path => '#{path}' :commit => '#{commit}'\n"
			usedVars[protocol] = name
			declString += "\tvar #{name}: #{protocol}!"
			initString += "\t\t#{name} = #{man.rootClass}()\n"
			man.strongDependencies.each do |key, value|
				if usedVars[value] != nil then
					initString += "#{name}.key = #{usedVars[value]}"
				end
			end
			man.weakDependencies.each do |key, value|
				if usedVars[value] != nil then
					initString += "#{name}.key = #{usedVars[value]}"
				end
			end
			initString +="\t\t#{name}.#{man.rootInitialize}()\n\n\n"
			if name == appMan["rootModule"] then
				vcName = man.view
			end
		}
		initString += "window.rootController = #{appMan}.#{vcName}\n\t\twindow.makeKeyAndVisible()\n"
		initString += "\}"
		resultString = declString + initString + "}"
		podString += "end"
	end
end