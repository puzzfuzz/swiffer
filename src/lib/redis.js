'use strict';

var redis = require('redis');
var client = redis.createClient();

console.log("Creating Redis client!");

client.on('error', function(err){
	console.log(err);
});
client.on('end', function(err){
	console.log("REDIS HATH DIED?");
});

module.exports = client;
