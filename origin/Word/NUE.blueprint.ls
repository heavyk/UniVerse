encantador: \Word
incantation: \NUE
type: \Fixed
presence: \Abstract
version: \0.1.0
poetry:
	Verse:
		Mun: \latest
		Aficionado: \latest
	Voice:
		Image: \latest


machina:
	order: <[header content footer]>
	parts:
		header: (E) -> E \div c: 'row header'
		content: (E) -> E \div c: 'row content'
		footer: (E) -> E \div c: 'row footer'
	states:
		uninitialized:
			onenter: ->
				step = @book.poem.get \nue
				console.log "entered NUE experience... your current step is:", step
				if step is false
					@transition '/done'
				else
					if typeof step is \undefined
						step = '/mun'
					@transition step



		'/mun':
			onenter: ->
				console.log "yay you're on step one..."
				console.log "this should be moved to eventListeners.transition to allow foa save in each case"
				# we don't have a mun yet, so we shouldn't save
				if @book.session.mun
					@exec \next
				# @book.poem.set \nue, @state
				# @book.poem.save!

			content: (E) ->
				window.mun_list = @poetry.Verse.Mun "where my dawgs at?" {persona: @book.session.persona}
				return
					* E \h3 null "Start by making a name for yourself..."
					# * E \div null "select a mun that you own:"
					* mun_list

			footer: (E) ->
				btn = E \a c: "pull-right btn #{if @book.session.mun => 'btn-success' else 'btn-default disabled'}" href: '/next', "step 2: make an appearance"
				@book.session.once \mun ->
					# debugger
					E.$ btn .removeClass \disabled .removeClass \btn-default .addClass \btn-success
				return btn

			'/next': ->
				@transition '/foto'

			'/prev': ->

		'/foto':
			onenter: ->
				console.log "yay you're on step one..."
				@book.poem.set \nue, @state
				@book.poem.save!

			content: (E) ->
				foto = @poetry.Voice.Image {mun: @book.session.mun}, {goto: \profile_foto}
				return
					* E \h3 null "Design your look..."
					* E \div null "[TODO: la subida de fotos aqui...]"
					* foto

			footer: (E) ->
				btn = E \a c: "pull-right btn btn-default not-disabled" href: '/afines', "step 2: select my afines"
				# @book.session.once \mun ->
				# 	# debugger
				# 	E.$ btn .removeClass \disabled .removeClass \btn-default .addClass \btn-success
				return
					* E \div c: \col-xs-6,
							E \a c: 'btn btn-default' href: '/mun', "back to step one"
					* E \div c: \col-xs-6, btn

		'/afines':
			onenter: ->
				console.log "yay you're on step two now..."
				@book.poem.set \nue, @state
				@book.poem.save!

			content: (E) ->
				# aficiones = @poetry.Verse.Aficionado "categories of things I might like:" {mun: @book.session.mun}
				aficiones = E \p null "TODO: [list of aficiones]"
				return
					* E \h3 null "My Afines"
					* E \div null "select some things that you like..."
					* E \div null aficiones

			footer: (E) ->
				btn = E \a c: "pull-right btn btn-default not-disabled" href: '/intro', "step 3: get started"
				return
					* E \div c: \col-xs-6,
							E \a c: 'btn btn-default' href: '/foto', "back to step one"
					* E \div c: \col-xs-6, btn

		'/intro':
			onenter: ->
				console.log "yay you're on step two now..."
				@book.poem.set \nue, @state
				@book.poem.save!

			content: (E) ->
				# window.MyMuns = @poetry.Verse.Mun "where my dawgs at?" {persona: @book.session.persona}
				return
					* E \h3 null "My Afines"
					* E \div null "select some things that you like..."
					* E \div null "TODO:"

			footer: (E) ->
				return
					* E \a c: 'btn btn-link' href: '/afines', "back to step two"
					* E \a c: 'pull-right btn btn-success' href: '/done', "Done!"

		'/done':
			onenter: ->
				console.log "yay you're done!"
				@book.poem.set \nue, @state

			content: (E) ->
				# window.MyMuns = @poetry.Verse.Mun "where my dawgs at?" {persona: @book.session.persona}
				return
					* E \h3 null "Congrats for making it this far!"
					* E \div null "TODO: some cool things about maybe learning about how the page works"

			footer: (E) ->
				return
					* E \div c: \col-xs-6,
							E \a c: 'btn btn-link' href: '/intro' "back to step three"
					* E \div c: \col-xs-6,
							E \a c: 'pull-right btn btn-default' href: '/_/profile', "take me to my profile"
							E \a c: 'pull-right btn btn-default' href: '/_/home', "take me to my home"

			'/_/home': -> @book.poem.transition \/home
			'/_/profile': -> @book.poem.transition \/profile


		# small_list:
		session_list:
			onenter: ->
				console.log "mun is ready!!!"

			render: (E) ->
				# who = "me!"
				E \div c: \media, # onclick: ~> (@emit \selected @id),
					E \a c: \pull-left href: @id,
						E \img c: <[img-rounded img-mun]> data: src: 'holder.js/32x32'
					E \div,
						onclick: ~>
							console.log "CLICK!", @key
							@book.session.exec 'mun.set', @key, (err, session) ->
								debugger
								console.log "set"
							# @emit \selected @
						c: \media-body,
						E \h4 c: \media-heading,
							E \a href: @id, @get \name
							E \small null,
								E \a href: '/selected', "activate"
						# E \h5 null, "los hombres son mejores que las mujeres"
						# "some sort of response here..."

			'/selected': (evt) ->
				console.log "you clicked on the link '/selected'!!!", evt
				@_el.style.background-color = '#ff0'

			'/unselected': (evt) ->

		new:
			onenter: ->
				console.log "we are a new something!", @_bp.namespace
				console.log "states", @states
				# setTimeout ~>
				# 	@transition \yay
				# , 3000

			render: (E) ->
				"TODO: this is a new mun!!!"

		yay:
			onenter: ->
				setTimeout ~>
					@transition \yayer
				, 1000
				# debugger

			render: (E) ->
				"omg sooo cool!"

		yayer:
			onenter: ->
				setTimeout ~>
					@transition \yay
				, 1000

			render: (E) ->
				"ho ho ho"

		'/mine':
			get: (query) ->
				query.bind \uid, req.user._key

			summon: (cb) ->
				cb uid: @book.session.mun

			render: (E, cursor) ->
				E \div c: \my-muns,
					cursor.each (d) ->
						@render \
				# ...

client:
	MyMuns: (api) -> api.'/mine'

api:
	client:
		'MyMuns.query': """
			FOR mun in Mun
			FILTER mun.uid == @uid
			RETURN mun
		"""
	# MyMuns: (req, res) ->
	# 	res.query.bind \uid, req.user._key
	# 	res.json res.query.execute!

# api:
# 	'/mine': (ajax) ->
# 		ajax {
# 			url: '...'
# 		}

# 	client:
# 		MyMuns: (ajax, cb) ->

# 		MunSearch: (params) ->


	server:
		MunSearch: (api) ->
			console.log "Mun.api!"
			api.get '/search', (req, res) ->
				console.log "we got a search!!"
	MyMuns: (api, app) ->
		path = app.get '/mine', (req, res) ->
			# muns = Muns.all req.user._key
			uid = req.user._key
			qry = @collection.byExample {uid}
			#muns.muns = _.map muns.muns, ((dd) ->
			#	console.log "got mun", dd
			#	console.dir dd
			#	dd.forClient!
			#), @
			res.json {
				muns: qry.toArray!
				#muns: _.map qry.toArray!, (dd) ->
					#console.log "mun:", dd
					#return new @modelPrototype dd
				#	return dd
				count: qry.count!
			}
		path.onlyIfAuthenticated 401, 'not logged in'

layout:
	uid:
		label: "Persona"
		type: \string
		required: true
		hidden: true
		oninfo: "the persona which owns this mun [hidden]"
	name:
		label: "Name"
		type: \string
		required: true
		onempty: "please type a name for your Mun"
		oninfo: "the name everyone will see"
	full_name:
		label: "Full Name"
		type: \string
		required: true
		default: ->
			"a function: "+@get(\name)
		onempty: "please type a name for your Mun"
		oninfo: "the name everyone will see"
	birthday:
		label: "birthday"
		type: \date
		onempty: "write anything you want here!!"
	img:
		label: "Profile Image"
		type: \Image
		default: \lala.jpg
		onempty: "please upload a foto for your Mun"
		oninfo: "the image everyone will see associated with your Mun"
