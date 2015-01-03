_ = require 'underscore'
util = require '../lib/requestUtils'




module.exports =
	categorize: (req, res, next) ->
		###
  		Request url may have Ids in it, so lets find the object space and replace the specific ID w/ an object name to group by
  		i.e.
  			http://mysite.com/api/6000000000123/ -> http://mysite.com/api/<user_id>

  		NOTE: we are INTENTIONALLY manipulating the passed-in request obj directly
		###

		if req?.body?.url

			#urls may contain CSRF tokens like: http://mysite.com/api/<some_id>/?__token=ABC123d4$1234567890$abcdef12...
			# replace any for cleaner classifying
			req.body.url = util.scrubCSRFToken req.body.url
			#find any ids present in the url and replace them with strings representing the object type
			req.body.url = util.replaceIdsWithObjectType req.body.url

		next()

