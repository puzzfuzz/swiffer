var ItemView = require('src/common/item-view');
var template = require('./item-template.hbs');
var _ = require('lodash');
var moment = require('moment');

module.exports = ItemView.extend({
	tagName: 'div',
	template: template,
	className: 'requests__item panel panel-default',

	modelEvents: {
		'all': 'render'
	},

	onRender: function(){
		if (this.model.get('__isNew')) {
			this.model.set({'__isNew':false},{silent:true});
		}
	},

	onAttach: function() {
		var self = this,
			timeout = (this.model.collection ? this.model.collection.indexOf(this.model) : 0) * 150;
		_.delay(function(){self.$el.addClass('added');}, timeout);
	},

	templateHelpers: function() {

	}

});
