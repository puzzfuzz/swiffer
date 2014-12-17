define([
	'../../.',
	'underscore',
	'backbone',
	'coreapp'
], function($, _, Backbone, App){

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


	App.Router = Backbone.Router.extend({
		routes: {
			// Define some URL routes
//			'/projects': 'showProjects',
//			'/users': 'showUsers',
//
			'exception/:id': 'showException',

			// Default
			'*actions': 'defaultAction'
		},

		initialize : function(){
//			var app_router = new AppRouter;

//			app_router.on('showProjects', function(){
//				// Call render on the module we loaded in via the dependency array
//				// 'views/projects/list'
//				var projectListView = new ProjectListView();
//				projectListView.render();
//			});
//			// As above, call render on our loaded module
//			// 'views/users/list'
//			app_router.on('showUsers', function(){
//				var userListView = new UserListView();
//				userListView.render();
//			});
//			app_router.on('', function(actions){
//				// We have no matching route, lets just log what the URL was
//				console.log('No route:', actions);
//			});
//			Backbone.history.start();
		},

		showException: function(id) {
			console.log("Trying to show this exception", id);

			$(".exceptions_wrap").empty();
			App.API('getException', id).done(drawException);
		},

		defaultAction: function(actions) {
			console.log('No route:', actions);
			$(".exceptions_wrap").empty();
			App.API('listExceptions').done(function(list) {
				_(list).each(drawException);
			});
		}
	});

	return App;
});