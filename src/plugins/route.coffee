_ = require 'underscore'
express = require 'express'
bodyParser = require 'body-parser'

class RouterHandler
	api:
		'route:read': 'getRoute'

	constructor: (@logger, @swiffer, @events)->
		@router = express.Router()

		@router.use bodyParser.json()
		@router.post '/route', @save


	getRoute: (data, callback)->
		if !data.id
			callback 'id parameter required', null
		@swiffer.db.getList "routes", data.id
			.catch (err)->
				console.log err
				callback err, null
			.then (data)->
				callback null, (_(data).sortBy (value, i)=> i)

	save: (req, res, next)=>
		routes = _.clone(req.body)

		routes.id = routes.clientTime

		@swiffer.db.pushList "routes", routes.session, routes
			.catch (err)->
				console.log "Error pushing routes!", err

		data = 
			name: 'route:create'
			data: routes

		@events.emit 'io', data
		@events.emit 'axon', data

		#emit exception as a session event
		data =
			name: 'session/' + routes.session + ":route"
			data: routes

		@events.emit 'io', data


		res.status(200).json({ error: null })


module.exports = RouterHandler
