_ = require 'underscore'
express = require 'express'
bodyParser = require 'body-parser'

class ExceptionHandler
	constructor: (@logger, @swiffer, @events)->
		@logger.log "Exception handler constructor is running!!"
		@router = express.Router()

		@router.use bodyParser.json()

		@router.post '/exception', @save, @send
		@router.get '/exception', @get

		# @swiffer.app.use @router


		@events.on 'connection', (socket)=>
			socket.emit 'hello', {from: 'exception', to:'yours truely'}
			# model.get (err, data)=>
			# 	if (err)
			# 		return
			# 	data.forEach (exception) =>
			# 		socket.emit 'exception', exception

	save: (req, res, next)=>
		exception = _.clone(req.body)
		next()
		# model.save exception, (err)=>
		# 	if (err)
		# 		return res.json(503, { error: true })
		# 	model.trim()

	send: (req, res, next)=>
		@logger.log req.body
		exception = _.clone(req.body)
		res.status(200).json({ error: null })
		
		data = 
			name: 'exception'
			data: exception

		@events.emit 'io', data
		@events.emit 'axon', data

	get: (req, res)=>
		@logger.log "Exception get!"
		res.status(200).json({nothing: "indeed"})
		# model.get (err, data)=>
		# 	@logger.log "This is running, at least! and restarts"
		# 	if (err)
		# 		return res.json(503, { error: true })
		# 	res.status(200).json(data)

	unload: ->
		@router.routes = {}


module.exports = ExceptionHandler
