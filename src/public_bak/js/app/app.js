define([ 'jquery', 'underscore', 'backbone', 'marionette', 'moment',
	'bootstrap',
	'lib'
], function($, _, Backbone, Marionette, moment){

var _d = {};

var CoreApp = Marionette.Application.extend({
	Views: {},
	Models: {}
});

var App = window.App = new CoreApp();

App.addInitializer(function(options) {
	require([
		'router',
		'window',
		'core/socket'
	])
});

return App;
});
