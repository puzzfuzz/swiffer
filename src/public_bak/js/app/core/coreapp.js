/**
 * Core App baseline and generic functionality
 */
define(['jquery',
	'backbone', 'marionette', 'underscore',
	'moment',
	'lib'
],
function($, Backbone, Marionette, _) {
	var CoreApp = Marionette.Application.extend({
		initialize: function(options) {
			console.log(options.container);
		}
	});

	var App = new CoreApp({container: '#app'});

	$.extend(App, {
		Views: {},
		Models: {}
	});

	return App;
});
