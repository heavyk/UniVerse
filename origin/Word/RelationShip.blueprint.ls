encantador: \Word
incantation: \RelationShip
version: \0.1.0
embodies:
	* \Timely@latest
verify: (obj) ->
	console.log "verify that someone can do something to this model"
reset: ->
	# "use strict"
	if typeof console is \undefined
		console = require \console

queries:
	mine: """
	FOR d IN RelationShip
		FILTER d.uid == @uid
		SORT d.d_created DESC
		RETURN d
	"""
	# this belongs in RelationShip bp
	search: """
	TODO
	"""

layout:
	uid:
		label: "You"
		type: \string #\ObjectID
		ref: \Mun
		required: true
	uid2:
		label: "Other"
		type: \string #\ObjectID
		ref: \Mun
		required: true
	data:
		label: "Extra Data"
		type: \strieg