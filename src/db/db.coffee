Q = require 'q'

unimplemented = -> "Cannot call pure virtual method"

class AbstractDatabase
	put: (table, id, data)->
		unimplemented()

	get: (table, id)->
		unimplemented()

	close: ->
		console.log("Nothing to close on database layer.")

	# utility
	createCallback: (deferr)->
		return (err, data)->
			if err
				deferr.reject err
			else
				deferr.resolve data


module.exports = AbstractDatabase
