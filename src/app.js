'use strict';

// init coffee so that we can include coffee modules..
require('coffee-script/register');

var Prompt = require('./lib/prompt'),
	express = require('express'),
	app = express(),
	exception = require('./controllers/c_exceptions'),
	config = require('../config');

app.use(function(req, res, next) {
	res.header("Access-Control-Allow-Origin", "*");
	res.header("Access-Control-Allow-Headers", "X-Requested-With");
	res.header("Access-Control-Allow-Headers", "Content-Type");
	next();
});
app.use(express.json());

app.post('/exception', exception.save, exception.send);

app.get('/exception', exception.get);

app.listen(config.port, function(){
	app.prompt.setStatusLines([app.prompt.clc.green("Listening on port " + config.port)]);
});

app.prompt = new Prompt();
app.prompt.setStatusLines([app.prompt.clc.blackBright("Starting up...")]);
console.log = function() {
	app.prompt.log.apply(app.prompt, arguments);

