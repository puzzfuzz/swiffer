var ItemView = require('src/common/item-view');
var template = require('./item-template.hbs');
var _ = require('lodash');
var moment = require('moment');

module.exports = ItemView.extend({
	tagName: 'div',
	template: template,
	className: 'session__item panel panel-default',

	modelEvents: {
		'change': 'render'
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
		var self = this;
		var state = {};
		if (self.model.isActive()) {
			state.string = "ACTIVE";
			state.label = "success";
		} else if (self.model.isIdle()) {
			state.string = "IDLE";
			state.label = "warning";
		} else {
			state.string = "CLOSED";
			state.label = "danger";
		}
		return {
			stateString: state.string,
			stateLabel: state.label,
			duration: function(){
				var duration;
				if (self.model.isActive() || self.model.isIdle()) {
					duration = this.lastSeen - this.startTime;
				} else {
					duration = this.endTime - this.startTime;
				}
				if (duration) {
					return moment.duration(duration).humanize();
				}
				return "";
			}
		}
	}

});
