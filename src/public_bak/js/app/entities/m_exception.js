define([ 'jquery', 'backbone', 'underscore', 'app',
], function ( $, Backbone, _, App ) {

	App.Models.Exception = Backbone.Models.extend({

		defaults: function () {
			var defaults = this._super("defaults", arguments);
			$.extend(true, defaults, {
				display_name: '',
				include_global_partners: '0'
			});
			return defaults;
		},

		initialize: function ( data, options ) {
			this._super('initialize', arguments);
		},

		saveData: function () {
			var data = this.toJSON();

			return {
				attr_image: 				data.attributes.image,
				attr_idle_logout: 			data.attributes.idle_logout,
				// attr_company_name: 			data.attributes.company_name,
				// attr_company_address: 		data.attributes.company_address,
				// attr_main_contact_info: 	data.attributes.main_contact_info,
				// attr_description: 			data.attributes.description,
				// attr_web_site: 				data.attributes.web_site,
				// attr_category: 				data.attributes.category,

				name: 						data.name,
				disabled: 					data.disabled,
				// cost: 						data.cost,
				// visibility:					data.visibility,
				// whitelist_ids: 				data.whitelist_ids,
				// locked_publisher_id: 		data.locked_publisher_id,

				display_name: 				data.display_name && data.display_name.length > 0 ? data.display_name : Constants.NULL,
				swx_enabled: 				data.swx_enabled,
				include_global_partners: 	data.include_global_partners
			};
		},

		listCampaigns: function() {
			var id = this.get('id');
			debugger;
			var List = App.Models.Collection.extend({
				model: App.Models.Campaign,
				readURL: function() {
					return id + "/" + App.Models.Campaign.noun + '?related=brands';
				}
			});

			var list = new List();
			list.fetchAll();
			return list;
		},

	});

	return App.Models.Advertiser;

});