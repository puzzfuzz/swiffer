Prompt = require './lib/prompt'
express = require 'express'
exception = require './controllers/c_exceptions'
config = require '../config'
ModuleManager = require './lib/modulemanager'
bodyParser = require 'body-parser'
vm = require 'vm'

app = express()
server = require('http').Server(app)
io = require('socket.io').listen(server)


staticRoot = __dirname + config['staticRoot']

class Swiffer
	constructor: ->
		@setupPrompt()
		@module = new ModuleManager @prompt, @
		@setupExpress()

	setupPrompt: ->
		@prompt = new Prompt
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
#		@app = express()

#		@app.use (req, res, next)=>
		app.use (req, res, next)=>
			res.header "Access-Control-Allow-Origin", "*"
			res.header "Access-Control-Allow-Headers", "X-Requested-With"
			res.header "Access-Control-Allow-Headers", "Content-Type"
			next()

#		@app.use bodyParser.json()
		app.use bodyParser.json()
#		@app.use express.static(staticRoot)
		app.use express.static(staticRoot)

#		@app.get '/', (req, res) =>
		app.get '/', (req, res) =>
			console.log "handling default root..."
			res.sendFile('index.html', {root:staticRoot})

		@setupSocket()

#		@app.listen config.port, =>

		#--- MUST listen on server, not app for socket.io to work
		server.listen config.port, =>
			@prompt.setStatusLines [@prompt.clc.green "Listening on port #{config.port}"]

	setupSocket: ->
#		@server = require('http').Server(@app)
#		@io = require('socket.io')(@server)

		io.sockets.on 'connection', (socket)=>
			exception.get (err, data)=>
				if (err)
					return
				data.forEach (exception) =>
					socket.emit 'exception', exception

	parseCommand: (msg)->
		index = msg.indexOf(" ")
		if index < 1 then index = msg.length
		cmd = msg.substring(1, index)

		if index == msg.length
			args = null
		else
			args = msg.substring index

		switch cmd
			when "e"
				try
					result = vm.runInContext args, context
					@prompt.log result
				catch e
					@prompt.log e
			when "l"
				args = args.trim()
				@module.loadModule args


swiffer = new Swiffer()

scope = 
	swiffer: swiffer
	prompt: swiffer.prompt
	require: require

context = vm.createContext scope
