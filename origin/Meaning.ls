
{ Fsm } = require \MachineShop

class Meaning extends Fsm
	var window,	cE,	aC,	$
	(@book, @_bp, key, opts) ->
		self = @
		self._is_dirty = false
		self._dirty_vals = {}
		self._is_new = true
		client_key = Math.random!toString 32 .substr 2
		self.refs = book.refs
		if typeof key is \object
			# debugger
			self._xp = key
			self._xp._k = client_key
			self._is_dirty = true
			key = key._key
			# @exec \verify

		if typeof key is \string
			self.id = id = if _bp.type is \Mutable
				'quest:'+key
			else
				_bp.incantation+'/'+key
		else
			self.id = _bp.incantation+'/'+client_key

		window := book.refs.window
		cE := window.cE
		aC := window.aC
		# @_cE = _.bind cE, self
		@_cE = ->
			cE.apply self, arguments
		@_cE.$ = $ := window.$
		@_cE.rC = window.rC
		@poetry = book.poetry
		@memory = book.memory[_bp.incantation]
		@_parts = {}
		# @initialState = null
		# if not id
		# 	@state = \new
		# if uninitialized = @states.uninitialized and keys = Object.keys uninitialized
		# 	if keys.length is 1
		# if typeof key is \string
		# 	initialState = key
		# if key is '/navbar'
		# 	debugger
		if typeof opts is \object
			if typeof opts.el isnt \undefined
				self._el = opts.el
				delete opts.el
			ToolShed.extend self, opts

		switch _bp.type
		| \Cardinal =>
			if @_xp
				@_xp_tpl = {} <<< @_xp
				@_xp._k = client_key
			# should this actually be: if self._el @@::_el ???
			if typeof self._el isnt \object
				self._el = \form
		| \Mutable =>
			if key
				@initialState = key

		if not @_xp
			@_xp = {_k: client_key}

		if typeof self._el is \undefined then self._el = \div
		if typeof self._el is \string
			el_opts = if _bp.encantador then {c: _bp.encantador+' '+_bp.incantation+' container-fluid'} else {}
			self._el = cE self._el, el_opts
		else if typeof self._el is \function
			self._el = self._el.call this, cE
		else if typeof self._el isnt \object
			throw new Error "I dunno what to do! "+typeof self._el
		self._el.dataset.blueprint = _bp.fqvn
		self._el._machina = self
		# console.error "Meaning: gonna call super", _bp._blueprint.machina
		# console.log "before super:", @states.ready, this


		if _bp.type is \Fixed and id
			@_loading = key

		if not @parts
			#TODO: remove this warning...
			# @debug.warn "your bluprint doesn't define any parts"
			@parts = {}

		super "#{_bp.encantador}:#{_bp.incantation}(#{if key => key else if _bp.type is \Fixed then \new else _bp.type })"

		if not @id
			debugger

		switch _bp.type
		| \Mutable =>
			if key
				self.exec \quest, key, opts#, self._xp
		| \Abstract =>
			debugger
			console.log "type is changed to significance"
			if key
				self.transition key
		| \Cardinal =>
			console.log "todo: cardinal types..."
			# debugger
			if typeof key is \string
				console.log "load up the exp using this id"
			fallthrough
		| \Fixed => fallthrough
		| otherwise =>
			# debugger
			if id and _bp._blueprint.presence isnt \Abstract
				# if key and experience = @book.memory.get[id]
				# 	@debug "found existing inst", experience
				# 	@_xp = experience
				# 	# debugger
				# else
					self.exec \load key
			# else
			# 	self.transition \ENOENT

		# TODO: add a way to reset the name of the namespace once loaded


	# initialState: false
	render: ->
		"this is #{@namespace}"
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

	# id: ~
	# 	-> @_xp._id
	_render: ->
		# if @encantador is \Poem
		# debugger
		@_el

	action_up: (path, evt) ->
		el = @_el.parentNode
		do
			if machina = el._machina
				process.nextTick ->
					if machina.states[machina.state][path]
						machina.exec path, evt
					else
						machina.transition path
				return machina
		while el = el.parentNode
		return null

	exp: (no_default) ->
		if no_default
			d = _.cloneDeep @_xp
			_.each @_bp.layout, (!(v, k) ->
				if v.required
					d[k] = @get k
			), this
		else
			d = {}
			_.each @_bp.layout, (!(v, k) ->
				if typeof (v = @get k, no_default) isnt \undefined
					d[k] = v
			), this
		return d
	get: (path, no_default) ->
		if @__loading
			# debugger
			# if we don't have the value, return the default if there's a default
			return "loadi___ng..."
		if typeof (v = if ~path.indexOf '.' then get_path(@_xp, path) else @_xp[path]) is \undefined and not no_default and typeof (s = @_bp.layout[path]) isnt \undefined
			if typeof (v = s.default) is \function
				v = v.call this, s
		return v
	set: (path, val) ->
		console.log "set:", path, val, @_xp
		assert @_bp._blueprint.type isnt \Abstract
		# TODO: validate
		# TODO: check for getters/setters
		# TODO: add read-only params (kinda silly though, I know... really only useful for verification)
		if path is \_rev or path is \_key or path is \_id
			@debug.error "'_rev', '_key' and '_id' are immutable properties. you have a bug somewhere..."
			return @_xp[path]

		prev_val = if ~path.indexOf '.'
			get_path(@_xp, path, val)
		else @_xp[path]

		unless _.isEqual val, prev_val
			@_is_dirty = true
			if ~path.indexOf '.'
				set_path(@_xp, path, val)
			else
				@_xp[path] := val
			@_dirty_vals[path] := val
			@emit \set path, val
			return val
			# @_is_verified = false

	forget: (cb) ->
		@debug "forgetting %s", @key
		if @_is_new
			@exec \make_new
			if typeof cb is \function => cb.call this, null, this
		else
			@memory.forget @key, cb

	save: (cb) ->
		console.log "saving..."
		# assert @_bp._blueprint.presence isnt \Abstract
		if @_bp._blueprint.presence is \Abstract
			return
		# actually, we should be able to save, but it won't actually do anything accept for change the client and send the events
		# this is useful if, perhaps an object acts on the behalf of anothor
		# TODO: remove the above restriction for the future
		if @_is_new
			d = @exp true
			# debugger
			if d._rev
				debugger
				console.error "TODO: you have a bug somewhere... you shouldn't have a _rev ever!!"
			@memory.create @_xp, (err, xp) ~>
				if err
					@emit \error err
				else
					@emit \created, xp
				if typeof cb is \function
					cb ...
		else if @_is_dirty
			console.log "saving dirty experience", @_xp, @_dirty_vals
			@memory.patch @key, @_dirty_vals, (err, xp) ~>
				if err
					@emit \error err
				else
					@emit \patched, xp
				if typeof cb is \function
					cb ...
		else cb.call @, void, @_xp

	eventListeners:
		transition: (evt) !->
			@debug ":::: transition %s -> %s", evt.fromState, evt.toState
			@debug "transitioning: #{@_bp.type} %s -> %s", evt.fromState, evt.toState
			# if evt.toState is '/' or @_bp.type is \Cardinal  #typeof evt.fromState is \undefined
			# 	debugger

			set_path = 1
			self = @
			cE = self._cE
			aC = self.refs.window.aC
			path = evt.toState
			from_state = evt.fromState
			cur_state = @states[path]
			part_order = if cur_state.order => cur_state.order else @order
			parts = if cur_state.parts => cur_state.parts else @parts
			if typeof part_order is \string
				# OPTIMIZE! - this is kinda sucky. since this function is called so often, it probably can be optimized...
				part_order = [part_order]
			else if not part_order
				part_order = [\render]
				if not parts
					# part_order = [\render]
					@_parts.render = @_el

			# if evt.toState is '/login'
			# 	debugger
			if not Array.isArray part_order
				throw new Error "blueprint '#{@_bp.fqvn}' does not specify 'order' for its parts: #{Object.keys @parts} - or at least it's not an array..."
			if typeof parts isnt \object
				throw new Error "you have not defined this blueprint's parts or the state's parts..."

			# assert typeof @_parts is \object
			# be sure we have all parts, and in the right order
			# if @_bp.incantation is \Login
			# 	debugger
			# 	console.log "...", part_order
			if part_order
				pi = 0
				for k, i in part_order
					# I'll admit, this is kinda funky logic here... there's no specific reason for it, at all...
					part = @_parts[k]
					if not part and (typeof (p = parts[k]) is \function or typeof (p = @parts[k]) is \function)
						@_parts[k] = part = p.call @, cE
					if part
						if (wrong_one = @_el.childNodes[pi]) isnt part
							@_el.removeChild wrong_one if wrong_one
							@_el.removeChild part if part.parentNode is @_el
							aC @_el, part, pi
						pi++
				# remove remaining...

				part = @_el.childNodes[part_order.length]
				# if @_bp.incantation is \Login
				# 	debugger
				# 	console.log "...", part_order
				while part and part = part.nextSibling
					@_el.removeChild part


			do_render = (renderer) ->
				# if @_bp.incantation is \Login
				# 	debugger
				# 	console.log "...", renderer
				if typeof self.state isnt \undefined
					if @cmds.field_entry and rr = @_bp.layout[renderer]
						# this is a dumb hack to be sure that the field knows its own name...
						# I know, stupid...
						# debugger
						# if not rr.field
						# 	rr.field = renderer
						# debugger
						ret = @exec \field_entry, renderer, rr
					else if typeof (r = self.states[if typeof from_state isnt \undefined and self._loading => \loading else path][renderer]) is \function
						data = evt.args.0
						# console.error "priorState", from_state
						if (typeof self._parts is \undefined and el = self._el) or (typeof self._parts is \object and el = self._parts[renderer])
							# if ~self.namespace.indexOf 'Mun('
							# 	debugger
							# el.innerHTML = ''
							rr = r.call(self, cE, data)
							rC.call @, el, rr
						else set_path--
						if path.0 is '/'
							if typeof from_state is \string and from_state.0 isnt '/'
								data = {path: path, mun: UniVerse.mun, poem: UniVerse.poem}
								# console.error "replaceState", path, data, UniVerse.poem
								self.replace_path data, "some title"
							else if set_path and data
								UniVerse.poem = data.poem
								# eventually support hash tags on older browsers:
								# https://github.com/defunkt/jquery-pjax
								# console.error "self.transition.pushState"
								# console.error "pushing state", data.path, data
								self.push_path data, data.title + ""
					#else if typeof self.priorState is \undefined
					# console.error "you have defined a renderer '#renderer', but it is not initialized in the '#{self.state}' state"
			if part_order
				# _.each part_order, do_render
				for p in part_order =>
					do_render.call this, p
			else
				# debugger
				do_render.call this, \render

		added: (el) ->
			# this will be to keep ref counts of the element...
		removed: (el) ->
			# TODO: when replacing the DOM element in the render function, emit this event
			#    do a dom walk on the removed node and see if _machina is defined. if it is, emit this
			# TODO: when
		destroy: ->
			@debug "destroying..."
			# this is a first attempt to keep things clean memorywise...
			el = @_el
			if el
				el._machina = null
				if el.parentNode
					$ el .remove!

		invalidstate: (e) !->
			# show todo
			# check for states with variables
			path = e.attemptedState
			poem = @
			if path.0 is '/' and poem._regex_routes
				console.log "checking routes", poem._regex_routes
				_.each poem._regex_routes, (regex, p) ->
					if ~path.indexOf regex.at_least
						m = path.match regex
						if m
							m.shift! # knock off first
							params = {}
							_.each m, (p, i) -> params[regex.keys[i].name] = p
							url = e.args.0
							url.params = params
							console.log "FOUND MATCH", p, params, e
							poem.transition p, url
							return false
			#@transition \invalidstate
			@debug.error "oh shit we're invalid (#{e.state} -> #{e.attemptedState}) %s", @_bp.encantador
			@debug.todo "moved to invalid state... if in debug mode, try to load the bluprint so you get to make the state right there..."
			debugger

	'memory:found': (xp) !->
		@_loading = null
		@key = key = xp._key
		@id = xp._id
		@_is_new = false
		@_is_new = !xp._rev
		if @_is_dirty
			@_is_dirty = false
			@_dirty_vals = {}
		#TODO: change its namespace?
		@memory.on "changed:#key" _.bind @'memory:changed', @
		@memory.on "deleted:#key" _.bind @'memory:deleted', @
		@_xp = xp
		if @state
			if @state is @initialState
				if typeof @goto is \string
					@transition @goto
				else
					@transition \ready
			else
				@emit \transition {fromState: @state, toState: @state, args:[]}
		else
			# debugger
			@transition \uninitialized
		# should be something more like this:
		# if @goto
		# 	@transition @goto
		# else
		# 	# re-render the element
		# 	@render!
		# XXX: fixme this is probably broken
		@memory.off "!found:#key", _.bind @'memory:!found', @
		@memory.off "found:#key", _.bind @'memory:found', @

	'memory:changed': (xp) !->
		# this should probably do something fancy. idea is:
		# 1. re-render into a dummy element.
		# 2. just swap out the fields which have changed
		# 3. maybe when swapping out the fields, I can give it some sort of effect
		# 4. this also could be cool for the future where I do some sort of action-replay deal
		# 5. it'd also be cool to save the _rev with a timestamp so I can do a page replay
		# check if key has changed?
		debugger
		@exec \changed xp, old_xp, diff

	'memory:deleted': !->
		@transition \deleted
		# maybe this should do something like:
		# 1. render a deleted element with an undo button.
		# 2. after a certain time passes (and no undo is pressed), it removes itself from the dom
		# 3. if undo is pressed, it'll transition to the undo state, and try to restore itself

	'memory:!found': !->
		@_loading = null
		@exec \make_new
		debugger
		@transition \not_found

	'memory:error': (err) !->
		@_loading = null # is this necessary?
		# @_error = err
		@transition if err.code => err.code else \error

	cmds:
		make_new: (erase_vals) ->
			if erase_vals
				@_xp = ToolShed.extend {}, @_xp_tpl
			else
				@_xp = ToolShed.extend {}, @_xp
				# because extend removes all keys starting with _, these shouldn't exist
				# delete @_xp._key
				# delete @_xp._id
				# delete @_xp._rev
			@_is_new = true
			# TODO: if not erase_vals, then determine the diff here
			@_dirty_vals = {}
			@_is_dirty = false

		load: (key, cb) ->
			if typeof key is \function
				cb = key
				key = @key
			incantation = @_bp.incantation
			@debug "load: %s", key
			if typeof key is \number
				key = @_bp.incantation + '/' + key
			if typeof key is \string
				# if not ~key.indexOf '/'
				# 	key = @_bp.incantation + '/' + key
				if ~key.indexOf '/'
					debugger
				# if ~@id.indexOf \Affinaty
				# 	debugger
				# if we're already loading one, then go ahead and abort the load, then load again
				#TODO: add some sort of timeout here for long loadings.
				# if experience = @book.library.experiences[key]
				# memory = @book.memory[incantation]
				@memory.on "error:#key" _.bind @'memory:error', @

				if xp = @memory.get key
					# @_xp = experience
					@'memory:found' xp
					if typeof cb is \function
						debugger
						cb_state = cb void, xp
					@transition if typeof cb_state is \string and @states[cb_state] then cb_state else if @state isnt @initialState then @state else \ready
				else
					# self = @
					@memory.on "found:#key", ~>
						# debugger
						@'memory:found' ...
					@memory.on "!found:#key" ~>
						@'memory:!found' ...
					# @memory.on "found:#key" _.bind @'memory:found', @
					# @memory.on "!found:#key" _.bind @'memory:!found', @
					# if @_loading and @__loading
					# 	@__loading.abort!
					# console.error "MOVE THIS (the fetch) OVER TO Blueprint (and automatically save it into cache)"
					# @__loading = req = Http.get {path: "/db/#{id}"}, (res) !~>
					# 	@__loading = null
					# 	data = ''
					# 	res.on \error (err) ->
					# 		console.error "we've got an error!!", err

					# 	res.on \data (buf) ->
					# 		# console.log "got data", data
					# 		data += buf

					# 	res.on \end ~>
					# 		console.log "done with the request:", res
					# 		@_loading = null
					# 		if res.statusCode is 200
					# 			@_xp = ToolShed.objectify data, {}, {name: @id} #ToolShed.da_funk res, {}, {name: @id}
					# 			# console.error "YAYAYAYA", @_el, @state
					# 			if @state
					# 				if @state is @initialState
					# 					if typeof @goto is \string
					# 						@transition @goto
					# 					else
					# 						@transition \ready
					# 				else
					# 					@emit \transition {fromState: @state, toState: @state, args:[]}
					# 			else
					# 				# debugger
					# 				@transition \uninitialized
					# 		else
					# 			# @transition \error
					# 			@emit \error, {code: \ENOENT}
					# 			@transition res.statusCode
						# debugger
					# req.setHeader 'Content-Type', "application/json"
					@_loading = key
			else
				throw new Error "we don't know what kind of key this is: #{id} ... unable to load"
				# if typeof id is \object

				console.log "going to extend this with the "
				@debug.todo "check to see if it has a key"
				@debug.todo "@exec"


	initialize: ->
		console.error "Meaning::initialize", @id

	states:
		uninitialized:
			onenter: ->
				console.log "Meaning::uninitialized"

		loading:
			render: (E) ->
				E \div c: \loading, "loading..."

		new:
			onenter: ->
				# debugger
				console.log "we are a new something!", @_bp.namespace
				console.log "states", @states
				# setTimeout ~>
				# 	@transition \yay
				# , 2000

			render: (E) ->
				"TODO: new #{@namespace}... add the voice"


			validate: ->
				console.log "TODO: validate the new word! this should be the voice..."


		edit:
			onenter: ->
				console.log "we're going to edit the experience: #{@id}"

			render: (E) ->


		ready:
			onenter: ->
				console.log "Meaning::ready..."
				console.log "Meaning: waiting for a command or something"

			render: (E) ->
				# debugger
				E \h4 null "Meaning::ready", "(this is a bug because it stould initialize in the uninitialized state)"
				# E \h2 null "ready!"#, @get(\name)

			validate: ->
				console.error "TODO: @validate state??"
				_.each @_bp.layout, (v, k) ->
					console.log "verify path", k, v

		invalidstate:
			onenter: (e) ->
				console.log "invalid state!!", e.attemptedState

			render: (E) ->
				E \div c: \todo data: todo: "new_page_editor", "invalid state: TODO: make a new page editor"
				#TODO: make it search for the data after loading the element
				#TODO: make an external interface for the todos

	path: '/'
	# history: []
	replace_path: (data, title) ~>
		@debug "replacing path %s with title '%s'", data.path, title
		@debug.todo "if history is an array, make sure the ... wait, the latest, is the current one, right?"
		@path = data.path
		@path.data = data
		if title
			@title = title
		# debugger
		# window.history.replaceState data, title, data.path
	push_path: (data, title) ~>
		@debug "pushing path %s with title '%s'", data.path, title
		if not @history
			@history = []
		@history.push @title
		@replace_path data, title
		# debugger
		# window.history.pushState data, title+Math.random!toString(32).slice(2), data.path
