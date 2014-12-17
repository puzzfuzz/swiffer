
define([ 'jquery', 'underscore', 'backbone', 'marionette', 'moment',
//	'core/socket',
	'bootstrap'
], function($, _, Backbone, Marionette, moment){
	var _d = {};

	var CoreApp = Marionette.Application.extend({
		initialize : function(){
			require(['core/socket'], function(){
				App.Socket.init();
			});

			// Pass in our Router module and call it's initialize function
			require(['window'], function() {
//				_d.router = App.router = new App.Router();
				_d.window = App.window = new App.Views.Window({
					model: App.user
				});
				_d.window.renderTo($("#mainCanvas").empty());
			});

			require(['router'], function(Router){
				console.log('starting...');
				new Router();
				Backbone.history.start({
					root: "/swiffer/",
					pushState: true
				});
			});
		},
		Views: {},
		Models: {}
	});

	var App = new CoreApp();

	return App;
});
