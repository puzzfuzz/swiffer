Q = require 'q'
_ = require 'underscore'

unimplemented = -> "Cannot call pure virtual method"

class AbstractDatabase
	put: (table, id, data)->
		unimplemented()

	get: (table, id)->
		unimplemented()

	list: (table)->
		unimplemented()

	listWhere: (table, match)->
		deferr = Q.defer()

		@list table
			.catch (err)->
				deferr.reject err
			.then (arr)->
				arr = _(arr).where(match)
				deferr.resolve arr
					

		deferr.promise

	pushList: (table, bucket, value)->
		unimplemented()

	popList: (table, bucket)->
		unimplemented()

	unshiftList: (table, bucket, value)->
		unimplemented()

	shiftList: (table, bucket)->
		unimplemented()

	getList: (table, bucket)->
		unimplemented()

	setList: (table, bucket, list)->
		unimplemented()

	close: ->
		console.log("Nothing to close on database layer.")


	# utility
	createCallback: (deferr, parse)->
		return (err, data)->
			if err
				console.log err
				deferr.reject err
			else
				if parse
					try
						data = parse data 
					catch e
						console.log 'Error while parsing!', data, e
				deferr.resolve data


module.exports = AbstractDatabase
