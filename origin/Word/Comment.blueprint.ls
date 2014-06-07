
# make CreatedEdited as an abstract class
# make the Blueprint work rperly inside of arango
# ??? make Date as an abstract class (which has various funcs for relative time and shit)

encantador: \Word
incantation: \Comment
type: \Fixed
version: \0.1.1
embodies:
	* \Creation
	* \Timely
poetry:
	Word:
		'Mun': \latest
	# 'Media': \latest
reset: ->
	if typeof console is \undefined
		console = require \console
	muns = @blueprints.Mun.all!
	range = muns.length - 1

	console.log "count", count = @collection.count!
	for n til 100 - count
		mun_receiver = mun_sender = parseInt(Math.random!*range, 10)
		while mun_sender is mun_receiver
			mun_receiver = parseInt(Math.random!*range, 10)
		words = []
		#make_comment = (sender, receiver) ->
		for j til sc = 1 + Math.round(Math.random! * 3)
			# sentence
			for i til wc = 2 + Math.round(Math.random! * 30)
				words.push @random-word!
			words[*-1] += '.'
		console.log "inserting(#sc)(#wc): "+words.join ' '
		@collection.save {
			sender: muns[mun_sender]._key
			receiver: muns[mun_receiver]._key
			text: words.join ' '
		}

	#posts = @collection.byExample {sender: muns[mun_sender]._key}
	console.log "posts:", @collection.count!
	# @collection.save {
	# 	sender: muns[mun_sender]._key
	# 	receiver: muns[mun_receiver]._key
	# 	text: words.join ' '
	# }
api: (api, app) ->
	path = api.get '/profile/:id', (req, res) ->
		d = @collection.byExample receiver: req.get(\id)
		res.json d.toArray
	#path.onlyIfAuthenticated 401, 'not logged in'

phrases:
	render: (E, d) ->
		E \div null, "TODO"
		E \div c: \media,
			d.sender.render \img_link
			E \div c: \media-body,
				E \h4 c: \media-heading,
					d.sender.render \txt_link
					E \small null "commented..."
				d.text
layout:
	sender:
		type: \string #\ObjectId
		required: true
		ref: \Mun@latest
	receiver:
		type: \string #\ObjectId
		required: true
		ref: \Mun@latest
	text: # change tis over to pub/priv key
		type: \string
		required: true
	d_created:
		type: \Date@latest
		required: true
		default: -> Date.now!

machina:
	states:
		profile_list:
			onenter: ->
				console.log "mun is ready!!!"
				@book.session.on \mun (key) ~>
					if key is @key
						@_cE.$ @_el .addClass 'active'
				# debugger

			render: (E) ->
				E \div c: \media,
					@get \recipient .phrase \img_link #@render \img_link
					E \div c: \media-body,
						E \h4 c: \media-heading,
							@render \txt_link
							E \small null "commented..."
						"eres tan wapo!"`

			'/selected': (evt) ->
				console.log "you clicked on the link '/selected'!!!", evt
				# @_el.style.background-color = '#ff0'
				# $ @_el .addClass \active

			'/unselected': (evt) ->

			'/delete': ->
				@debug "gonna forget %s", @key
				@forget ->
					# debugger
					console.log "yay! deleted", &