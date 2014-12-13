_ = require 'underscore'
express = require 'express'
bodyParser = require 'body-parser'

class ExceptionHandler
	constructor: (@logger, @swiffer, @events)->
		@logger.log "Exception handler constructor is running!!"
		@router = express.Router()

		@router.use bodyParser.json()

		@router.post '/exception', @save, @send

		# @swiffer.app.use @router


		@events.on 'connection', (socket)=>
			@swiffer.db.list 'events'
				.then (data)=>
					socket.emit 'exception', JSON.parse(exception) for own id, exception of data

			# socket.emit 'hello', {from: 'exception', to:'yours truely'}
			# model.get (err, data)=>
			# 	if (err)
			# 		return
			# 	data.forEach (exception) =>
			# 		socket.emit 'exception', exception

	save: (req, res, next)=>
		exception = _.clone(req.body)

		@swiffer.db.put 'events', exception.clientTime, exception
			.finally ->
				console.log arguments

		data = 
			name: 'exception'
			data: exception

		@events.emit 'io', data
		@events.emit 'axon', data

		next()
		# model.save exception, (err)=>
		# 	if (err)
		# 		return res.json(503, { error: true })
		# 	model.trim()

	send: (req, res, next)=>
		@logger.log req.body
		exception = _.clone(req.body)
		res.status(200).json({ error: null })

	unload: ->
		@router.routes = {}


module.exports = ExceptionHandler
