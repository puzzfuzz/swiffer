AbstractDatabase = require './db'
AWS = require 'aws-sdk'
DOC = require 'dynamodb-doc'
Q = require 'q'
config = require '../../config'

# http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/DynamoDB.html

AWS.config.update({region: config.region});

class DynamoDB extends AbstractDatabase
	constructor: ->
		console.log "Hey look, dynamo did its init thing..."

		@dynamo = new AWS.DynamoDB()
		@client = new DOC.DynamoDB(@dynamo)

		@dynamo.waitFor 'tableNotExists', { TableName: 'events' }, @createEventTable

	createEventTable: =>
		console.log 'Trying to create a table!'
		@dynamo.createTable {
			TableName: 'events'
			AttributeDefinitions: [{
				AttributeName: 'id',
				AttributeType: 'S'
			}, {
				AttributeName: 'name',
				AttributeType: 'S'
			}, {
				AttributeName: 'data',
				AttributeType: 'M'
			}]
			KeySchema: [{
				AttributeName: 'id',
				KeyType: 'HASH'
			}]
			ProvisionedThroughput: {
				ReadCapacityUnits: 0
				WriteCapacityUnits: 0
			}
		}, ->
			console.log 'Table create!'
			console.log arguments
	put: (table, id, data)=>
		deferr = Q.defer()

		data.id = id if not data.id

		@client.putItem {
			TableName: table
			Item: data
		}, @createCallback deferr

		deferr.promise

	get: (table, id)->
		deferr = Q.defer()

		@client.getItem {
			TableName: table
			Key: 
				id: id
		}, @createCallback deferr

		deferr.promise


module.exports = DynamoDB
