/**
 * Convenience extensions to core Backbone Objects
 */
(function($, Backbone) {

	var _remove = Backbone.View.prototype.remove;

	$.extend(Backbone.View.prototype, {
		getTemplateData: function() {
			var data = {},
				state;
			if (this.model) {
				$.extend(data, this.model.toJSON());
			}
			if (this.stateModel) {
				state = this.stateModel.toJSON();
				$.extend(data, {
					stateModel: state ///@@@ still using both
				});

				if (!data.state) {
					// only create the blocker if we don't have a state value
					if (Object.defineProperty) {
						Object.defineProperty(data, 'state', {
							get: function () {
								throw new Error("Do not use state in templates. Use stateModel instead!");
							},
							set: function(value) {
								// This is called when a subclass edits the data.state before the template. We remove the error condition and return it to a normal variable
								// we also lock it as a normal variable, there is not really a good reason for this..
								Object.defineProperty(data, 'state', {
									value: value,
									writable: true,
									configurable: false
								});
								return value;
							},
							// we do this so we can redefine it later
							configurable: true
						});
					}
				}
			}

			return data;
		},
		render: function() {
			var data, state;

			data = this.getTemplateData();
			// even if we use custom data getter we still might need state data to decide which template to use
			if (this.stateModel) {
				state = this.stateModel.toJSON();
			}

			if (state && state.state && this[state.state + '_template']) {
				this.$el.html(this[state.state + '_template'](data));

			} else if (this.template) {
				this.$el.html(this.template(data));
			}


			this.redelegateEvents();

			return this;
		},
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
		remove: function() {
			var self = this,
				stack = new Error().stack,
				cid = self.cid;

			if (this.isRemoved) {
				console.warn("This view was removed twice!", this.render.stack);
				debugger;
				return;
			}

			// first clean everything up
			_remove.apply(this, arguments);
			this.$el.remove();
			$(document).off('.' + cid);
			$(window).off('.' + cid);

			this.undelegateEvents();
			this.stopListening();

			$.each(this, function(name, val) {
				if (!self.hasOwnProperty(name)) { return; }
				if (name === "_superCallObjects") { return; }
				if (name === "cid") { return; }

				if (self[name] && self[name] instanceof Backbone.View && !self[name].isRemoved && typeof self[name].remove === 'function') {
					console.warn("[GC] Should this view", cid, "have removed its sub-view", name, "?");
				}
				self[name] = null;
				delete self[name];
			});
			if (this.model) {
				this.model = null;
			}
			if (this.collection) {
				this.collection = null;
			}

			this.isRemoved = true;

			this.render = function() {
				// render should never be called after remove
				console.log(stack);
				debugger; //jshint ignore:line
			};
			this.render.stack = stack;

		},
	});
})(jQuery, Backbone);