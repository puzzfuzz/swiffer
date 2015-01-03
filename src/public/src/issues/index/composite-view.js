var _ = require('lodash');
var CompositeView = require('src/common/composite-view');
var Collection = require('src/common/collection');
var ItemView = require('./item-view');
var template = require('./composite-template.hbs');

module.exports = CompositeView.extend({
	template: template,
	className: 'issues issues--index container',

	initialize: function(options) {
		this.models = options.collection.models;
	},

	childView: ItemView,
	childViewContainer: 'div.list-group',

//	collectionEvents: {
//		'change': 'render',
//		'before:add': 'onBeforeItemAdded'
//	},

	onBeforeRender: function() {
		//animate new issues being added to the top of the list, only after initial render
		this.onBeforeAddChild = function(){};
	},

	onRender: function(){
		//animate new issues being added to the top of the list, only after initial render
		this.onBeforeAddChild = this.newIssueAdded;
	},

	newIssueAdded: function(issueView) {
		this.$childViewContainer.prepend(issueView.$el);
		issueView.onAttach();
	},

	templateHelpers: function() {

	}
});
