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

	pushList: (table, value)->
		unimplemented()

	popList: (table)->
		unimplemented()

	unshiftList: (table, value)->
		unimplemented()

	shiftList: (table)->
		unimplemented()

	getList: (table)->
		unimplemented()

	setList: (table, list)->
		unimplemented()

	close: ->
		console.log("Nothing to close on database layer.")


	# utility
	createCallback: (deferr, parse)->
		return (err, data)->
			if err
				deferr.reject err
			else
				if parse
					try
						data = parse data 
					catch
						console.log data
				deferr.resolve data


module.exports = AbstractDatabase
