define(['../../.', 'underscore', 'backbone', 'coreapp'
], function($, _, Backbone, App){

	App.Views.Window =  Backbone.View.extend({
		template: _.template([
			'<nav class="navbar navbar-default" role="navigation">',
				'<div class="container-fluid">',
					'<div class="navbar-header">',
						'<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#nav_collapse">',
							'<span class="sr-only">Toggle navigation</span>',
							'<span class="icon-bar"></span>',
							'<span class="icon-bar"></span>',
							'<span class="icon-bar"></span>',
						'</button>',
						'<a class="navbar-brand" href="#">Swiffer</a>',
					'</div>',
					'<div class="collapse navbar-collapse" id="nav_collapse">',
						'<ul class="nav navbar-nav">',
							// '<li class="active"><a href="#">Link <span class="sr-only">(current)</span></a></li>',
						'<li class="dropdown">',
					// /navbar-collapse
					'</div>',
				// /container-fluid
				'</div>',
			// /navbar
			'</nav>',

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