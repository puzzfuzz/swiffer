(function(window){
	/**
	 * Swiffer client-side script inclusion
	 */

	var _defaultOptions = function(){return {
		onerror: true,		//Automatically bind onerror handler
		apiRoot : null,     //REQUIRED - route to the Swiffer API server
		apiKey : null,      //REQUIRED - local API key for connecting to the Swiffer API server
		user: null,         //user ID to associate all events from this session with
		userName : null,    //user name to associate all events from this session with
		app : null,         //specifier for which app this event originated from; for reporting
		environment : null, //specifier for which environment this event originated from; for reporting: ex: "live", "dev", "test", etc.
		session : (new Date()).getTime(), //session identifier; defaults to current timestamp in milliseconds
		useSocket: false,   //boolean flag for whether to connect over socket or use traditional REST api
		socketURL: null,    //optional socket url to use; if none specified apiRoot will be used (only when useSocket === true)
		$: window.$,        //jQuery reference; defaults to standard window.$ - can be overridden on initialization
		requestTracker: true//track and time all ajax requests fired by the host app, allowing for client-side slow query tracking
	}},

	/**
	 * Cherry-picked underscore convenience methods
	 */
	// Is a given value an array?
	// Delegates to ECMA5's native Array.isArray
	isArray = Array.isArray || function(obj) {
		return toString.call(obj) === '[object Array]';
	},
	// Is a given variable an object?
	isObject = function(obj) {
		var type = typeof obj;
		return type === 'function' || type === 'object' && !!obj;
	},
	// Create a (shallow-cloned) duplicate of an object.
	clone = function(obj, deep) {
		if (deep) {
			return JSON.parse(JSON.stringify(obj));
		}
		if (!isObject(obj)) return obj;
		return isArray(obj) ? obj.slice() : extend({}, obj);
	},
	// Verbatim from underscore.js
	// Extend a given object with all the properties in passed-in object(s).
	extend = function(obj) {
		if (!isObject(obj)) return obj;
		var source, prop;
		for (var i = 1, length = arguments.length; i < length; i++) {
			source = arguments[i];
			for (prop in source) {
				if (hasOwnProperty.call(source, prop)) {
					obj[prop] = source[prop];
				}
			}
		}
		return obj;
	},

	/**
	 * Tests for required properties and throws an exception if any are unset
	 * @param {Object} obj object to check for required properties
	 * @param {Array} props array of required props to check for on the object
	 */
	requireProperties = function(obj, props) {
		var prop;
		for (var i = 0, length = props.length; i < length; i++) {
			prop = props[i];
			if (!obj[prop]) {
				throw new Exception("Error initializing Swiffer: " + prop + "is a required option.");
			}
		}
	},

	rpcgw = {
		apiRoot: null,
		apiKey: null,
		options: {
			apiRoot: null,
			apiKey: null,
		},
		init: function(options) {
			rpcgw.apiRoot = options.apiRoot;
			rpcgw.apiKey = options.apiKey;

			extend(rpcgw.options, options);

			delete rpcgw.options.apiRoot;
			delete rpcgw.options.apiKey;

			setInterval(function() {
				rpcgw.post('poll');
			}, 10000);

			return this;
		},
		post: function(path, data) {
			//is this a shallow or deep copy? does it matter?
			data = extend({}, rpcgw.options, data);
			data.apiKey = rpcgw.apiKey;
			data.clientTime = (new Date()).getTime();
			//flag request to be ignored by request tracker
			data.noTrack = true;

			return $.ajax({
				type: "POST",
				url: rpcgw.apiRoot + path,
				data: JSON.stringify(data),
				contentType: 'application/json'
			});
		},
		get: function(path, data) {
			//is this a shallow or deep copy? does it matter?
			data = extend({}, rpcgw.options, data);
			data.apiKey = rpcgw.apiKey;
			data.clientTime = (new Date()).getTime();
			//flag request to be ignored by request tracker
			data.noTrack = true;

			return $.ajax({
				type: "GET",
				url: rpcgw.apiRoot + path,
				data: JSON.stringify(data),
				contentType: 'application/json'
			});
		}
	},

	requestTrackers = {};

	var Swiffer = {
		api : null,
		initialized: false,
		init: function(options){
			var initProgress = $.Deferred();

			requireProperties(options, ['apiRoot', 'apiKey']);

			options.apiRoot = options.apiRoot.replace(/\/*$/, '/');
			Swiffer.options = extend(_defaultOptions(), options);
			Swiffer.initialized = true;

			if (Swiffer.options.onerror) {
				Swiffer.initOnError();
				// defensive against re-init
				delete Swiffer.options.onerror;
			}

			if (Swiffer.options.requestTracker) {
				Swiffer.initRequestTracker();
				// defensive against re-init
				delete Swiffer.options.requestTracker;
			}

			if (this.options.useSocket) {
				//TODO
				//connect socket
				//resolve promise once socket is connected
			} else {
				rpcgw.init(Swiffer.options);
				initProgress.resolve();
			}

			return initProgress;
		},

		initOnError: function(){
			(function(_onerror) {
				window.onerror = function(){
					if (_onerror) { _onerror.apply(this, arguments); }
					Swiffer.onError.apply(this, arguments);
				};
			}(window.onerror));
		},

		initRequestTracker: function() {
			if (Swiffer.options.$ && Swiffer.options.$.ajax) {
				(function(_ajax) {
					Swiffer.options.$.ajax = function(){
						var deff,
							//$.ajax signature is either (url, options) or (options[.url])
							options = isObject(arguments[0]) ? arguments[0] : arguments[1],
							requestUrl = (options && options.url ? options.url : arguments[0]);

						if (options.noTrack) {
							//pass through directly, don't track
							return _ajax.apply(this, arguments);
						}

						if (_ajax) { deff = _ajax.apply(this, arguments); }
						requestTrackers[requestUrl] = (new Date()).getTime();
						deff.always(function(){
							var requestTime = (new Date()).getTime() - requestTrackers[requestUrl];
							delete requestTrackers[requestUrl];
							console.log("request finished - time:%i url:%s", requestTime, requestUrl);
						});

						return deff;
					};
				}(Swiffer.options.$.ajax));
			}
		},

		exception: function(exception){
			return Swiffer.send('exception', exception);
		},

		send: function(api, data) {
			return rpcgw.post(api, data);
		},

		event: function(eventName, eventData) {
			return rpcgw.post('event', {
				eventName: eventName,
				eventData: eventData
			})
		},

		/**
		 * Mirrors native window.onerror signature, plus optional param to capture or throw exception.
		 *  Optionally, the most recent exception can be stored in localstorage w/ the @last_exception key, and be pulled from there
		 *
		 * @param errorMsg {String} Error message
		 * @param url {String} Url where error was raised
		 * @param lineNumber {Number} Line number where error was raised
		 * @param column {Number} Column number for the line where the error occurred (number) Requires Gecko 31.0
		 * @param e {Object} Error Object (object) Requires Gecko 31.0
		 * @param capture {Boolean} optional indicator if exception should be captured or thrown, defaults false (i.e. will throw)
		 */
		onError: function(errorMsg, url, lineNumber, column, e, capture) {
			var trace = null, exception;
			if (e && e.stack) {
				trace = e.stack;
			} else if (localStorage['last_exception']) {
				trace = localStorage['last_exception'];
				localStorage.setItem('last_exception', null);
			}

			exception = {
				errorMessage: errorMsg,
				url: url,
				lineNumber: lineNumber,
				column: column,
				e: e,
				trace: trace
			};

			Swiffer.exception(exception);

			return !!capture;
		}

	};

	window.Swiffer = Swiffer;

	return window.Swiffer;
})(window);
