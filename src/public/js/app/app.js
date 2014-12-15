
define([ 'jquery', 'underscore', 'backbone', 'coreapp', 'router', 'moment',
	'core/socket'
], function($, _, Backbone, App, Router, moment){
	var _d = {};

	$.extend(App, {
		initialize : function(){
			App.Socket.init();
			// Pass in our Router module and call it's initialize function
			require(['router', 'window'], function() {
				_d.router = App.router = new App.Router();
				_d.window = App.window = new App.Views.Window({
					model: App.user
				});
				_d.window.renderTo($("#mainCanvas").empty());

				Backbone.history.start({
					root: "/swiffer/",
					pushState: true
				});
			});
		}
	});

	return App;
});
