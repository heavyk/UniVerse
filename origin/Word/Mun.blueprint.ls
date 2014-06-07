encantador: \Word # \Word@latest
incantation: \Mun
type: \Fixed
version: \0.1.0
embodies:
	* \Timely
poetry:
	Verse:
		Comment: \latest
		PerspectiveList: \latest
	Word:
		MySpace: \latest

verify: (obj) ->
	console.log "verify that someone can do something to this model"

reset: ->
	if typeof console is \undefined
		console = require \console
	hamsternipples = @users.get \hamsternipples
	MUNS = {}

	make_mun = ((data) ->
		id = @collection.name!+'/'+data._key
		unless data.uid
			data.uid = hamsternipples._key
		if @collection.exists id
			@collection.update id, data
		else @collection.save data
		#MUNS[data.name] = user
		# user.save
	).bind this
	make_mun {
		_key: '11'
		name: "kenny"
		full_name: "Kenneth Bentley"
	}
	make_mun {
		_key: '1155'
		name: "duralog"
		full_name: "flames of love"
	}
	make_mun {
		_key: '1111'
		name: "heavyk"
		full_name: "mechanic of the sequence"
	}
	make_mun {
		_key: '1234'
		name: "hamsternipples"
		full_name: "nips"
	}

# queries:
# 	mine: """
# 	FOR d IN Mun
# 		FILTER d.uid == @uid
# 		SORT d.d_created DESC
# 		RETURN d
# 	"""
# 	# this belongs in RelationShip bp
# 	search: """
# 	TODO
# 	"""


syllables:
	img_link: (E, d) ->
		E \a c: <[pull-left mun-link]> href: '/profile/'+@get(\_key),
			E \img c: <[img-thumbnail img-mun]> data: src: 'holder.js/64x64'
			if @get \is_you
				E \div c: \prox-box,
					E \span c: \prox s: 'background-color:\#f22;width:100%'
			else
				E \div c: \prox-box,
					E \span c: \prox s: 'background-color:\#722;width:40%'

	# preferences: (E, d) ->
	# 	console.log "welcome to Mun.profile"
	# 	E \div null,
	# 		E \h3, null, @get \name

	# profile: (E, d) ->
	# 	word = @
	# 	who = @get \name
	# 	id = @get \_id
	# 	E \div c: \row,
	# 		E \div, c: <[col-sm-4 col-lg-3 col-xl-2]>,
	# 			E \div c: <[panel panel-default]>,
	# 				E \div c: \panel-heading,
	# 					E \h3 c: \panel-title, @get(\name)
	# 				E \div c: \panel-body,
	# 					E \img c: <[img-rounded img-responsive]> data: src: 'holder.js/256x256'
	# 			E \div c: <[panel panel-default]>,
	# 				E \div c: \panel-heading,
	# 					E \h3 c: \panel-title, "actions"
	# 				E \div c: \panel-body,
	# 					E \ul c: <[nav nav-pills nav-stacked]>,
	# 						E \li null,
	# 							E \a href: "/message/#id", "Message"
	# 						E \li null,
	# 							E \a href: "/todo/do/something/for/#{who}", "something else here"
	# 		E \div, c: <[col-sm-8 col-lg-9 col-xl-10]>,
	# 			E \div c: <[panel panel-default]>,
	# 				E \div c: \panel-heading,
	# 					E \h3 c: \panel-title, "#{@get(\full_name)}'s comments"
	# 				E \div c: \panel-body,
	# 					# E \div c: <[alert alert-warning alert-dismissable]>,
	# 					# 	E \button type: \button c: \close data: dismiss: \alert
	# 					# 	E \p null, "this is some introductory text here..."
	# 					# 	E \button type: \button c: <[btn btn-primary]> data: dismiss: \alert, "Ok, got it.."
	# 					# @render \preferences
	# 					# @book.Verse.Comments d._key
	# 					# console.log "Comments" @, @book.Verse #.Comments

	# 					E \div null, ->
	# 						word.book.Verse.Comment.inst "profile"
	# 						# word.book.Verse.CommentList.inst "#{@get(\_key)}/received"
	# 						# word.book.Verse.Comment.inst "received/#{@id}"
	# 						# word.book.Voice.BasicForm.inst \comment
	# 						"TODO:  make this a list ... !!!"
	# 					E \div c: \media,
	# 						@render \img_link
	# 						E \div c: \media-body,
	# 							E \h4 c: \media-heading,
	# 								@render \txt_link
	# 								E \small null "commented..."
	# 							"eres tan wapo!"
	# 					#return "TODO: make a wall with comments"
	# 					#TODO: keep track of these alerts

machina:
	# queries:
	# 	reationships: ->
	# 		q = new Query """
	# 			FOR d in #{@collection.name}
	# 			FILTER d.uid1 == @uid
	# 			RETURN d._id
	# 		"""
	# 		q.bind_client \uid (book) -> book.session.mun
	# 		q.bind_server \uid (req) -> req.user._key

	# 	my_muns: ->
	# 		q = new Query """
	# 			FOR d in #{@collection.name}
	# 			FILTER d.uid == @uid
	# 			RETURN d._id
	# 		"""
	# 		q.bind_client \uid (book) -> book.session.mun
	# 		q.bind_server \uid (req) -> req.user._key
	states:
		# small_list:
		session_list:
			onenter: ->
				console.log "mun is ready!!!"
				@book.session.on \mun (key) ~>
					if key is @key
						@_cE.$ @_el .addClass 'active'
				# debugger

			render: (E) ->
				# this is a pretty lame hack...
				if @book.session.mun is @key
					E.$ @_el .addClass 'active'
				E \div c: \media, # onclick: ~> (@emit \selected @id),
					E \a c: \pull-left href: @id,
						E \img c: <[img-rounded img-mun]> data: src: 'holder.js/32x32'
					E \div,
						onclick: ~>
							console.log "CLICK!", @key
							# debugger
							@book.session.exec 'mun.set', @key, (err, session) ->
								# debugger
								console.log "set", session
							# @emit \selected @
						c: \media-body,
						E \h4 c: \media-heading,
							E \a href: @id, @get \name
							E \small null,
								E \a href: '/selected', "activate"
								E \a href: '/delete', "delete"
						# E \h5 null, (new Date!).toString!
						# E \p null "oenoienioenoen"
						# E \p null "oenoienioenoen"
						# E \p null "oenoienioenoen"
						# E \p null "oenoienioenoen"

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

		'/profile':
			render: (E) ->
				E \div c: \row,
					E \div, c: <[col-sm-4 col-lg-3 col-xl-2]>,
						# E \div null "the sidebar"
						# E \div null @book.session.mun
						E \div c: <[panel panel-default]>,
							E \div c: \panel-heading,
								E \h3 c: \panel-title, @get(\name)
							E \div c: \panel-body,
								E \img c: <[img-rounded img-responsive]> data: src: 'holder.js/256x256'
						E \div c: <[panel panel-default]>,
							E \div c: \panel-heading,
								E \h3 c: \panel-title, "actions"
							E \div c: \panel-body,
								E \ul c: <[nav nav-pills nav-stacked]>,
									E \li null,
										E \a href: "/message/[todo]", "Message"
									E \li null,
										E \a href: "/todo/do/something/for/[todo]", "something else here"
					E \div, c: <[col-sm-8 col-lg-9 col-xl-10]>,
						E \div c: <[panel panel-default]>,
							E \div c: \panel-heading,
								E \h3 c: \panel-title, "#{@get(\full_name)}'s comments"
							E \div c: \panel-body,
								# E \div c: <[alert alert-warning alert-dismissable]>,
								# 	E \button type: \button c: \close data: dismiss: \alert
								# 	E \p null, "this is some introductory text here..."
								# 	E \button type: \button c: <[btn btn-primary]> data: dismiss: \alert, "Ok, got it.."
								# @render \preferences
								# @book.Verse.Comments d._key
								# console.log "Comments" @, @book.Verse #.Comments


								@poetry.Verse.Comment "tell me something good!"
								#return "TODO: make a wall with comments"
								#TODO: keep track of these alerts

						# mun = @poetry.Word.Mun @book.session.mun, {
						# 	goto: '/profile'
						# }

						# mun.once \state:ready ->
						# 	debugger
						# "TODO: add the comments"
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
