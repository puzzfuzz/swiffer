_ = require 'underscore'
express = require 'express'
bodyParser = require 'body-parser'

class ExceptionHandler
	api:
		'issue:read': 'getIssue'

	constructor: (@logger, @swiffer, @events)->
		@logger.log "Issue handler constructor is running!!"
		@router = express.Router()

#		issues are read-only, rolled up exceptions
#		@router.post '/issue', @save, @send

	getIssue: (data, callback)=>
		console.log "is this thing on?", arguments
#		if data?.id # if there's an ID then we fetch
#			@swiffer.db.get 'issues', data.id
#			.catch (err)->
#					callback err, null
#			.then (value)->
#					callback null, value
#		else # otherwise we just read
		@swiffer.db.list 'exceptions'
			.catch (err)->
				console.log 'Error', err
				callback((err.message || err), null)
			.then (data)->
				data = _(data)
				.chain()
				.groupBy 'errorMessage'
				.map (value, key)->
					console.log('running issue mapper')
					m = _(value).max (val) -> val.clientTime
					{ message: key, exceptions: value, recent: m.clientTime}
				.value()
				callback null, data



#		For now issues are read-only, rolled up exceptions
#	save: (req, res, next)=>
#		exception = _.clone(req.body)
#
#		exception.id = exception.clientTime
#
#		@swiffer.db.put 'exceptions', exception.id, exception
#
#		data =
#			name: 'exception:create'
#			data: exception
#
#		@events.emit 'io', data
#		@events.emit 'axon', data
#
#		#emit exception as a session event
#		data =
#			name: 'session/' + exception.session + ":exception"
#			data: exception
#
#		@events.emit 'io', data
#
#		next()

	send: (req, res, next)=>
		@logger.log req.body
		exception = _.clone(req.body)
		res.status(200).json({ error: null })

	unload: ->
		@router.routes = {}


module.exports = ExceptionHandler
