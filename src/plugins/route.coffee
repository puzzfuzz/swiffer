_ = require 'underscore'
express = require 'express'
bodyParser = require 'body-parser'

class RouterHandler
	constructor: (@logger, @swiffer, @events)->
		@router = express.Router()

		@router.use bodyParser.json()
		@router.post '/route', @save

		# @swiffer.app.use @router

		@events.on 'socket:listRoutes', (socket, session)=>
			@swiffer.db.getList "routes:#{session}"
				.catch (err)->
					socket.error err
				.then (data)->
					socket.reply _(data).sortBy (value, i)=> i


	save: (req, res, next)=>
		routes = _.clone(req.body)

		routes.name = 'route'

		@swiffer.db.pushList "routes:#{routes.session}", routes

		data = 
			name: 'route'
			data: routes

		@events.emit 'io', data
		@events.emit 'axon', data


module.exports = RouterHandler
