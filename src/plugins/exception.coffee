_ = require 'underscore'
express = require 'express'
bodyParser = require 'body-parser'

class ExceptionHandler
	constructor: (@logger, @swiffer, @events)->
		@logger.log "Exception handler constructor is running!!"
		@router = express.Router()

		@router.post '/exception', @save, @send

		# @swiffer.app.use @router

		@events.on 'socket:listExceptions', (socket)=>
			@swiffer.db.listWhere 'events', { name: 'exception' }
				.catch (err)->
					socket.error err
				.then (data)->
					socket.reply _(data).sortBy (value, i)=> i

		@events.on 'socket:getException', (socket, id)=>
			@swiffer.db.get 'events', id
				.catch (err)->
					socket.error err
				.then (value)->
					socket.reply value

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
