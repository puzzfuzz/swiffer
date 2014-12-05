EventEmitter = require('events').EventEmitter
domain = require 'domain'

class ModuleManager
	constructor: (@logger, @swiffer)->
		@modules = {}
		@eventProxies = {}
		@domains = {}

	proxyEvent: (event)->
		for name, emitter of @eventProxies
			emitter.emit.apply emitter, event

	getEventProxy: (name)->
		if (@eventProxies[name])
			return @eventProxies[name]

		@eventProxies[name] = new EventEmitter()
		@getDomain(name).add @eventProxies[name]

		return @eventProxies[name]

	getDomain: (name)->
		if (@domains[name])
			return @domains[name]
		d = @domains[name] = domain.create()
		d.on 'error', (er)=>
			@logger.log er
		return @domains[name]

	cleanUp: (name)->
		delete require.cache[require.resolve("../plugins/#{name}")]
		delete @eventProxies[name]
		delete @domains[name]

	loadModule: (name)->
		try
			@logger.log @logger.clc.cyan "About to load #{name}"
			@unloadModule name
			Module = require("../plugins/#{name}")
			@modules[name] = new Module @logger, @swiffer
		catch e
			@logger.log @logger.clc.red(e.message) + @logger.clc.cyan(" in #{name}")
			@logger.log @logger.clc.red(e)

	unloadModule: (name)->
		try
			module = @modules[name]
			module?.unload()

			@swiffer.app._router.stack = @swiffer.app._router.stack.filter (route)=>
				route.handle != module.router

		catch e
		finally
			delete @modules[name]
			@cleanUp name



module.exports = ModuleManager
