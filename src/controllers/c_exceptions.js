'use strict';


var _ = require('underscore');
var model = require('../models/m_exceptions');

/**
 *	Send exception to model to be saved
 */
exports.save = function(req, res, next) {
	var exception = _.clone(req.body);
	model.save(exception, function(err) {
		if (err) return res.json(503, { error: true });
		next();
		model.trim();
	});
};

/**
 *	Send exception to pub/sub socket in model
 */
exports.send = function(req, res, next) {
	var exception = _.clone(req.body);
	model.send(exception, function(err) {
		if (err) return res.json(503, { error: true });
		res.json(200, { error: null });
	});
};

/**
 * Get 10 exception from model
 */
exports.get = function(callback) {
	model.get(function(err, data) {
		data = _(data).reverse();
		callback(err, data);
	});
};