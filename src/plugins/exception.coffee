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


		@events.on 'socket:listExceptions', (socket)=>
		# @events.on 'connection', (socket)=>
			# @swiffer.db.list 'events'
			@swiffer.db.listWhere 'events', { name: 'exception' }
				.catch @logger.log
				.then (data)=>
					_(data).chain()
						.sortBy (value, i)=>
							i
						.each (value, i)=>
							socket.emit 'exception', value

		@events.on 'socket:getException', (socket, id)=>
			@swiffer.db.get 'events', id
				.then (value)->
					socket.emit 'exception', value

	save: (req, res, next)=>
		exception = _.clone(req.body)

		exception.name = 'exception'

		@swiffer.db.put 'events', exception.clientTime, exception

		data = 
			name: 'exception'
			data: exception

		@events.emit 'io', data
		@events.emit 'axon', data

		next()

	send: (req, res, next)=>
		@logger.log req.body
		exception = _.clone(req.body)
		res.status(200).json({ error: null })

	unload: ->
		@router.routes = {}


module.exports = ExceptionHandler
