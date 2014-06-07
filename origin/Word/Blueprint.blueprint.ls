
# this will evolve into a generic blueprint with which you will have an interface
# to create new words (same for Poem/Poem)

# purhaps, ue tis sort of visualization to makn the editor more awesome
# http://mbostock.github.io/protovis/ex/indent.html

#incantator: \Word
encantador: \Word
#type: \Blueprint
incantation: \Blueprint
#encantacion: \Blueprint
#name: \Blueprint
version: \0.1.0
embodies:
	* \Machina
	* \Timely
	* \Creation
# synchronize, harmonize
api: (api, bp) ->
	path = api.get '/_#{bp.type}/:type/:name' (req, res) ->
		id = req.get \id
		@collection.byExample name: id type: id
		r = bp.model.byId req.params \id
		res.json r.forClient!
	path.pathParam \type, type: \string description: "what is the type of the blueprint you want to get"
	path.pathParam \name, type: \string description: "what is the name of the blueprint you want to get"
	path.queryParam \version, type: \string description: "what id you want to get"

	path = app.del '/_#{bp.type}/:id' (req, res) ->
		# TODO: verify the user has permissions to delete
		bp = bp.model.removeById req.params \id
	path.pathParam \id, type: \string description: "what id you want to delete"
	path.onlyIfAuthenticated 401, 'not logged in'

	path = app.patch '/_#{bp.type}/:id' (req, res) ->
		# TODO: verify the user has permissions to update
		# bps.updateById req.params \id
		# res.json bp.forClient!
	path.pathParam \id, type: \string description: "what id you want to get"
	path.bodyParam \data, "new data for your Blueprint", bp.model
	path.onlyIfAuthenticated 401, 'not logged in'

	path = app.put '/_#{bp.type}', (req, res) ->
		# TODO: verify the user has permissions to make a new one
		bp = new bp.model req.body!
		res.json Blueprints.save bp
	#path.bodyParam \name, "the name of your Blueprint", bp.model
	path.bodyParam \name, bp.name.description, bp.model
	path.bodyParam \type, bp.type.description, bp.model
	path.bodyParam \uid, bp.uid.description, bp.model
	path.onlyIfAuthenticated 401, 'not logged in'

layout:
	mid:
		type: \string
		ref: \Mun._key
		# if set() receives an object, then automatically run this check: if ~(i = f.ref.indexOf '.') and typeof (v = val[k = f.ref.substr ++i]) isnt \undefined then v
		description: \Mün
		required: true
		# default: (bp) -> hamsternipples
	encantador: # incantator
		type: \string
		description: "which abstract Blueprint will serve as the progenetor of this incantation (encantador)"
		ref: \Blueprint.type
		required: true
	incantation:
		type: \string
		description: "the name of this Blueprint"
		ref: \Blueprint.name
		required: true
	version:
		type: \string
		description: "this Blueprint's version"
		element: \Semver
		default: \0.0.1
	machina:
		type: \object
		funky: true
		# required: true
		# default:
		# 	initialize: ->
		# 		console.log "instantiate #{@bp.name}"
		# 	states:
		# 		uninitialized:
		# 			onenter: ->
		# 				console.log "hello world! we're #{@state}"
		# 			render: (E) ->
		# 				E \div c: \empty, "an empty element"
	queries:
		type: \object
		description: "list of queries you will want to use in this blueprint"
		funky: true
	abstract:
		type: \boolean
		description: "an abstract blueprint has a layout, but does not have a db.collection. useful for storing common things many blueprints will use (eg. it's a mixin)"

phrases:
	list_item: (E) ->
		E \div c: \container, "a cool blueprint: #{@get(\name)}"
	render: (E) ->
		E \div null, "TOD00000"

machina:
	initialize: ->
		console.log "instantiate Word:"
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

	eventListeners:
		noauth: ->
			console.error "GOT A NOAUTH", @state
			if @state is \uninitialized
				@transition \login

		auth: (session) ->
			console.error "GOT AN AUTH"
			@transition \ready
			#window.location.href
			# setup the session

	states:
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

		'/':
			onenter: ->
				unless @book.session.current
					@transition \login

			render: (E) ->
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
				if session = @book.session.current
					user = @poetry.Word.Mun.inst @book.session.current.mun
					console.warn "Word", @poetry.Word.Mun.inst
					console.log "Verse", @poetry.Verse
					user.render \profile
				else
					@transition \login

		'/new':
			render: (E) ->
				"TODO: #{path.slice 1 .join ' '}"

		'/preferences':
			render: (E) ->
				poem = @
				E \div c: \preferences,
					E \h3 null, "Preferences"
					E \div null, "... nothing here yet ..."
					E \h3 null, "Different entities"
					E \div c: \muns,
						E \div c: \list-group, (parent_el) ->
							el = E \li c: \list-group-item, "loading..."
							poem.list_muns (err, res) ->
								console.log "list_muns", err, res
								replace =
									if err
										E \div c: \error, "something went wrong..."
									else for m in res.muns
										console.log "mun==sess", m._key, poem.poetry.mun
										E \a c: "list-group-item#{if m._key is poem.poetry.session.current.mun => ' active' else ''}" href: '/profile/'+m._key,
											E \div c: \media,
												E \img c: <[pull-left img-rounded img-mun]> data: src: 'holder.js/32x32'
												E \div c: \media-body,
													E \h4 c: \media-heading,
														E \a href: '/profile/'+m._key, m.name
								$ el .remove!
								aC parent_el, replace
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