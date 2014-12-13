Prompt = require './lib/prompt'
express = require 'express'
config = require '../config'
ModuleManager = require './lib/modulemanager'
bodyParser = require 'body-parser'
vm = require 'vm'
axon = require 'axon'

staticRoot = __dirname + config.staticRoot

class Swiffer
	constructor: ->
		@setupPrompt()
		@init()

	init: ->
		@setupExpress()
		@setupSocket()
		@setupDatabase()
		@setupAxon()

		@module = new ModuleManager @prompt, @

		@module.loadModule module for module in config.modules

	reload: ->
		@module.unloadModule module for own module of @module.modules

		@module = null
		@app = null
		@appServer.close()
		@db?.close()
		@db = null
		@axonSocket.close()
		@axonSocket = null

		delete require.cache[require.resolve('./db/' + config.database)]
		delete require.cache[require.resolve('../config')]
		delete require.cache[require.resolve('./lib/modulemanager')]

		config = require '../config'
		ModuleManager = require './lib/modulemanager'



		timeleft = config.restartTime || 5
		restartWaiter = ()=>
			@prompt.setStatusLines [@prompt.clc.blackBright("Server stopped..."), @prompt.clc.yellow("Restarting in #{timeleft}...")]
			if timeleft == 0
				@init()
				@prompt.log @prompt.clc.yellow("Restarting server")
			else
				timeleft--
				setTimeout restartWaiter, 1000

		restartWaiter()


	setupPrompt: ->
		@prompt = new Prompt @
		@prompt.setStatusLines [@prompt.clc.blackBright "Starting up..."]
		console.log = =>
			@prompt.log.apply @prompt, arguments

		@prompt.on 'line', (msg)=>
			if (msg.charAt(0) == "/")
				if (msg.charAt(1) == " ")
					msg = "/"+msg.substring(2)
				else
					return @parseCommand msg

			# do something with msg?


	setupExpress: ->
		#scoped app out for socket-io config, prolly not the best idea - CP
		@app = express();

		@app.use (req, res, next)=>
			res.header "Access-Control-Allow-Origin", "*"
			res.header "Access-Control-Allow-Headers", "X-Requested-With"
			res.header "Access-Control-Allow-Headers", "Content-Type"
			next()

		@app.use bodyParser.json()
		@app.use express.static(staticRoot)

		@app.get '/', (req, res) =>
			@prompt.log "handling default root..."
			res.sendFile('index.html', {root:staticRoot})

#		@app.listen config.port, =>
		#--- MUST listen on server, not app for socket.io to work
		@appServer = require('http').createServer(@app)
		@appServer.listen config.port, =>
			@prompt.setStatusLines [@prompt.clc.green "Listening on port #{config.port}"]


	setupSocket: ->
		@io = require('socket.io').listen(@appServer)

		@io.sockets.on 'connection', (socket)=>
			@module.proxyEvent 'connection', socket

	setupAxon: ->
		@axonSocket = axon.socket 'pub'
		@axonSocket.bind 10382

	setupDatabase: ->
		if !config.database
			return

		Database = require './db/' + config.database

		if Database
			@db = new Database @

	parseCommand: (msg)->
		index = msg.indexOf(" ")
		if index < 1 then index = msg.length
		cmd = msg.substring(1, index)

		if index == msg.length
			args = null
		else
			args = msg.substring index

		switch cmd
			when "restart"
				@reload()

			when "e"
				try
					result = vm.runInContext args, context
					@prompt.log result
				catch e
					@prompt.log e
			when "l", "loadModule"
				args = args.trim()
				@module.loadModule args
			when "unloadModule"
				args = args.trim()
				@module.unloadModule args


swiffer = new Swiffer()

scope = 
	swiffer: swiffer
	prompt: swiffer.prompt
	require: require

context = vm.createContext scope
