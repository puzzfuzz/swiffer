define([
	'jquery',
	'underscore',
	'backbone',
	'coreapp'
], function($, _, Backbone, App){
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
		},

		defaultAction: function(actions) {
			console.log('No route:', actions);
		}
	});

	return App;
});