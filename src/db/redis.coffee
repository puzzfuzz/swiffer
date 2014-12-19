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


	pushList: (table, bucket, value)->
		deferr = Q.defer()
		@client.rpush "#{table}:#{bucket}", JSON.stringify(value), @createCallback(deferr)

		deferr.promise

	popList: (table, bucket)->
		deferr = Q.defer()
		@client.rpop "#{table}:#{bucket}", @createCallback(deferr)

		deferr.promise

	unshiftList: (table, bucket, value)->
		deferr = Q.defer()
		@client.lpop "#{table}:#{bucket}", JSON.stringify(value), @createCallback(deferr)

		deferr.promise

	shiftList: (table, bucket)->
		deferr = Q.defer()
		@client.lpush "#{table}:#{bucket}", @createCallback(deferr)

		deferr.promise

	getList: (table, bucket)->
		deferr = Q.defer()
		@client.lrange "#{table}:#{bucket}", 0, -1, @createCallback(deferr, (data)->
				_(data).map (d)-> 
					d = JSON.parse d if d != "[object Object]"
					d
			)

		deferr.promise

	# setList: (table, list)->

	close: ->
		@client.quit()
		@client = null


module.exports = RedisDatabase
