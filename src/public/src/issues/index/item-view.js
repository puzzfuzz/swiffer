var ItemView = require('src/common/item-view');
var template = require('./item-template.hbs');
var _ = require('lodash');
var moment = require('moment');

module.exports = ItemView.extend({
	tagName: 'div',
	template: template,
	className: 'issues__item panel panel-default',

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
		console.log('onAttach called');
	},

	templateHelpers: function() {
		var exceptions = this.model.get('exceptions'),
			exceptionCount = exceptions.length,
			lastSeen = moment(this.model.get('recent')).format('MM/DD/YYYY HH:mm:ss.SSS'),
			users = _(exceptions).chain()
				.groupBy(function(ex){
					return ex.user || ex.userName;
				})
				.map(function(ex){
					//group by returns array of exceptions per user,
					// but we just want the unique user so pull the first dude form the list
					var ex = ex[0];
					return {
						user: ex.user,
						userName: ex.userName
					}
				})
				.value(),
			userCount = users.length;


		return {
			exceptions: exceptions,
			exceptionCount: exceptionCount,
			lastSeen: lastSeen,
			users: users,
			userCount: userCount
		}

	}

});
