EventEmitter = require('events').EventEmitter

class SessionManager extends EventEmitter
	constructor: (@logger, @swiffer)->
		@sessions = {}

	getSession: (sessID)->
		return @sessions[sessID]

	createSession: (sessID)=>
		@swiffer.db.get 'sessions', sessID
			.catch =>
				@logger.log 'Starting session', sessID
				# there is not already a session by this id
				@sessions[sessID] =
					id: sessID
					startTime: +new Date()

				# Before poll, important because we don't want to send timerID
				@swiffer.db.put 'sessions', sessID, @sessions[sessID]

			.then (data)=>
				@logger.log 'Resuming stored session', sessID
				@sessions[sessID] = data

			.finally =>
				@emit 'start', sessID
				@poll sessID


	endSession: (sessID)=>
		@logger.log 'Closing session', sessID

		@sessions[sessID].endTime = +new Date()
		delete @sessions[sessID].timerID

		@swiffer.db.put 'sessions', sessID, @sessions[sessID]
		@emit 'end', sessID

		delete @sessions[sessID]

	poll: (sessID)=>
		if !@sessions[sessID]
			return @createSession sessID

		clearTimeout @sessions[sessID].timerID
		@sessions[sessID].timerID = setTimeout (=> @endSession(sessID)), 30000


module.exports = SessionManager
