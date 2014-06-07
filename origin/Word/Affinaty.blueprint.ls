
encantador: \Word
incantation: \Affinaty # this and the following are the path
type: \Fixed
version: \0.1.0 # this is like a tag
embodies:
	* \Creation
	* \Timely
poetry:
	Word:
		Mun: \latest
layout:
	name:
		type: \string
		required: true
	description:
		type: \string
		onempty: "please write a description"
	# TODO: add Affinaty todo items, language, etc.
machina:
	states:
		ready:
			onenter: ->
			render: (E) ->
				E \div c: \container,
					E \h1, c: \title, @get \name
					E \div, c: \description, @get \description
	# ...