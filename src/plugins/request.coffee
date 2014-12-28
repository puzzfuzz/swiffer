_ = require 'underscore'
express = require 'express'
bodyParser = require 'body-parser'

class EventsHandler
	api:
		'request:read': 'getRequests'

	constructor: (@logger, @swiffer, @events)->
		@router = express.Router()

		@router.use bodyParser.json()
		@router.post '/request', @save


	getRequests: (data, callback)->
		@swiffer.db.getList "requests"
		.catch (err)->
				console.log err
				callback err, null
		.then (data)->
				callback null, (_(data).sortBy (value, i)=> i)

	save: (req, res, next)=>
		clientRequest = _.clone(req.body)

		clientRequest.id = clientRequest.clientTime
		console.log "saving request: %s",clientRequest.url

		@swiffer.db.pushList "requests", null, clientRequest
		.catch (err)->
				console.log "Error pushing requests!", err

		data =
			name: 'request:create'
			data: clientRequest

		@events.emit 'io', data
		@events.emit 'axon', data

		res.status(200).json({ error: null })


module.exports = EventsHandler
