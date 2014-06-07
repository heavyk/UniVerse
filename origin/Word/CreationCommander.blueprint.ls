# some time in the future, expand this to show off contributions and stuff

encantador: \Word
incantation: \CreationCommander
version: \0.1.0
verify: (obj) ->
	console.log "verify that someone can do something to this model"
reset: ->
	# "use strict"
	if typeof console is \undefined
		console = require \console

poetry:
	t_delta: (E, d) ->
		Moment = require \moment
		date = @get \d_created || @get \d_modified
		E \span c: \t_delta data: time: t, Moment date .fromNow!

layout:
	mid:
		type: \string
		ref: \Mun
		required: true
		default: ->
			@session.current.mun
	title:
		type: \string
		default: 'co-creator'