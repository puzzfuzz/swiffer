var Backbone = require('backbone');
var Radio = require('backbone.radio');
var _ = require('lodash');

var flashesChannel = Radio.channel('flashes');

module.exports = Backbone.Model.extend({
  constructor: function() {
    Backbone.Model.apply(this, arguments);
    this.on('request', this.handleRequest);
    this.on('error', this.handleError);
  },

  handleRequest: function() {
    flashesChannel.command('remove', this.serverError);
    delete this.serverError;
  },

  handleError: function() {
    this.serverError = { type: 'danger', title: 'Server Error' };
    flashesChannel.command('add', this.serverError);
  },

  cleanup: function() {
    if (this.serverError) {
      flashesChannel.command('remove', this.serverError);
    }
    delete this.serverError;
    delete this.validationError;
  },

	//ensure change:attr gets triggered
	pushToArray: function(attr, value) {
		var t_array = _.clone(this.get(attr));
		t_array.push(value);

		this.set(attr, t_array);
	}
});
