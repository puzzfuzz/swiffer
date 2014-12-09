'use strict';

// init coffee so that we can include coffee modules..
require('coffee-script/register');

var Prompt = require('./lib/prompt'),
	express = require('express'),
	app = express(),
	server = require('http').Server(app),
	io = require('socket.io')(server),
	exception = require('./controllers/c_exceptions'),
	config = require('../config');

app.use(function(req, res, next) {
	res.header("Access-Control-Allow-Origin", "*");
	res.header("Access-Control-Allow-Headers", "X-Requested-With");
	res.header("Access-Control-Allow-Headers", "Content-Type");
	next();
});
app.use(express.json());
/**
 * Serve static assets out of public
 */
//app.use(express.static('/public'));

app.post('/exception', exception.save, exception.send);

app.get('/exception', exception.get);

app.get('/', function(req, res) {
	console.log("handling default root...");
//	res.sendfile('public/index.html');
});

app.listen(config.port, function(){
	app.prompt.setStatusLines([app.prompt.clc.green("Listening on port " + config.port)]);
});
//
//io.sockets.on('connection', function(socket){
//	exception.get(function(err, data){
//		if (err) return;
//		data.forEach(function(exception){
//			socket.emit('exception', exception);
//		});
//	});
//});

app.prompt = new Prompt();
app.prompt.setStatusLines([app.prompt.clc.blackBright("Starting up...")]);
console.log = function() {
	app.prompt.log.apply(app.prompt, arguments);
};
