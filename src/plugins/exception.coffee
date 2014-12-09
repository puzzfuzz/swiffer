_ = require 'underscore'
model = require '../models/m_exceptions'
express = require 'express'

class ExceptionHandler
	constructor: (@logger, @swiffer)->
		@logger.log "Exception handler constructor is running!!"
		@router = express.Router()

		@router.post '/exception', @save, @send
		@router.get '/exception', @get

		@swiffer.app.use @router

	save: (req, res, next)=>
		exception = _.clone(req.body)
		model.save exception, (err)=>
			if (err)
				return res.json(503, { error: true })
			next()
			model.trim()

	send: (req, res, next)=>
		exception = _.clone(req.body)
		#TODO move io into socket / broadcast module
		model.send @swiffer.io, exception, (err)=>
			if (err)
				return res.json(503, { error: true })
			res.json(200, { error: null })

	get: (req, res)->
		model.get (err, data)=>
			if (err)
				return res.json(503, { error: true })
			logger.log "This is running, at least! and restarts"
			res.status(200).json(data)

	unload: ->
		@router.routes = {}


module.exports = ExceptionHandler
