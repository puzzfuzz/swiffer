EventEmitter = require('events').EventEmitter
domain = require 'domain'
express = require 'express'

class ModuleManager
	constructor: (@logger, @swiffer)->
		@modules = {}
		@eventProxies = {}
		@domains = {}

	proxyEvent: ()->
		for name, emitter of @eventProxies
			emitter.emit.apply emitter, arguments

	getEventProxy: (name)->
		if (@eventProxies[name])
			return @eventProxies[name]

		@eventProxies[name] = new EventEmitter()
		@getDomain(name).add @eventProxies[name]

		@eventProxies[name].on 'io', (data)=>
			@swiffer.io.sockets.emit data.name, data.data

		@eventProxies[name].on 'axon', (data)=>
			@swiffer.axonSocket.send data.name, data.data

		return @eventProxies[name]

	getDomain: (name)->
		if @domains[name] and !@domains[name]._disposed	
			return @domains[name]

		console.log "Creating a domain for #{name}"
		d = @domains[name] = domain.create()
		d.on 'error', (e)=>
			@logger.log @logger.clc.red(e.message) + @logger.clc.cyan(" in #{name}")
			@logger.log @logger.clc.red(e)
			@logger.log @logger.clc.red(e.stack)
			@unloadModule name
			# @loadModule name
		return @domains[name]

	cleanUp: (name)->
		delete require.cache[require.resolve("../plugins/#{name}")]
		delete @eventProxies[name]
		@domains[name]?.dispose()
		delete @domains[name]
		delete @modules[name]

	loadModule: (name)->
		@unloadModule name
		myDomain = @getDomain name
		myDomain.run =>
			@logger.log @logger.clc.cyan "About to load #{name}"
			Module = require("../plugins/#{name}")
			@modules[name] = new Module @logger, @swiffer, @getEventProxy(name)


			if @modules[name].router
				@logger.log "Setting up the router proxy"
				router = express.Router()
				router.use (req, res, next)=>
						myDomain.exit()
						@getDomain(name).run next
					, @modules[name].router

				# router.use @modules[name].router
				@swiffer.app.use router
				@modules[name]._router_ref = router

	unloadModule: (name)->
		if !@modules[name]
			return @cleanUp name
		try
			module = @modules[name]
			module?.unload()

			@swiffer.app._router.stack = @swiffer.app._router.stack.filter (route)=>
				route.handle != module._router_ref

		catch e
		finally
			@cleanUp name



module.exports = ModuleManager
