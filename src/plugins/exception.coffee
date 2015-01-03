_ = require 'underscore'
express = require 'express'
bodyParser = require 'body-parser'

class ExceptionHandler
	api:
		'exception:read': 'getException'

	constructor: (@logger, @swiffer, @events)->
		@logger.log "Exception handler constructor is running!!"
		@router = express.Router()

		@router.post '/exception', @save, @send

	getException: (data, callback)=>
		console.log "is this thing on?", arguments
		if data?.id # if there's an ID then we fetch
			@swiffer.db.get 'exceptions', data.id
				.catch (err)->
					callback err, null
				.then (value)->
					callback null, value
		else # otherwise we just read
			@swiffer.db.list 'exceptions'
				.catch (err)->
					console.log 'Error', err
					callback((err.message || err), null)
				.then (data)->
					callback null, (_(data).sortBy (value, i)=> i)

	save: (req, res, next)=>
		exception = _.clone(req.body)

		exception.id = exception.clientTime

		@swiffer.db.put 'exceptions', exception.id, exception

		data = 
			name: 'exception:create'
			data: exception

		@events.emit 'io', data
		@events.emit 'axon', data

		#emit exception as a session event
		data =
			name: 'session/' + exception.session + ":exception"
			data: exception

		@events.emit 'io', data

		next()

	send: (req, res, next)=>
		@logger.log req.body
		exception = _.clone(req.body)
		res.status(200).json({ error: null })

	unload: ->
		@router.routes = {}


module.exports = ExceptionHandler
