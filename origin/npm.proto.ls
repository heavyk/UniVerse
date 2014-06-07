part: \poetry
name: \npm
type \Fixed
poetry:
	Npm: \latest
returns: -> @exports
this: (module) ->
	poetry:
		npm: @require \npm
machina:
	initialize: (module) ->
		Npm = @poetry.Npm
		# make sure it's a valid module name here
		Npm.exec \fetch module
	states:
		uninitialize