'use strict';

var express = require('express') ;
var app = express();
var exception = require('./controllers/c_exceptions');

app.use(function(req, res, next) {
	res.header("Access-Control-Allow-Origin", "*");
	res.header("Access-Control-Allow-Headers", "X-Requested-With");
	res.header("Access-Control-Allow-Headers", "Content-Type");
	next();
});
app.use(express.json());

app.post('/exception', exception.save, exception.send);

app.get('/exception', exception.get);

app.listen(1337, function(){
	console.log('Server is listening on port %d', 1337);
});