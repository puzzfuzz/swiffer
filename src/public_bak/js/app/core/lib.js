/**
 * Convenience extensions to core Backbone Objects
 */
define(['../../../.', 'backbone', 'underscore','moment',
],
function($, Backbone, _) {

	$.extend(Backbone.View.prototype, {
		renderTo: function(selector) {
			this.$el.appendTo(selector);
			this.render();

			this.redelegateEvents();

			return this;
		},
		redelegateEvents: function() {
			this.undelegateEvents();
			this.delegateEvents();

			return this;
		},
	});

});
