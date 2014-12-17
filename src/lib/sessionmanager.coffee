EventEmitter = require('events').EventEmitter
_ = require 'underscore'

class SessionManager extends EventEmitter
	constructor: (@logger, @swiffer)->
		@sessions = {}

	getSession: (sessID)->
		return @sessions[sessID]

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
				@poll sessID


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


		@storeSession sessID
		@emit 'end', sessID

		

	poll: (sessID)=>
		if !@sessions[sessID]
			return @createSession sessID

		clearTimeout @sessions[sessID].timerID
		@sessions[sessID].timerID = setTimeout (=> @endSession(sessID)), 15000
		@sessions[sessID].lastSeen = +new Date()

		@storeSession sessID

	storeSession: (sessID, data)=>
		data = @sessions[sessID] if !data
		data = _.clone data

		delete data.timerID if data

		@swiffer.db.put 'sessions', sessID, data


module.exports = SessionManager
