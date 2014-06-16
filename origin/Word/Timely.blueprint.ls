encantador: \Word
incantation: \Timely
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
		date = @get \d_created || @get \d_modified
		E \span c: \t_delta data: time: t, Moment date .fromNow!

layout:
	d_created:
		type: \Date@latest
		required: true
		default: -> Date.now!
	d_modified:
		type: \Date@latest