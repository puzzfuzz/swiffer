AbstractDatabase = require './db'
AWS = require 'aws-sdk'
DOC = require 'dynamodb-doc'
Q = require 'q'
config = require '../../config'
_ = require 'underscore'

# http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/DynamoDB.html
#

AWS.config.update({region: config.region});

class DynamoDB extends AbstractDatabase
	_generatingTables: {}
	_knownTables: {}
	constructor: ->
		console.log "Hey look, dynamo did its init thing..."

		@dynamo = new AWS.DynamoDB()
		@client = new DOC.DynamoDB(@dynamo)


	buildTables: =>
		# delete it if it exists
		@dynamo.deleteTable { TableName: 'swiffer_events' }
		# once gone, recreate
		@dynamo.waitFor 'tableNotExists', { TableName: 'swiffer_events' }, @createEventTable

	checkTable: (table, isList)->
		if @_knownTables[table]
			return @_knownTables[table]

		deferr = Q.defer()
		@_knownTables[table] = deferr.promise

		@dynamo.describeTable { TableName: "swiffer_#{table}" }, (err, data)=>
			if err == null
				return deferr.resolve()

			console.log err
			if err.code == "ResourceNotFoundException"
				@generateTable table, isList
				@dynamo.waitFor 'tableExists', { TableName: "swiffer_#{table}" }, =>
					@_generatingTables[table] = false
					console.log "#{table} definitely exists."
					deferr.resolve()

		deferr.promise

	generateTable: (table, isList)->
		if @_generatingTables[table]
			return

		@_generatingTables[table] = true
		try
			schema = require "../schema/#{table}"
		catch e
			schema = 
				AttributeDefinitions: [{
					AttributeName: 'id'
					AttributeType: 'S'
				}]
				KeySchema: [{
					AttributeName: 'id'
					KeyType: 'HASH'
				}]
			if isList
				schema.AttributeDefinitions.push
					AttributeName: 'bucket'
					AttributeType: 'S'
				schema.KeySchema = [{
					AttributeName: 'bucket'
					KeyType: 'HASH'
				}, {
					AttributeName: 'id'
					KeyType: 'RANGE'
				}]


		if !schema.ProvisionedThroughput
			schema.ProvisionedThroughput =
				ReadCapacityUnits: 5
				WriteCapacityUnits: 5
		
		schema.TableName = "swiffer_#{table}"

		@dynamo.createTable schema, ->
			console.log "Table has been created! swiffer_#{table}"
		

	put: (table, id, data, isList)=>
		deferr = Q.defer()

		@checkTable(table, isList).then =>
			data.id = ""+id

			@client.putItem {
				TableName: "swiffer_#{table}"
				Item: data
			}, @createCallback deferr

		deferr.promise

	get: (table, id, isList)->
		deferr = Q.defer()

		@checkTable(table, isList).then =>
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

	# right
	pushList: (table, bucket, value)->
		deferr = Q.defer()

		@checkTable(table, true).then =>
			value.id = ""+value.id
			value.bucket = ""+bucket

			@client.putItem {
				TableName: "swiffer_#{table}"
				Item: value
			}, @createCallback deferr

		deferr.promise

	popList: (table, bucket, id)->
		return @get table, bucket, id, true

	# left
	unshiftList: (table, bucket, value)->
		@pushList table, bucket, value

	shiftList: (table, bucket, id)->
		@popList table, bucket, id

	getList: (table, bucket)->
		deferr = Q.defer()

		params =
			TableName: "swiffer_#{table}"
			KeyConditions: [
				@client.Condition "bucket", "EQ", ""+bucket
			]
		@client.query params, @createCallback deferr

		deferr.promise

	setList: (table, bucket, list)->
		unimplemented()

	# utility
	createCallback: (deferr)->
		return (err, data)->
			if err
				deferr.reject err
			else
				if data.Item
					data = data.Item
				else if data.Items
					data = data.Items
				# else
					# return deferr.reject {message: "Not found"}
				deferr.resolve data

module.exports = DynamoDB
