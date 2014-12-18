express = require 'express'
EventEmitter = require('events').EventEmitter
_ = require 'underscore'

class SessionManager extends EventEmitter
	api:
		'session:read': 'getSession'

	constructor: (@logger, @swiffer, @events)->
		@sessions = {}
		@router = express.Router()

		@router.post '/poll', (req, res, next)=>
			# reply right away
			res.status(200).json({ error: null })

			sessID = req.body.session

			if @sessions[sessID] and req.body.lastIdle
				@sessions[sessID].lastIdle = req.body.lastIdle

			@poll req.body.session

	emitEvent: (type, data)->
		data = _.clone data

		if data.timerID
			delete data.timerID

		socketData = 
			name: "session:#{type}"
			data: data

		@events.emit 'io', socketData

	getSession: (data, callback)->
		if data?.id # if there's an ID then we fetch
			@swiffer.db.get 'sessions', id
				.catch (err)->
					socket.error err
				.then (value)->
					socket.reply null, value
		else # otherwise we just read
			@swiffer.db.list 'sessions'
				.catch (err)->
					callback err
				.then (data)->
					callback null, _(data).sortBy (value, i)=> i

	createSession: (sessID)=>
		@swiffer.db.get 'sessions', sessID
			.then (data)=>
				# add the reconnect event
				data.reconnect = [] if !data.reconnect
				data.reconnect.push [ data.lastSeen, +new Date() ]

				@sessions[sessID] = data
			.finally =>
				if @sessions[sessID]
					@logger.log 'Resuming stored session', sessID, @sessions[sessID]
				else
					@logger.log 'Starting session', sessID
					# there is not already a session by this id
					@sessions[sessID] =
						id: sessID
						startTime: +new Date()

				@emit 'start', sessID
				@poll sessID, true
				@emitEvent 'create', @sessions[sessID]


	endSession: (sessID)=>
		@logger.log 'Closing session', sessID

		# clean
		sess = @sessions[sessID]
		delete sess.timerID
		delete @sessions[sessID]

		# extend
		sess.endTime = +new Date()
		@swiffer.db.getList "routes:#{sessID}"
			.then (routes)->
				sess.routes = _(routes).chain()
								.pluck 'route'
								.unique()
								.value()
			.finally =>
				@swiffer.db.put 'sessions', sessID, sess
				@emitEvent 'update', sess


		@storeSession sessID
		@emit 'end', sessID

		

	poll: (sessID, silent)=>
		if !@sessions[sessID]
			return @createSession sessID

		clearTimeout @sessions[sessID].timerID
		@sessions[sessID].timerID = setTimeout (=> @endSession(sessID)), 15000
		@sessions[sessID].lastSeen = +new Date()

		@storeSession sessID
		if !silent
			@emitEvent 'update', @sessions[sessID]


	storeSession: (sessID, data)=>
		data = @sessions[sessID] if !data
		data = _.clone data

		delete data.timerID if data

		@swiffer.db.put 'sessions', sessID, data


module.exports = SessionManager
