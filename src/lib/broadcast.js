var config = require('../../config');
//var io = require('socket.io');

/**
 * Send a exception to the publish socket
 * @param {Object} obj
 */
exports.send = function(io, obj) {
	console.log('emitting exception... ');
	io.sockets.emit('exception', obj);
};