EventEmitter = require('events').EventEmitter
domain = require 'domain'
express = require 'express'
_ = require 'underscore'

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

		myDomain = @getDomain(name)

		@eventProxies[name] = new EventEmitter()
		myDomain.add @eventProxies[name]

		@eventProxies[name].on 'io', (data)=>
			myDomain.exit()
			@swiffer.io.sockets.emit data.name, data.data

		@eventProxies[name].on 'axon', (data)=>
			myDomain.exit()
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

	addClient: (socket)=>
		console.log "Creating a new client for the modules"
		@proxyEvent 'connection', socket
		_(@modules).each (module, moduleName)=>
			if module.api
				myDomain = @getDomain moduleName
				_(module.api).each (method, api)->
					if typeof method == 'string'
						method = module[method]
					console.log "Binding #{api} to #{moduleName}"
					socket.on api, ->
						console.log 'Invoking this method!', arguments
						myDomain.exit()
						myDomain.run ->
							method.apply module, arguments

	loadModule: (name)->
		@unloadModule name
		myDomain = @getDomain name
		myDomain.exit()
		myDomain.run =>
			@logger.log @logger.clc.cyan "About to load #{name}"
			Module = require("../plugins/#{name}")
			module = @modules[name] = new Module @logger, @swiffer, @getEventProxy(name)


			if module.api
				_(module.api).each (method, api)=>
					if typeof method == 'string'
						method = module[method]

					_(@swiffer.io.of('/').connected).each (client)->
						client.on api, ->
							myDomain.exit()
							myDomain.run ->
								method.apply module, arguments

			if module.router
				@logger.log "Setting up the router proxy"
				router = express.Router()
				router.use (req, res, next)=>
						myDomain.exit()
						@getDomain(name).run next
					, module.router

				# router.use module.router
				@swiffer.app.use router
				module._router_ref = router

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
