//var Backbone = require('backbone');
//var $ = require('jquery');
//var _ = require('lodash');
//
//var apiEndpoint = "http://localhost:3000";
//console.log('using custom sync');
//
//var methodMap = {
//	'create': 'POST',
//	'update': 'PUT',
//	'patch':  'PATCH',
//	'delete': 'DELETE',
//	'read':   'GET'
//};
//
//// Throw an error when a URL is needed, and none is supplied.
//var urlError = function() {
//	throw new Error('A "url" property or function must be specified');
//};
//
//module.exports = Backbone.sync = function(method, model, options) {
//	var type = methodMap[method];
//
//	console.log('in custom sync');
//
//	// Default options, unless specified.
//	_.defaults(options || (options = {}), {
//		emulateHTTP: Backbone.emulateHTTP,
//		emulateJSON: Backbone.emulateJSON
//	});
//
//	// Default JSON-request options.
//	var params = {type: type, dataType: 'json'};
//
//	// Ensure that we have a URL.
//	if (!options.url) {
//		params.url = _.result(model, 'url') || urlError();
//		if (params.url.indexOf(/http/) === -1) {
//			params.url = apiEndpoint + params.url;
//		}
//	}
//
//	// Ensure that we have the appropriate request data.
//	if (options.data == null && model && (method === 'create' || method === 'update' || method === 'patch')) {
//		params.contentType = 'application/json';
//		params.data = JSON.stringify(options.attrs || model.toJSON(options));
//	}
//
//	// For older servers, emulate JSON by encoding the request into an HTML-form.
//	if (options.emulateJSON) {
//		params.contentType = 'application/x-www-form-urlencoded';
//		params.data = params.data ? {model: params.data} : {};
//	}
//
//	// For older servers, emulate HTTP by mimicking the HTTP method with `_method`
//	// And an `X-HTTP-Method-Override` header.
//	if (options.emulateHTTP && (type === 'PUT' || type === 'DELETE' || type === 'PATCH')) {
//		params.type = 'POST';
//		if (options.emulateJSON) params.data._method = type;
//		var beforeSend = options.beforeSend;
//		options.beforeSend = function(xhr) {
//			xhr.setRequestHeader('X-HTTP-Method-Override', type);
//			if (beforeSend) return beforeSend.apply(this, arguments);
//		};
//	}
//
//	// Don't process data on a non-GET request.
//	if (params.type !== 'GET' && !options.emulateJSON) {
//		params.processData = false;
//	}
//
//	// Pass along `textStatus` and `errorThrown` from jQuery.
//	var error = options.error;
//	options.error = function(xhr, textStatus, errorThrown) {
//		options.textStatus = textStatus;
//		options.errorThrown = errorThrown;
//		if (error) error.apply(this, arguments);
//	};
//
//	// Make the request, allowing the user to override any Ajax options.
//	var xhr = options.xhr = Backbone.ajax(_.extend(params, options));
//	model.trigger('request', model, xhr, options);
//	return xhr;
//};
//
