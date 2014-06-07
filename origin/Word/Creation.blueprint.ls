encantador: \Word
incantation: \Creation
version: \0.1.0
abstract: true
verify: (obj) ->
	console.log "verify that someone can do something to this model"
reset: ->
	# "use strict"
	if typeof console is \undefined
		console = require \console

syllables:
	t_delta: (E, d) ->
		Moment = require \moment
		date = d.d_modified || d.d_modified
		E \span c: \t_delta data: time: t, Moment date .fromNow!

layout:
	creator:
		type: \string
		ref: \Mun
		required: true
		default: ->
			@session.current.mun