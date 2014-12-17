var Backbone = require('backbone');

var oldUrl = Backbone.Collection.url;

module.exports = Backbone.Collection.extend({
  constructor: function() {
    Backbone.Collection.apply(this, arguments);
    this._isNew = true;
    this.once('sync', function() {
      this._isNew = false;
    });
  },

  isNew: function() {
    return this._isNew;
  },

	url: function() {
		console.log('in model url');
		var url = oldUrl.apply(this, arguments);
		console.log('url...' + url);
		return "http://localhost:3000" + url
	}
});
