var _ = require('lodash');
var CompositeView = require('src/common/composite-view');
var Collection = require('src/common/collection');
var RequestItemView = require('./item-view');
var template = require('./composite-template.hbs');

module.exports = CompositeView.extend({
	template: template,
	className: 'requests requests--index container',

	initialize: function(options) {
		this.models = options.collection.models;
	},

	childView: RequestItemView,
	childViewContainer: 'div.list-group',

	onBeforeRender: function() {
		//animate new issues being added to the top of the list, only after initial render
		this.onBeforeAddChild = function(){};
	},

	onRender: function(){
		//animate new issues being added to the top of the list, only after initial render
		this.onBeforeAddChild = this.newRequestAdded;
	},

	newRequestAdded: function(requestView) {
		this.$childViewContainer.prepend(requestView.$el);
		requestView.onAttach();
	},

	templateHelpers: function() {

	}
});
