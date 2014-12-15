redis = require 'redis'
AbstractDatabase = require './db'
Q = require 'q'
_ = require 'underscore'

# client = redis.createClient()
# client.quit()

class RedisDatabase extends AbstractDatabase
	constructor: ->
		@client = redis.createClient()

	put: (table, id, data)->
		deferr = Q.defer()
		@client.hset table, id, JSON.stringify(data), @createCallback(deferr)

		deferr.promise

	get: (table, id)->
		deferr = Q.defer()
		@client.hget table, id, @createCallback(deferr, JSON.parse)

		deferr.promise

	list: (table)->
		deferr = Q.defer()
		@client.hgetall table, @createCallback(deferr, (data)->
			_(data).map (d)-> JSON.parse d
			)

		deferr.promise


	close: ->
		@client.quit()
		@client = null


module.exports = RedisDatabase
