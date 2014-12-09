// Place third party dependencies in the lib folder
//
// Configure loading modules from the lib directory,
// except 'app' ones, 
requirejs.config({
	"baseUrl": "js/app",
	"paths": {
		"app":          "app",
		"jquery":       "//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min",
		"socket.io":    "/socket.io/socket.io",
		"backbone":     "../lib/backbone-min",
		"underscore":   "../lib/underscore-min",
		"moment":       "../lib/moment",
		"coreapp":      "core/coreapp",
		"lib":          "core/lib",
		"router":       "router"
	}
});

// Load the main app module to start the app
//requirejs(["app/main"]);

require([

	// Load our app module and pass it to our definition function
	'app',
], function(App){
	// The "app" dependency is passed in as "App"
	App.initialize();
});