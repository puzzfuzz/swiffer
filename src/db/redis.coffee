redis = require 'redis'
AbstractDatabase = require './db'
Q = require 'q'


# client = redis.createClient()
# client.quit()

class RedisDatabase extends AbstractDatabase
	constructor: ->
		@client = redis.createClient()

	put: (table, id, data)->
		deferr = Q.defer()
		@client.hset id, table, JSON.stringify(data), @createCallback(deferr)

		deferr.promise

	get: (table, id)->
		deferr = Q.defer()
		@client.hget id, table, @createCallback(deferr)

		deferr.promise

	close: ->
		@client.quit()
		@client = null


module.exports = RedisDatabase
