AbstractDatabase = require './db'
AWS = require 'aws-sdk'
DOC = require 'dynamodb-doc'
Q = require 'q'
config = require '../../config'
_ = require 'underscore'

# http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/DynamoDB.html

AWS.config.update({region: config.region});

class DynamoDB extends AbstractDatabase
	constructor: ->
		console.log "Hey look, dynamo did its init thing..."

		@dynamo = new AWS.DynamoDB()
		@client = new DOC.DynamoDB(@dynamo)


	buildTables: =>
		# delete it if it exists
		@dynamo.deleteTable { TableName: 'swiffer_events' }
		# once gone, recreate
		@dynamo.waitFor 'tableNotExists', { TableName: 'swiffer_events' }, @createEventTable

	createEventTable: =>
		console.log 'Trying to create a table!'
		@dynamo.createTable {
			TableName: 'swiffer_events'
			AttributeDefinitions: [{
				AttributeName: 'id'
				AttributeType: 'S'
			}, {
				AttributeName: 'name'
				AttributeType: 'S'
			}]
			KeySchema: [{
				AttributeName: 'id'
				KeyType: 'HASH'
			}]
			GlobalSecondaryIndexes: [{
				IndexName: 'name-range'
				KeySchema: [{
					AttributeName: 'name'
					KeyType: 'HASH'
				}]
				Projection: {
					ProjectionType: 'KEYS_ONLY'
				}
				ProvisionedThroughput: {
					ReadCapacityUnits: 5
					WriteCapacityUnits: 5
				}

			}]
			ProvisionedThroughput: {
				ReadCapacityUnits: 5
				WriteCapacityUnits: 5
			}
		}, ->
			console.log 'Table create!'
			console.log arguments
	put: (table, id, data)=>
		deferr = Q.defer()

		data.id = ""+id

		@client.putItem {
			TableName: "swiffer_#{table}"
			Item: data
		}, @createCallback deferr

		deferr.promise

	get: (table, id)->
		deferr = Q.defer()

		@client.getItem {
			TableName: "swiffer_#{table}"
			Key: 
				id: ""+id
		}, @createCallback deferr

		deferr.promise

	list: (table)->
		deferr = Q.defer()

		@client.scan {
			TableName: "swiffer_#{table}"
		}, @createCallback deferr

		deferr.promise

	listWhere: (table, match)->
		deferr = Q.defer()

		@list table
			.catch deferr.reject
			.then (arr)=>
				arr = _(arr).where match
				deferr.resolve arr

		deferr.promise


	# utility
	createCallback: (deferr)->
		return (err, data)->
			if err
				deferr.reject err
			else
				if data.Item
					data = data.Item
				if data.Items
					data = data.Items
				deferr.resolve data

module.exports = DynamoDB
