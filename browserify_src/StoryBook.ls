
Url = require \url
assert = require \assert
less = require \less

# Library = require './Library' .Library
Session = require './Session' .Session
# make the ICropper a part of the image bp
# Slick = require \rslnautic-slick .Slick

{ Fsm, ToolShed, _ } = require 'MachineShop'

# the poetry book contains the window and everything in it
class StoryBook extends Fsm
	var window,	cE,	aC,	$
	(refs, id) ->
		self = @
		if typeof refs isnt \object
			@debug.error "you need to pass a 'refs' object to the StoryBook"
		else if not refs.window
			throw new Error "for now, you MUST have a window for this book. later this will be relaxed bor servers and stuff... patience, dude"
		else
			@refs = _.clone refs

		window := refs.window
		window.StoryBook = self
		# window.ICropper = ICropper = require \../lala-components/icropper/icropper .ICropper
		# window.ICropper = ICropper = require \./ICropper .ICropper
		cE := window.cE
		aC := window.aC
		$ := window.$

		path = Url.parse window.location.href+''
		@path = @initialPath = path.path

		@akaskic_records = @library = refs.library
		@refs.book = refs.book = @
		# 1. get the session
		refs.session = @session = new Session refs, \1234
		@session.on \auth ->
			# _.each self.poems, (poem) ->
			for poem in self.poems
				poem.exec \auth self.session.current
		@session.on \noauth ->
			# _.each self.poems, (poem) ->
			for poem in self.poems
				poem.exec \noauth
		book = @
		@session.on \mun (mun) ~>
			if @mun
				@mun.exec \load mun
			else
				@mun = @poetry.Word.Mun mun
		@session.on \state:not_authenticated ->
			if book.poem
				book.poem.exec \make_new
				book.poem.transition '/'
		@session.on \state:authenticated ->
			path = Url.parse window.location.href+''
			toState = if path.path isnt @path => path.path else @path
			if book.poem
				book.poem.exec \load book.session.persona
		if @renderers
			@_renderers = @renderers
			delete @renderers
			@_parts = {}
		@books = {} #OPTIMIZE: I don't think this is used...
		@poetry = {}
		@memory = {}
		@poems = []
		@poem = null
		@poem_els = []
		@poem_fqvns = []
		@words = {}
		@_ = {}

		if typeof @_el is \undefined then @_el = \div
		if typeof @_el is \string
			el_opts = if @_class then {c: @_class} else {}
			@_el = cE @_el, el_opts
		else if typeof @_el is \function
			@_el = @_el.call this, cE
		else if typeof @_el isnt \object
			throw new Error "I dunno what to do! "+typeof @_el

		# we're doing this on the prototype, below...
		# DaFunk.extend this, Fsm.Empathy
		super "StoryBook"
		if typeof id is \string
			@debug.todo "load up a storybook from the database of a defined id (figurehead)"

	add_poetry: (encantador, incantation, version, fn) ->
		if typeof @poetry[encantador] isnt \function
			throw new Error "you must make the encantador first ... not happens"

		# console.debug "setting:", encantador, incantation, version, fn
		@poetry[encantador][incantation] = fn

	initialize: ->
		@debug "storybook initialize!!!!!!"

	_class: \StoryBook
	renderers:
		* \poem_header
		* \header
		* \render
		* \poem
		* \footer
		* \poem_footer
	elements:
		Poem:
			Affinaty: \latest
			Sandra: \latest
	_render: -> @_el
	render: (E) ->
		@debug.error "whattt??? we shouldn't be here... remove me"
		if (s = @state) and (ss = @states[s])
			if ss instanceof Fsm
				debugger
			else ss._el
		else "yay!!!"


	eventListeners:
		transition: (e) ->
			set_path = 1
			self = @
			cE = self.refs.window.cE
			aC = self.refs.window.aC
			path = self.state
			_.each self._renderers, (renderer, i) ~>
				if typeof self.state isnt \undefined
					if typeof (r = self.states[path][renderer]) isnt \undefined
						data = e.args.0
						if typeof e.fromState is \undefined
							aC self._el, self._parts[renderer] = if typeof r is \function => r.call(self, cE, data) else r
						else if el = self._parts[renderer]
							# a slightly faster way of clearning an element:
							# http://jsperf.com/innerhtml-vs-removechild/178
							# method 1:
							# el.innerHTML = ''
							el.textContent = ''
							# method 2:
							# _el = el.cloneNode false
							# el.parentNode.replaceChild _el, el
							# self._parts[renderer] = el = _el
							aC el, if typeof r is \function => r.call(self, cE, data) else r
						else set_path--
						# console.error "set_path", set_path, path.0, e.args
						if path.0 is '/'
							if typeof e.fromState is \string and e.fromState.0 isnt '/'
								data = {path: path, mun: UniVerse.mun, poem: UniVerse.poem}
								# console.error "replaceState", path, data, UniVerse.poem
								@replace_path data, "some title"
							else if set_path and data
								UniVerse.poem = data.poem
								# eventually support hash tags on older browsers:
								# https://github.com/defunkt/jquery-pjax
								@push_path data, data.title + ""
					#else if typeof self.priorState is \undefined
					# console.error "you have defined a renderer '#renderer', but it is not initialized in the '#{poem.state}' state"

		invalidstate: (e) ->
			@debug.error "oh shit we're invalid (#{e.state} -> #{e.attemptedState})"


	states:
		uninitialized:
			onenter: ->
				@debug "StoryBook waiting for something to do..."

			'node-webkit:onenter': !->
				@debug "doing uninitialized:node-webkit"
				process.removeAllListeners \uncaughtException
				process.on \uncaughtException (err) ~>
					console.error "uncaught error:", err.stack
					throw err
				#TODO: add watcher

			'browser:onenter': !->
				$ window .bind \click, (e) ~>
					target = e.target
					if target.form # or ((c = target.className) and ~c.indexOf('disabled') and ~(c.split ' ').indexOf 'disabled')
						e.preventDefault!
						return false
					if e.metaKey or e.ctrlKey or e.shiftKey or e.defaltPrevented or (e.button and e.button isnt 1) or typeof target.href is \undefined
						return
					e.preventDefault!
					el = target
					path = el.href
					if ~path.indexOf '://'
						_path = Url.parse path
						path = _path.path
					do
						if machina = el._machina
							setTimeout ->
								if machina.states[machina.state][path]
									machina.exec path, e
								else
									machina.transition path
							, 100
							# we will assume that we don't want to adjust above elements.
							# if the above element wants to listen, then it can just listen....
							e.stopImmediatePropagation!
							return false
					while el = el.parentNode
					if path
						@debug.error "wtf?!?! why?"
						@route path

				$ window .bind \popstate, (evt) !~>
					# console.log "popstate.evt", evt+""
					if url = evt.originalEvent.state
						# console.log "popstate", evt, url
						@debug.todo "TODO!!!! - we really need a - back button! - lol"
						# console.log "poetry", poetry, poetry?mun
						# console.log "::", url, evt.originalEvent
						# if @mun isnt url.mun
						# 	console.error "you were a different mun back then!!"
						# 	console.error "TODO: switch the mun"
						# if @poem isnt url.poem
						# 	console.error "does no good to route on a differen poem!!"
						# 	console.error "TODO: switch the poem"
						if url then @route url.path, true
					else
						console.error "POP STATE"
					evt.preventDefault!

			render: (E) ->
				E \div null "main..."

	cmds:
		login: (opts, cb) ->
			throw new Error "not yet implemented dude"
			# TODO: implement mozilla persona - well :)
			@session.exec \persona.login (opts, cb) ->


		logout: ->
			@session.exec \persona.logout ->

		open: (name, version, path, cb) ->
			if typeof name isnt \string
				throw new Error "we can't figure out the name of the poetry you're trying to load"
			if typeof fqvn isnt \string
				fqvn = name

			UniVerse.library.exec \fetch {encantador: "Poem" incantation: name, version, book: @}, (err, bp) ~>
				# debugger
				bp.once \state:ready ~>
					@debug "POEM INITIALIZED.... wait for a session"
					@session.once_initialized !~>
						@debug "SESSION INITIALIZED...."
						noem = name+'@'+version
						@debug.todo "replace_path here with the poem loaded ... later replace again"
						@session.now.poem = noem
						sess_id = @session.id
						@debug "loading poem '#noem' with sess_id: #sess_id", bp
						@poem = poem = @poetry.Poem[name](sess_id)
						poem.on \transition (evt) ~>
							if evt.toState.indexOf('/') is 0
								@debug "set the path!! -> %s", evt.toState
								@push_path {poem: poem.fqvn, path: evt.toState}, poem.title
						# @session.on \persona ~>
						# 	# debugger
						# 	if @poems.length is 0 and @initialPath
						# 		poem.path = @initialPath
						# 	poem.exec \load @session.persona
						# 	@debug.todo "save the current sessi"

						fqvn = name+'@'+version
						@states[fqvn] = {}
						@states[fqvn].render = poem
						@poems.push poem
						@poem_fqvns.push fqvn
						@poem_els.push poem._el
						# transition the storybook to the poem in use

						if not bp._blueprint.style
							debugger
						else
							not_found = true
							for e in els = document.getElementsByTagName \style
								if e.dataset.encantador is bp.encantador and e.dataset.incantation is bp.incantation
									not_found = e.disabled = false
								else
									e.disabled = true
							if not_found is true
								parser = new window.less.Parser {
									env: \development
									# async: false
									filename: bp.encantador+'-'+bp.incantation+'.less'
									rootpath: window.location.host
									paths: ['bootstrap/less', '.']
									relativeUrls: false
									timeout: 2000
									# optimization: 2
								}
								parser.parse bp._blueprint.style, ((err, tree) ->
									css = tree.toCSS!
									aC null cE \style, data: {bp.encantador, bp.incantation}, css
								), {
									globalVars: void
									modifyVars: void
								}

						poem.transition @path
						@transition noem

						@debug.todo "load up the path into the poem"

		activate: (fqvn) ->
			throw new Error "not yet implemented - poem switching"
			# if not poem = @poems[fqvn]
			debugger

	authenticated:~ ->
		if @session.current => true else false

	replace_path: (data, title) ->
		window.history.replaceState data, title, data.path
	push_path: (data, title) ->
		window.history.pushState data, title+Math.random!toString(32).slice(2), data.path

	route: (path, is_back) ->
		window_href = window.location.href + ''
		window_href_base = window_href.substr 0, window_href.lastIndexOf '/'
		mun = if @session.current => @session.current.mun else null
		poem = @state
		url = Url.parse path
		if url.path
			path = url.path
		if url.protocol
			proto = url.protocol

		querystring = ''
		if i = ~path.indexOf '?'
			querystring = path.slice i + 1
			path = path.slice 0, i

		@debug "route:", path, "->", @path
		if path isnt @path
			poem = @states[@state].render
			poem.transition path, {poem, path, mun}

		switch proto
		| \poem =>
			@debug.error "poem router... eventually this will become a its own poem ... eg. poem://saviour/emanuel/muthta/fuckin/christ/is/awesome will oviously route 'emanuel/muthta/fuckin/christ/is/awesome' inside of the 'saviour' poem - obviously :) lol"
			debugger
			@debug " #{proto}:#{poem} @ path: #{path}"

		# this is kinda old code... don't do this. it'll change
		switch path
		| \/logout =>
			@exec \logout

		| \/disconnected =>
			# TODO: show disconnected thing...
			refs.poem.emit \disconnected
			aC null, lala = cE \div c: 'modal-backdrop fade in'
			_universe.on \ready ~>
				$ lala .remove!

		@debug "we're done routing now ... is_back: %s", is_back

ToolShed.extend StoryBook::, Fsm.Empathy
export StoryBook