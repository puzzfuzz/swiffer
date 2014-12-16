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
				@logger.log 'Resuming stored session', sessID, data
				@sessions[sessID] = data
			.finally =>
				if !@sessions[sessID]
					@logger.log 'Starting session', sessID
					# there is not already a session by this id
					@sessions[sessID] =
						id: sessID
						startTime: +new Date()

					# Before poll, important because we don't want to send timerID
					@swiffer.db.put 'sessions', sessID, @sessions[sessID]

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


		@swiffer.db.put 'sessions', sessID, @sessions[sessID]
		@emit 'end', sessID

		

	poll: (sessID)=>
		if !@sessions[sessID]
			return @createSession sessID

		clearTimeout @sessions[sessID].timerID
		@sessions[sessID].timerID = setTimeout (=> @endSession(sessID)), 15000


module.exports = SessionManager
