var Backbone = require('backbone');
Backbone.$ = require('jquery');
require('bootstrap');
require('backbone.syphon');
require('backbone-query-parameters');

var io = require('socket.io-client');

window.socket = io.connect();

require('backbone.iobind');
require('backbone.iosync');

//require('src/common/sync');

