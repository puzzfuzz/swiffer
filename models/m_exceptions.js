'use strict';

var redis = require('../lib/redis');
var broadcast = require('../lib/broadcast');

/**
 * Save exception to database
 * @param {Array} exception
 * @param {Function} callback
 */
exports.save = function(exception, callback){
	redis.lpush('exceptions', JSON.stringify(exception), function(err){
		if (err) return callback(err, null);
		callback(null, null);
	});
};

/**
 * Trim down the redis list
 */
exports.trim = function() {
	redis.ltrim('exceptions', 0, 9);
};

/**
 * Send out exceptions to the broadcaster
 * @param {Array} exception
 * @param {Function} callback
 */
exports.send = function(exception, callback) {
	broadcast.send(exception);
	callback(null, null);
};

/**
 * Get exceptions from redis
 * @param {Function} callback
 */
exports.get = function(callback) {
	redis.lrange('exceptions', 0, -1, function(err, data){
		if (err) return callback(err, null);
		callback(null, data.map(JSON.parse));
	});
};