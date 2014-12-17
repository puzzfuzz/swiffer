// Place third party dependencies in the lib folder
//
// Configure loading modules from the lib directory,
// except 'app' ones, 
requirejs.config({
	"baseUrl": "/js/app",
	urlArgs: '_=' + (new Date()).getTime(),
	"paths": {
		"jquery":       "../lib/jquery.min",
		"socket.io":    "/socket.io/socket.io",
		"backbone":     "../lib/backbone-min",
		"underscore":   "../lib/underscore-min",
		"moment":       "../lib/moment",
		"marionette":   "../lib/marionette/backbone.marionette",
		"bootstrap":    "/bootstrap/js/bootstrap",
		"coreapp":      "core/coreapp",
		"lib":          "core/lib",
	},
	shim: {
		jquery: {
			exports: 'jQuery'
		},
		backbone: {
			deps: ['jquery'],
			exports: 'Backbone'
		}
	}
});

// Load the main app module to start the app
//requirejs(["app/main"]);

require([

	// Load our app module and pass it to our definition function
	'app',
	'lib'
], function(App) {
	// The "app" dependency is passed in as "App"
	App.start();
});