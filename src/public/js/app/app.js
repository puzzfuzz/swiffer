
define([ 'jquery', 'underscore', 'backbone', 'coreapp', 'router', 'socket.io', 'moment'
], function($, _, Backbone, App, Router, io, moment){
	var _d = {};

	$.extend(App, {
		initialize : function(){
			// Pass in our Router module and call it's initialize function
			require(['router', 'window'], function() {
				_d.router = App.router = new App.Router();
				_d.window = App.window = new App.Views.Window({
					model: App.user
				});
				_d.window.renderTo($("#mainCanvas").empty());

				Backbone.history.start({
					root: "/"
				});
			});

			var socket = io.connect("http://localhost:1337");

			socket.on('exception', function(exception){
				var $exception = $('<div>'+exception.errorMessage+'</div>');
				if (exception.who) {
					$exception.append('<div>'+exception.who+'</div>');
				}
				if (exception.when) {
					$exception.append('<div>'+moment(exception.when).format('M/D/YYYY HH:mm:ss.SSS')+'</div>');
				}
				if (exception.trace) {
					$exception.append('<pre>'+ exception.trace +'</pre>');
				}
				$('.exceptions_wrap').prepend($exception);
			});
		}
	});

	return App;
});
