clc = require 'cli-color'
readline = require 'readline'
EventEmitter = require('events').EventEmitter
config = require '../../config'
util = require 'util'
fs = require 'fs'

class Prompt extends EventEmitter
	constructor: (@swiffer)->
		@clc = clc
		@rl = readline.createInterface
			input: process.stdin
			output: process.stdout
			completer: (line, callback)=>
				if line.indexOf("/loadModule") == 0 and line.length > 10
					fs.readdir "#{__dirname}/../plugins/", (err, files)=>
						if err
							@log err
							return callback err

						lines = for file in files
							"/loadModule #{i = file.indexOf('.'); file.substr 0, (if i > 0 then i else file.length) }"
						return callback null, [lines, line]

				else if line.indexOf("/unloadModule") == 0 and line.length > 12
					modStart = line.substr(13)

					if !@swiffer.module
						return callback null, [[], line]

					availableModules = for own module of @swiffer.module.modules when module.indexOf(modStart) is 0
						module

					lines = for module in availableModules
						"/unloadModule #{module}"
					return callback null, [lines, line]

				else
					completions = ['/e', '/restart', '/loadModule', '/unloadModule']
					hits = completions.filter (c)-> c.indexOf(line) == 0

					callback null, [ (if hits.length then hits else completions), line]


		@statusLines = [clc.blackBright 'No status']

		@rl.setPrompt(config.prompt, config.prompt.length)

		@rl.on 'line', (msg)=>
			@pause()
			@clearLines(@statusLines.length+1)
			@_write config.prompt
			@_write msg
			@println()
			msg = msg.trim()
			@prompt()
			@resume()

			if msg.length > 0 
				@emit 'line', msg

		@prompt()


	clearLines: (count)->
		if (!count)
			count = 1
		for i in [1..count]
			@_write clc.up(1)
			@_write '\u001b[0G'+'\u001b[2K'
	pause: ->
		@rl.pause()
		@cpos = @rl.cursor
	resume: ->
		if (@rl.output.cursorTo)
			@rl.output.cursorTo config.prompt.length + @cpos
		@rl.cursor = @cpos
		@rl.resume()
	setStatusLines: (lines)->
		@pause()
		@clearLines(@statusLines.length)
		@statusLines = lines
		@prompt()
		@resume()

	prompt: =>
		@printStatusLine()
		@rl.prompt()

	log: =>
		@pause()
		# put in a new line for the output
		@_write '\u001b[0G'+'\u001b[2K'
		@clearLines(@statusLines.length)

		@_log msg for msg in arguments
		@println()

		@prompt()
		@resume()

	printStatusLine: =>
		for line in @statusLines
			@_write '\u001b[0G'+'\u001b[2K'
			@_write line
			@println()

	_log: (msg)->
		if typeof msg != "string" then msg = util.inspect(msg)
		@_write msg
		@_write ' '
	println: ->
		process.stdout.write '\n'
	_write: (data)->
		process.stdout.write data

module.exports = Prompt
