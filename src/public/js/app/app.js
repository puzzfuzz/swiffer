
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
					root: "/swiffer/",
					pushState: true
				});
			});

			var socket = io.connect("/");

			socket.emit('api', 'listExceptions', 1234);
			socket.on('hello', function(exception){
				$("h1").addClass('loaded');
			});
			socket.on('exception', function(exception) {
				console.log(arguments);
				var panel = $('<div />', {
						'class': 'panel panel-danger'
					}),
					body = $('<div />', {
						'class': 'panel-body'
					});
				panel.append([
					'<div class="panel-heading">',
						'<h3 class="panel-title">',
							exception.errorMessage,
						'</h3>',
					'</div>'
				].join(''))
				.append(body);

				if (exception.who) {
					body.append('<div>'+exception.who+'</div>');
				}
				if (exception.clientTime) {
					body.append('<div>'+moment(exception.clientTime).format('M/D/YYYY HH:mm:ss.SSS')+'</div>');
				}
				if (exception.trace) {
					body.append('<pre>'+ exception.trace +'</pre>');
				}
				$('.exceptions_wrap').prepend(panel);
			});
		}
	});

	return App;
});
