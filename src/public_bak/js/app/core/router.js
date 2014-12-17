define([
	'jquery', 'underscore','backbone', 'marionette', 'app', 'moment'
], function($, _, Backbone, Marionette, App, moment){

	function drawException(exception) {
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
	}

	var SwifferRouter = Backbone.Marionette.AppRouter.extend({
		routes: {
			'exception/:id': 'showException',

			// Default
			'*actions': 'defaultAction'
		},

		initialize : function(){
			console.log('initializing router');
		},

		showException: function(id) {
			console.log("Trying to show this exception", id);

			$(".exceptions_wrap").empty();

//			App.API('getException', id).done(drawException);
		},

		defaultAction: function(actions) {
			console.log('default route:', actions);
			$(".exceptions_wrap").empty();

			App.request('api', 'listExceptions').done(function(list){
				_(list).each(drawException);
			});

//			App.API('listExceptions').done(function(list) {
//				_(list).each(drawException);
//			});
		}
	});

	return SwifferRouter;
});