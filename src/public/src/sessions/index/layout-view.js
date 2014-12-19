var LayoutView = require('src/common/layout-view');
var template = require('./layout-template.hbs');
var _ = require('lodash');

module.exports = LayoutView.extend({
	template: template,
	className: 'session session--index container'
});
