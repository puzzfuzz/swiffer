'use strict';

var axon = require('axon');
var socket = axon.socket('pub');

socket.bind(1338);

/**
 * Send a exception to the publish socket
 * @param {Object} obj
 */
exports.send = function(obj) {
	socket.send(obj);
};