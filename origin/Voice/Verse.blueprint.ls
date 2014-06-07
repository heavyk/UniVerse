

# add font editor?
# https://github.com/mattlag/GLYPHR

# convert to rem instead of px for css
# https://bugsnag.com/blog/responsive-typography-with-rems

# mozilla brick (html components)
# https://hacks.mozilla.org/2014/03/custom-elements-for-custom-applications-web-components-with-mozillas-brick-and-x-tag/


encantador: \Verse
incantation: \Verse
type: \Mutable
version: \0.1.0
# embodies:
# 	* \Timely # this adds d_created/d_modified fields
# 	* \Creation # this adds creator fields
poetry:
	Verse:
		'Session': \latest
	Word:
		'Mun': \latest
		# 'Affinaty':
		# 	version: \latest
		# 	goto: \/splash
		#'Comment': \latest
# reset: ->
# 	name = @collection.name!
# 	@DB._drop name
# 	@DB._create name
# 	#@collection = @DB._collection name
# 	files = Fs.list "../uV/Blueshift/lib/Blueprints"

# api: (api, bp) ->
# 	path = api.get '/profile/:id' (req, res) ->
# 		@collection.byExample receiver: req.get \id
# 	path.pathParam \id, type: \string description: "the profile posts you'd like to get"

layout:
	quests:
		type: \object
		required: true
	description:
		type: \string
	params:
		type: \object





phrases:
	summary: (E, d) ->
		E \div c: \container,
			E \h2 c: \title, @get \name
			E \div c: \description, @get \name

	summary-xs: \sm # this is a link to show it will use the same version as the 'sm'
	# TODO: have the poetry send events to objects to re-render the views
	# TODO: when transitioning, store the phrases rendered to be updated/re-rendered (even if it's an array)
	summary-sm: (E, d) ->
		# a small version to be displayed in a small mobile display
		E \div c: \container,
			E \h2 c: \title, @get \name
			E \div c: \description, @get \name

machina:
	'extend.initialize': ->

		# name = opts.name
		# console.log "poem:", opts.name
		# console.log "wecome to poem #name", refs, opts
		#TODO: cake this render the top bar
		/*
		cE \a href: '?top-menu-toggle', c: \dropdown-toggle data: toggle: \dropdown,
			#cE \img c: <[img-rounded img-mun]> data: src: 'holder.js/32x32'
			cE \img c: <[img-rounded img-mun]> src: 'i/'+doc.get(\img)
			doc.get(\name)
			cE \b c: \caret
		*/
		# console.log "opts", opts
		# if typeof (poem = Poem._[name]) isnt \undefined
		# 	console.error 'this poem is already instantiated'
		# 	return poem

		# window = refs.window
		# doc = window.document
		# $ = window.$
		# cE = window.cE
		# aC = window.aC

		# TODO = (opts = {}) ->

		# cur_proto = name
		# cur_obj = \affinaty
		# routes = {}
		# var cur_watcher, cur_file
		console.log "this is interesting!", @state


		#lala = Poem

	order:
		* \header
		* \render
		* \footer
	router: (path, is_back) ->
		console.error "route", path, is_back
		window_href = window.location.href + ''
		window_href_base = window_href.substr 0, window_href.lastIndexOf '/'
		proto = cur_proto
		url_poem = cur_url_poem
		if ~path.indexOf window_href_base
			path = path.substr window_href_base.length
		else
			if ~path.indexOf "://"
				proto = path.split '://'
				if proto.length > 1
					[proto, path] = proto
				else
					proto = \http
					path = proto.0
			#[url_poem, path] = path.split '/'
			if (i = path.indexOf '/') > 0
				url_poem = path.substr 0, i
				path = path.substr i
			else if i is 0
				url_poem = cur_url_poem
				path = path
			else
				url_poem = path
				path = '/'

		querystring = ''
		if i = ~path.indexOf '?'
			querystring = path.slice i + 1
			path = path.slice 0, i

		console.log "proto:#{proto} url_poem:#{url_poem} path:#{path}"
		#Poem._[name].transition path, {path, proto, poem: url_poem}

		switch path
		| \/disconnected =>
			console.log "TODO: show disconnected thing..."
			refs.poem.emit \disconnected
			aC null, lala = cE \div c: 'modal-backdrop fade in'
			window.fsm.on \ready ->
				$ lala .remove!

	# cmds:


	states:
		uninitialized:
			header: (E) ->
				poetry = @poetry
				poem = @
				console.log "rendr header", poem
				E \div c: <[navbar navbar-inverse navbar-fixed-top]>,
					E \div c: \something,
						E \a c: \navbar-brand href: '/',
							# <brand>
							if typeof poem.brand is \function then E.call(poem, E)
							else if poem.brand then poem.brand
							else "[TODO: editable brand name]"
							# </brand>
						btn_menu = E \button,
							c: \navbar-toggle
							type: \button
							onclick: ->
								btn_menu.blur!
							data:
								toggle: \collapse
								target: '.navbar-responsive-collapse',
							E \span c: \icon-bar
							E \span c: \icon-bar
							E \span c: \icon-bar
						E \div c: <[navbar-collapse collapse navbar-responsive-collapse]>,
							E \ul c: <[nav navbar-nav]>,
								# <navbar>
								#E \li, null,
								# E \a href: '/home', "Home"
								#E \li null,
								# E \a href: '/profile', "Profile"
								# </navbar>
							E \ul c: <[nav navbar-nav]>,
								# <navbar>
								E \li, null,
									E \a href: '/home', "Home"
								E \li null,
									E \a href: '/profile', "Profile"
								# </navbar>
							E \ul c: <[nav navbar-nav navbar-right]> s: 'display:none', (el) ->
								poetry.on \auth ->
									E.$ el .show!
								poetry.on \noauth ->
									E.$ el .hide!
								E \li c: \dropdown,
									E \a href: '?top-menu-toggle', c: \dropdown-toggle data: toggle: \dropdown,
										E \img c: <[img-rounded img-mun]> data: src: 'holder.js/32x32'
										E \span c: \mun-name, (el) ->
											poetry.on \auth (session) ->
												el.innerHTML = session.user
											"..."
										E \b c: \caret
									E \ul c: \dropdown-menu,
										E \li null,
											E \a href: '/preferences', "Preferences"
										E \li null,
											E \a href: '/preferences', "another thing"
										E \li c: \divider
										E \li null,
											E \a href: '/logout', "logout"

			render: (E) ->
				E \div id: \content, "loading..."

			poem_footer: (E) ->
				E \div c: 'navbar navbar-inverse navbar-fixed-bottom', "[footer TODO]" # ...

		invalidstate:
			render: (E) ->
				E \div c: \todo data: todo: "new_page_editor", "invalid state: TODO: make a new page editor"
				#TODO: make it search for the data after loading the element
				#TODO: make an external interface for the todos

		# ready:
		# 	onenter: ->
		# 		# this should actually just call the router on
		# 		console.log "Wer'e ready"
		# 		poem = @
		# 		poem.transition @load_path || '/', {poem: Poem.poetry.poem, mun: Poem.poetry.mun, path: '/'}
		# 		#if no sessin, go to login page

		ready:
			onenter: ->
				# this should actually just call the router on
				path = @path || '/'
				console.log "We're ready", path #, {poem: Poem.poetry.poem, mun: Poem.poetry.mun, path}
				@transition path, {poem: @poetry.poem, mun: @poetry.mun, path}
				#if no sessin, go to login page
		'/':
			onenter: ->
				console.log "poetry:" #, @poetry
				# unless @book.session.current
				# 	@transition \login

			render: (E) ->
				console.log 'RENDER!!', @, typeof Poem
				debugger
				return
				draw_feed_entry = (who) ->
					E \div c: \media,
						E \a c: \pull-left href: '/profile/augusto',
							E \img c: <[img-rounded img-mun]> data: src: 'holder.js/64x64'
						E \div c: \media-body,
							E \h4 c: \media-heading,
								E \a href: '/profile/'+who, who
								E \small null "opina sobre..."
							E \h5 null, "los hombres son mejores que las mujeres"
							"some sort of response here..."

				E \div, c: \row,
					E \div, c: <[col-sm-4 home-sidebar]>,
						E \div c: <[panel panel-default]>,
							E \div c: \panel-heading, "Sidebar"
							E \div c: \panel-body,
								E \p null,
									E \a href: '/preferences', "preferences"
								#Poem.poetry.session.list_muns
								for id in [11, 1155, 1234, 1111]
									E \p null,
										E \a href: "/profile/#id", "link '#id'"
					E \div, c: <[col-sm-8 home-feed]>,
						#E \h1, null, "Home page"
						E \div c: <[panel panel-default]>,
							E \div c: \panel-heading, "the feed..."

							E \div c: \panel-body, ->
								return "TODO: user.view \\feed"

								for i in [\lala \jaja \jose \oooo]
									draw_feed_entry "alguien \#"+i

								E \div c: \media,
									E \a c: \pull-left href: '/profile/jenny',
										E \img c: <[img-rounded img-mun]> data: src: 'holder.js/64x64'
									E \div c: \media-body,
										E \h4 c: \media-heading,
											E \a href: '/profile/jenny', "Jenny"
											E \small null "opina sobre..."
										E \h5 null, "se conoce a su misma"
										"some sort of response here..."

								E \div c: \media,
									E \a c: <[pull-left mun-link]> href: '/profile/jenny',
										E \img c: <[img-thumbnail img-mun]> data: src: 'holder.js/64x64'
										#E \div c: \prox-box,
										# E \span c: \prox s: 'background-color:\#722;width:40%'
									E \div c: \media-body,
										E \h4 c: \media-heading,
											E \a href: '/profile/jenny', "Jenny"
											E \small null "opina sobre..."
										E \h5 null, "se conoce a su misma"
										"some sort of response here..."

								E \div c: \media,
									E \a c: <[pull-left mun-link]> href: '/profile/jenny',
										E \img c: <[img-thumbnail img-mun]> data: src: 'holder.js/64x64'
										#E \div c: \prox-box,
										# E \span c: \prox s: 'background-color:rgb(110,223,38);width:90%'
									E \div c: \media-body,
										E \h4 c: \media-heading,
											E \a href: '/profile/jenny', "Jenny"
											E \small null "opina sobre..."
										"eres tan wapo!"


		'/about_us':
			onenter: ->

			render: (E) ->
				E \div c: \container,
					E \h2 null, "About Us"
					E \p null, "some about us text goes here..."


		'/home':
			onenter: ->
				# if necessary, so some init

			render: (E) ->

		'/profile/:id':
			onenter: (url) ->
			render: (E, url) ->
				E \div null, "someone else's profile, id: ", url.params.id

		'/profile':
			render: (E, url) ->
				console.log "Poem.profile!!", @
				if session = @book.session.current
					mun = @poetry.Word.Mun.inst id = @book.session.current.mun
					#console.warn "Word", @poetry.Word.Mun.inst
					#console.log "Verse", @poetry.Verse
					console.log "mun", mun
					console.log "mun.states", mun.states
					mun.render \profile
				else
					@transition \login

		'/new':
			render: (E) ->
				"TODO: #{path.slice 1 .join ' '}"

		'/reationships':
			onenter: ->
				console.log "on the relationships page"

			render: (E) ->
				@poetry.Verse.RelationShips.render \list # will render the respective 'lg-list' (if we're that size) otherwise, 'list'
				E \div c: \container,
					E \h3 c: \panel-title, ""
		'/preferences':
			# summon: (cb) ->
			# 	# task = @task 'summon multiple things'
			# 	# task.push (done) -> ...
			# 	# task.push (done) -> ...
			# 	# task.end done
			# 	@Mun.get \mine, done

			error: (E) ->

			render: (E, d) ->
				poem = @
				E \div c: \preferences,
					E \h3 null, "Preferences"
					E \div null, "... nothing here yet ..."
					E \h3 null, "Different entities"
					E \div c: \muns,
						E \div c: \list-group, (parent_el) ~>
							el = E \li c: \list-group-item, "loading..."
							console.log "list_muns???", @Session
							@poetry.Verse.MyMuns!render \select_list
							#@Session.render \pref_list
							# poem.list_muns (err, res) ->
							# 	console.log "list_muns", err, res
							# 	replace =
							# 		if err
							# 			E \div c: \error, "something went wrong..."
							# 		else for m in res.muns
							# 			console.log "mun==sess", m._key, poem.poetry.mun
							# 			E \a c: "list-group-item#{if m._key is poem.poetry.session.current.mun => ' active' else ''}" href: '/profile/'+m._key,
							# 				E \div c: \media,
							# 					E \img c: <[pull-left img-rounded img-mun]> data: src: 'holder.js/32x32'
							# 					E \div c: \media-body,
							# 						E \h4 c: \media-heading,
							# 							E \a href: '/profile/'+m._key, m.name
							# 	#E.$ el .remove!
							# 	console.log "remove", E.$
							# 	aC parent_el, replace
							el
					E \h3 null, "Profile Photo"
					E \div c: \dropzone, id: 'my-dropzone',
					# this is the fallback form....
					# E \form c: \dropzone action: '/file-upload',
					#   E \div c: \fallback,
					#     E \input name: "file" type:"file" multiple:true
						!(el) ->
							process.nextTick ->
								console.log "dropzone", el


								Dropzone = window.component.require 'enyo-dropzone'
								dz = new Dropzone el,
									url: '/file-upload'
									dictDefaultMessage: "drag a photo here, or <a href=\"javascript:void(0)\">click</a> to browse for a photo"
								dz.on \addedFile ->
									console.log "addedFile", &
								dz.on \thumbnail (file, data_url) ->
									console.log "thumbnail", &
								dz.on \uploadprogress (file, percent, bytes) ->
									console.log "progress", percent, bytes
								dz.on \sending (file) ->
									console.log "sending file ...", &
								dz.on \error (file, error) ->
									console.log "error", &
								dz.on \success (file, id, evt) ->
									console.log "successfully uploaded file with id #id" &
									Cropper = window.component.require 'yields-crop'
									aC null, img = E \div c: \crop,
										E \img src: "i/#id"
									cropper = Cropper img
									cropper.build!
									console.log "cropper", cropper
									cropper.on \crop (dim) ->
										console.log "cropper dims:", dim
								dz.on \complete ->
									console.log "complete" &

		'/message':
			render: (E) ->
				E \div c: \messages,
					E \h3 null "new MunMessage refs"
					E \div null "should display the message box here (also integrate autocomplete)"
		'/logout':
			onenter: ->
				poem = @
				poem.poetry.session.logout ->
					poem.transition \login