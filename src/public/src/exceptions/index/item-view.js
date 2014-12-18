var ItemView = require('src/common/item-view');
var template = require('./item-template.hbs');
var _ = require('lodash');

module.exports = ItemView.extend({
	tagName: 'div',
	template: template,
	className: 'exceptions__item panel panel-default',

//	attributes: function () {
//		return {
//			href: '#exceptions/' + this.model.get('id')
//		};
//	},

	modelEvents: {
		'all': 'render'
	},

//	onBeforeRender: function() {
//		if (this.model.get('__isNew')) {
//			this.$el.addClass('collapse');
//		}
//	},

	onRender: function(){
		if (this.model.get('__isNew')) {
//			setTimeout(function(){this.$el.collapse('show')}, 1000);

			this.model.set({'__isNew':false},{silent:true});
		}
	},

	onAttach: function() {
		var self = this,
			timeout = (this.model.collection ? this.model.collection.indexOf(this.model) : 0) * 150;
		_.delay(function(){self.$el.addClass('added');}, timeout);
		console.log('onAttach called');
	}

});
