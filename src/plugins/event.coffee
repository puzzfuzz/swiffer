_ = require 'underscore'
express = require 'express'
bodyParser = require 'body-parser'

class EventsHandler
	api:
		'events:read': 'getRoute'

	constructor: (@logger, @swiffer, @events)->
		@router = express.Router()

		@router.use bodyParser.json()
		@router.post '/event', @save


	getRoute: (data, callback)->
		if !data.id
			callback 'id parameter required', null
		@swiffer.db.getList "events", data.id
		.catch (err)->
				console.log err
				callback err, null
		.then (data)->
				callback null, (_(data).sortBy (value, i)=> i)

	save: (req, res, next)=>
		events = _.clone(req.body)

		events.id = events.clientTime

		@swiffer.db.pushList "events", events.session, events
		.catch (err)->
				console.log "Error pushing routes!", err

		data =
			name: 'event:create'
			data: events

		@events.emit 'io', data
		@events.emit 'axon', data

		#emit exception as a session event
		data =
			name: 'session/' + events.session + ":event"
			data: events

		@events.emit 'io', data


		res.status(200).json({ error: null })


module.exports = EventsHandler
