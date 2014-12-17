/**
 * Convenience extensions to core Backbone Objects
 */
(function($, Backbone, _) {

	/**
	 * Super!
	 *  Convenience extension of core BB objects with a super method to allow object extension
	 *  while retaining parent behavior.
	 */

	// The super method takes two parameters: a method name
	// and an array of arguments to pass to the overridden method.
	// This is to optimize for the common case of passing 'arguments'.
	function _super(methodName, args) {

		// Keep track of how far up the prototype chain we have traversed,
		// in order to handle nested calls to _super.
		if (this._superCallObjects === undefined) { this._superCallObjects = {}; }
		var currentObject = this._superCallObjects[methodName] || this,
			parentObject  = findSuper(methodName, currentObject),
			result;
		this._superCallObjects[methodName] = parentObject;

		try {
			result = parentObject[methodName].apply(this, args || []);
		} catch (e) {
			delete this._superCallObjects[methodName];
			throw e;
		}

		delete this._superCallObjects[methodName];
		return result;
	}

	_.each(["Model", "Collection", "View", "Router", "Object"], function(klass) {
		Backbone[klass].prototype._super = _super;
	});

})(jQuery, Backbone, _);
