
# it'd be cool to have a thoughtstreams mobile app
# https://thoughtstreams.io

# add font editor?
# https://github.com/mattlag/GLYPHR

# convert to rem instead of px for css
# https://bugsnag.com/blog/responsive-typography-with-rems

# mozilla brick (html components)
# https://hacks.mozilla.org/2014/03/custom-elements-for-custom-applications-web-components-with-mozillas-brick-and-x-tag/


encantador: \Poem
incantation: \Poem
type: \Fixed
version: \0.1.1
# embodies:
# 	* \Timely # this adds d_created/d_modified fields
# 	* \Creation # this adds creator fields
poetry:
	Verse:
		'Session': \latest
	Word:
		'Mun': \latest
		Session: \latest

layout:
	name:
		type: \string
		required: true
	mask:
		type: \object
	brand:
		type: \function

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
	order:
		* \header
		* \render
		* \footer
	parts:
		header: (E) ->
			poem = @
			poetry = @poetry
			session = @book.session

			E \div c: <[navbar navbar-inverse navbar-fixed-top]>,
				E \div c: \something,
					E \a c: \navbar-brand href: '/',
						if typeof poem.brand is \function then E.call(poem, E)
						else if poem.brand then poem.brand
						else "[TODO: editable brand name]"
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
						window.session = @poetry.Word.Session '/navbar', {
							initialState: \navbar
							el: E \ul c: <[nav navbar-nav navbar-right]>
						}

		render: (E) ->
			E \div id: \content, "loading..."

		poem_footer: (E) ->
			E \div c: 'navbar navbar-inverse navbar-fixed-bottom', "[footer TODO]" # ...
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

		# console.log "proto:#{proto} url_poem:#{url_poem} path:#{path}"
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

	states:
		uninitialized:
			onenter: ->
				if not @book.authenticated
					@transitionSoon \login

		invalidstate:
			render: (E) ->
				E \div c: \todo data: todo: "new_page_editor", "invalid state: TODO: make a new page editor"
				#TODO: make it search for the data after loading the element
				#TODO: make an external interface for the todos

		ready:
			onenter: ->
				path = @path || '/'
				@transition path, {poem: @poetry.poem, mun: @poetry.mun, path}
			render: (E) ->
				E \div null "This shouldnit happen"

		'/':
			render: (E) ->
				E \h2 null "TODO: a splash page"

		'/about_us':
			render: (E) ->
				E \div c: \container,
					E \h2 null, "About Us"
					E \p null, "some about us text goes here..."


		'/home':
			render: (E) ->
				E \div null "TODO: a home page"

		'/profile/:id':
			onenter: (req) ->
				console.log "going to someone else's profile:", req

			render: (E, req) ->
				E \div null, "someone else's profile, id: ", req.params.id
				# gonzalo = @poetry.Word.Mun.incantation req.params.id
				# gonzalo.render \profile

		'/profile':
			onenter: ->
				if session = @book.session.current
					id = @book.session.current.mun
					mun = @poetry.Word.Mun id
				else
					debugger
					@transition \login

		'/new':
			render: (E) ->
				E \div null "TODO: a new poem page"

		'/preferences':
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
							@poetry.Verse.MyMuns!render \select_list
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
				@debug "gonna log out now..."
				poem = @
				@book.session.exec \persona.logout ->
					poem.transition '/'
