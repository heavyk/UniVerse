part: \poetry
name: \CommonJS
type \Abstract
returns: -> (module) -> @require module
module: ->
	module = {}
	exports = {}
	module.exports = exports
	_require = @require
	require = (module) ->
		_require module