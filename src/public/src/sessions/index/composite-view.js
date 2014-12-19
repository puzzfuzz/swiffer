var _ = require('lodash');
var CompositeView = require('src/common/composite-view');
var Collection = require('src/common/collection');
var ItemView = require('./item-view');
var template = require('./composite-template.hbs');

module.exports = CompositeView.extend({
	template: template,
	className: 'session session--index container',

	initialize: function(options) {
		this.models = options.collection.models;
//		this.state.start = (options.page - 1) * this.state.limit;
	},

	childView: ItemView,
	childViewContainer: 'div.list-group',

	onBeforeRender: function() {
		this.onBeforeAddChild = function(){};
	},

	onRender: function(){
		this.onBeforeAddChild = this.newSessionAdded;
	},

	newSessionAdded: function(sessionView) {
		this.$childViewContainer.prepend(sessionView.$el);
		sessionView.onAttach();
	},
});
