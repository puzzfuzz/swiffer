'use strict';

var axon = require('axon');
var socket = axon.socket('pub');

socket.bind(1338);

/**
 * Send a badge to the publish socket
 * @param {Object} badge
 */
exports.send = function(badge) {
	socket.send(badge);
};