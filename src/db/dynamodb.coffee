AbstractDatabase = require './db'
AWS = require 'aws-sdk'

class DynamoDB extends AbstractDatabase
	constructor: ->
		console.log "Hey look, dynamo did its init thing..."

		@dynamo = new AWS.DynamoDB()



module.exports = DynamoDB
