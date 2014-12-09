define(['jquery', 'underscore', 'backbone', 'coreapp'
], function($, _, Backbone, App){

	App.Views.Window =  Backbone.View.extend({
		template: _.template([
			'<h1>Swiffer Error Sweeper</h1>',
			'<div class="exceptions_wrap"></div>'
		].join('')),

		events: {

		},

		initialize: function() {

		},

		render: function() {
			this.$el.html(this.template());

			return this;
		}
	});

	return App;

});