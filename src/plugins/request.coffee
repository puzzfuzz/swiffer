_ = require 'underscore'
express = require 'express'
bodyParser = require 'body-parser'
#categories = require './requestCategories_base'
categories = require './requestCategories' #include custom categorizer

class RequestsHandler
	api:
		'request:read': 'getRequests'

	constructor: (@logger, @swiffer, @events)->
		@router = express.Router()

		@router.use bodyParser.json()
		@router.post '/request', categories.categorize, @save


	getRequests: (data, callback)->
		@swiffer.db.list "requests"
		.catch (err)->
				console.log err
				callback err, null
		.then (data)->
				callback null, (_(data).sortBy (value, i)=> i)

	save: (req, res, next)=>
		clientRequest = _.clone(req.body)

		id = clientRequest.url

		#check the db for any existing similar requests and roll up interesting data
		@swiffer.db.get "requests", id
			.then (data)=>

				requestToSave =
					id: id,
					url: clientRequest.url,
					time: [clientRequest.time],
					clientTime: clientRequest.clientTime,
					count: 1
				if data
					requestToSave.time = requestToSave.time.concat(data.time)
					requestToSave.count += data.count

				@swiffer.db.put "requests", requestToSave.id, requestToSave
				.catch (err)->
						console.log "Error pushing requests!", err

				data =
					name: 'request:create'
					data: requestToSave

				@events.emit 'io', data
				@events.emit 'axon', data

				res.status(200).json({ error: null })

module.exports = RequestsHandler
