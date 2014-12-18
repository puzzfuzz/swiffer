var ItemView = require('src/common/item-view');
var template = require('./item-template.hbs');

module.exports = ItemView.extend({
	tagName: 'a',
	template: template,
	className: 'exceptions__item list-group-item',

	attributes: function () {
		return {
			href: '#exceptions/' + this.model.get('id')
		};
	},

	modelEvents: {
		'all': 'render'
	},

	onRender: function(){
		if (this.model.get('__isNew')) {
			this.$el.addClass('new');
			this.model.set({'__isNew':false},{silent:true});
		}
	}
});
