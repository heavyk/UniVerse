
Url = require \url
assert = require \assert

# Library = require './Library' .Library
Session = require './Session' .Session
# make the ICropper a part of the image bp
# Slick = require \rslnautic-slick .Slick

{ Fsm, ToolShed, Fabuloso, _ } = require 'MachineShop'

# this does almost everything this guy wants:
# http://mvalente.eu/category/programming/

# for later, when objects change their values and we need to pay the XP for the change
# class Experience extends Scope

# for later, when we can save xp into the universe for changes to the Experience
# class ExperienceDB extends Fsm

# for later, when we can have a market
# class Currency extends Fsm

# for later, when we get blueprints out of the ether
# class EtherDB extends Fsm

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
		window.ICropper = ICropper = require \./ICropper .ICropper
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
			console.log "mun:", book.session.mun
			path = Url.parse window.location.href+''
			toState = if path.path isnt @path => path.path else @path
			console.log "AUTHENTICATED! persona", book.session.persona, "poem", book.poem
			# self.emit \transition {fromState: @state, toState, args: []}
			# poem = self.states[self.state].render
			# poem =
			if book.poem
				book.poem.exec \load book.session.persona
			# book.poem.once 'state:ready' ->
			# 	poem.transition toState
			# else
			# 	self.transition toState
		# refs.library = @library = new Library refs, name: \sencillo # host: ...
		# 2. unless id, load the StoryBook with the persona._id
		# 3.
		if @renderers
			@_renderers = @renderers
			delete @renderers
			@_parts = {}
		@books = {} # I don't think this is used...
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

		ToolShed.extend @, Fabuloso
		super "StoryBook"
		if typeof id is \string
			@debug.todo "load up a storybook from the database of a defined id (figurehead)"

	initialize: ->
		console.log "storybook initialize!!!!!!"
		# debugger

	_class: \StoryBook
	renderers:
		* \poem_header
		* \header
		* \render
		* \poem
		* \footer
		* \poem_footer

	_render: -> @_el
	render: (E) ->
		# E \div null "woahhh"
		debugger
		if (s = @state) and (ss = @states[s])
			# debugger
			if ss instanceof Fsm
				debugger
			else ss._el
		else "yay!!!"

	# poem:~
	# 	-> if @poem => @poem.key else null
	# 	# (key) ->
	# 	# 	if @_poem and key isnt @_poem.key
	# 	# 		@session.exec \mun.set

	eventListeners:
		transition: (e) ->
			set_path = 1
			self = @
			cE = self.refs.window.cE
			aC = self.refs.window.aC
			path = self.state
			_.each self._renderers, (renderer, i) ~>
				if typeof self.state isnt \undefined
					# if ~self.state.indexOf '@'
					# 	debugger
					if typeof (r = self.states[path][renderer]) isnt \undefined
						data = e.args.0
						# console.error "priorState", e.fromState
						if typeof e.fromState is \undefined
							aC self._el, self._parts[renderer] = if typeof r is \function => r.call(self, cE, data) else r
						else if el = self._parts[renderer]
							# console.error "RENDER:", self._loading
							el.innerHTML = ''
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
								# console.error "self.transition.pushState"
								# console.error "pushing state", data.path, data
								@push_path data, data.title + ""
					#else if typeof self.priorState is \undefined
					# console.error "you have defined a renderer '#renderer', but it is not initialized in the '#{poem.state}' state"

		invalidstate: (e) ->
			@debug.error "oh shit we're invalid (#{e.state} -> #{e.attemptedState})"


	states:
		uninitialized:
			onenter: ->
				@debug "StoryBook waiting for something to do..."
				# debugger
				# @transition \ready

			# open: (name, version) ->
			# 	console.error "load poem: Poem/#{name}"
			# 	bp = UniVerse.archive.blueprint \Poem, name
			# 	bp.once_initialized ~>
			# 		console.error "poem initialized", bp._blueprint
			# 		opts = ToolShed.da_funk bp._blueprint, refs, name: bp.fqvn
			# 		console.error "objectify res:", bp._blueprint, opts
			# 		opts.path = url.path if url.path
			# 		# console.error "bp.machina", typeof opts.machina, opts.machina
			# 		# opts.machina = {} unless opts.machina
			# 		@_[_universe.poem] = poem = bp.inst \affinaty #'affinaty' # {url}
			# 		console.error "POEM:", poem
			# 		# done!

			'node-webkit:onenter': !->
				console.log "doing uninitialized:node-webkit"
				process.removeAllListeners \uncaughtException
				process.on \uncaughtException (err) ~>
					console.error "uncaught error:", err.stack
					throw err
				#TODO: add watcher

			'browser:onenter': !->
				$ window .bind \click, (e) ~>
					# console.log "click", e
					target = e.target
					if target.form# or ((c = target.className) and ~c.indexOf('disabled') and ~(c.split ' ').indexOf 'disabled')
						e.preventDefault!
						return false
					if e.metaKey or e.ctrlKey or e.shiftKey or e.defaltPrevented or (e.button and e.button isnt 1) or typeof target.href is \undefined
						return
					e.preventDefault!
					# console.log "click on link:", target.href
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
								else #if machina.states[path]
									if path is '/logout'
										debugger
									machina.transition path
							, 100
							# we will assume that we don't want to adjust above elements.
							# if the above element wants to listen, then it can just listen....
							e.stopImmediatePropagation!
							return false
							# return false
						# if el is window
						# 	break
					while el = el.parentNode
					# debugger
					if path
						debugger
						@route path

				$ window .bind \popstate, (evt) !~>
					console.log "popstate.evt", evt+""
					if url = evt.originalEvent.state
						console.log "popstate", evt, url
						console.log "TODO!!!! - back button!"
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
			debugger
			@session.exec \persona.login (opts, cb) ->


		logout: ->
			@session.exec \persona.logout ->

		open: (name, version, path, cb) ->
			console.log "if the poem is not downloaded, download it", &
			console.log "once the poem is downloaded and loaded, switch to it"
			if typeof name isnt \string
				throw new Error "we can't figure out the name of the poetry you're trying to load"
			if typeof fqvn isnt \string
				fqvn = name

			# if typeof version is \function
			# 	cb = version
			# 	path = version = void
			# if typeof path is \function
			# if not path
			# 	path = '/'

			# @states[name] = new Book refs, fqvn
			# bp = UniVerse.archive.get \Poem, name
			# debugger
			# UniVerse.archive.exec \fetch "Poem/#name", (err, bp) ->

			UniVerse.library.exec \fetch {encantador: "Poem" incantation: name, version, book: @}, (err, bp) ~>
				# bp.refs <<< @refs
				# debugger
				bp.once_initialized ~>
					@debug "POEM INITIALIZED.... wait for a session"
					@session.once_initialized !~>
						@debug "SESSION INITIALIZED.... going to imbue the poem now..."
						noem = name+'@'+version
						@debug.todo "replace_path here with the poem loaded ... later replace again"
						@session.now.poem = noem
						sess_id = @session.id
						@debug "loading poem '#noem' with sess_id: #sess_id"
						@poem = poem = @poetry.Poem[name] sess_id
						poem.on \transition (evt) ~>
							console.log "transition evt", evt.toState
							if evt.toState.indexOf('/') is 0
								console.log "set the path!!", evt.toState
								@push_path {poem: poem.fqvn, path: evt.toState}, poem.title
						# @session.on \persona ~>
						# 	# debugger
						# 	if @poems.length is 0 and @initialPath
						# 		poem.path = @initialPath
						# 	poem.exec \load @session.persona
						# 	@debug.todo "save the current sessi"

						console.error "--POEM:", poem
						console.log "states", @states
						fqvn = name+'@'+version
						@states[fqvn] = {}
						@states[fqvn].render = poem
						@poems.push poem
						@poem_fqvns.push fqvn
						@poem_els.push poem._el
						# transition the storybook to the poem in use
						@transition name+'@'+version
						# debugger
						poem.transition @path
						@debug.todo "load up the path into the poem"
						# debugger
						# done!

		activate: (fqvn) ->
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
		console.error "routing path", path, is_back, window_href
		mun = if @session.current => @session.current.mun else null
		poem = @state #@session.poem
		# if ~path.indexOf window_href_base
		# 	path = path.substr window_href_base.length
		# else
		# 	if ~path.indexOf "://"
		# 		proto = path.split '://'
		# 		if proto.length > 1
		# 			[proto, path] = proto
		# 		else
		# 			proto = \http
		# 			path = proto.0
		# 	#[host, path] = path.split '/'
		# 	if (i = path.indexOf '/') > 0
		# 		host = path.substr 0, i
		# 		path = path.substr i
		# 	else if i is 0
		# 		host = cur_host
		# 		path = path
		# 	else
		# 		host = path
		# 		path = '/'
		url = Url.parse path
		if url.path
			path = url.path
		if url.protocol
			proto = url.protocol

		querystring = ''
		if i = ~path.indexOf '?'
			querystring = path.slice i + 1
			path = path.slice 0, i

		console.log "route:", path, "->", @path
		if path isnt @path
			console.error "before transition", path, {poem, path, mun}
			poem = @states[@state].render
			# debugger
			poem.transition path, {poem, path, mun}
			console.log "after transition"

		switch proto
		| \affinaty =>
			console.log "affinaty router... #{proto}:#{poem} @ path: #{path}"
			# t_cur_file = Path.resolve \lib, poem, poem+'.js'
			# if cur_file isnt t_cur_file
			# 	if cur_watcher
			# 		cur_watcher.stop!
			# 	cur_file := t_cur_file
			# cur = require t_cur_file
			/*
			cur_watcher := Fs.watchFile t_cur_file, {interval: 200}, ~>
				console.log "file changed", &
				_.each global.require.cache, (m, k) ~>
					if ~k.indexOf(cur_file) or ~k.indexOf("PublicDB") or ~k.indexOf("Poem") or ~k.indexOf("arango")
						delete global.require.cache[k]
				cur = require cur_file
				console.log "reloading...", path, refs
				refs.poem.transitionSoon path
			*/
			# for now all curs are splash
		# | otherwise =>
		# 	console.error "sorry the #{proto} protocol isn't supported yet"
		# 	return
		# path
		switch path
		| \/logout =>
			@exec \logout

		| \/disconnected =>
			console.log "TODO: show disconnected thing..."
			refs.poem.emit \disconnected
			aC null, lala = cE \div c: 'modal-backdrop fade in'
			_universe.on \ready ~>
				$ lala .remove!

		console.log "we're done...", is_back
		# unless is_back
		# 	# the state can be an object:
		# 	# window.history.pushState href: "#{proto}://#{obj}#{path}", '', #window_href
		# 	console.log "we're done... pushing state:", path, is_back
		# 	console.log "poem", poem
		# 	console.log "mun", mun
		# 	console.log "path", path
		# 	@poem = poem
		# 	@mun = mun
		# 	@path = path
		# 	window.history.pushState {poem, mun, path}, 'a title', path

# console.log "before extend:", StoryBook::initialize
# debugger
ToolShed.extend StoryBook::, Fabuloso
export StoryBook