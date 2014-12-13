
unimplemented = -> "Cannot call pure virtual method"

class AbstractDatabase
	put: (table, id, data)->
		unimplemented()

	get: (table, id)->
		unimplemented()

	close: ->
		console.log("Nothing to close on database layer.")


module.exports = AbstractDatabase
