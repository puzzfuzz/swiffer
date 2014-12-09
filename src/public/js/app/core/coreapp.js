/**
 * Core App baseline and generic functionality
 */
define(['jquery',
	'backbone', 'underscore',
	'moment',
	'lib'
],
function($, Backbone) {

	var App = window.App = {};

	//Allow the core App obj to play with BB events
	$.extend(App, Backbone.Events);

	$.extend(App, {
		Views: {},
		Models: {}
	});

	return App;

});
