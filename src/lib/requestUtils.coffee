_ = require 'underscore'

idOffset = 1000000000000

digits = new RegExp()
digits.compile /\d+/g

csrf = new RegExp()
csrf.compile /__token=[0-9a-zA-Z$]*/g

objectPrefixes =
	'6': 	'user_id',
	'9': 	'image_id',
	'11':	'location_id',
	'39':	'beacon_id',
	'42':	'placement_id',
	'55': 'partner_id',
	'58': 'template_id',
	'60':	'experience_id',
	'61': 'creative_id',
	'77': 'dataframe_id',
	'84': 'campaign_id',

RequestUtils =
	scrubCSRFToken: (str) ->
		str.replace(csrf, '')

	findIdInString: (str) ->
		#find any digits in the string
		str.match digits

	findPrefix: (str) ->
		#find the digit prefix
		#	all our ids are number spaced w/ a knowable id offset, set above
		Math.floor parseInt(str)/idOffset

	replaceIdsWithObjectType: (str) ->
		#find any ids present in the string
		ids = RequestUtils.findIdInString str

		if ids
			#if the string has ids, find the matching object type and substitute it in
			_(ids).forEach (value) =>
				prefix = RequestUtils.findPrefix value
				objectType = objectPrefixes[prefix]
				if objectType
					str = str.replace value, objectType

		return str



module.exports = RequestUtils