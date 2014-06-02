
{ ToolShed, Fsm } = require \MachineShop


class Motivation extends Fsm
	(@narrator, @_eth, key, opts) ->
		self = @
		self._is_dirty = false
		self._dirty_vals = {}
		self._is_new = true
		client_key = Math.random!toString 32 .substr 2
		self.refs = narrator.refs
		if typeof key is \object
			# debugger
			self._xp = key
			self._xp._k = client_key
			self._is_dirty = true
			key = key._key
			# @exec \verify

		if typeof key is \string
			self.id = id = if _eth.type is \Mutable
				'quest:'+key
			else
				_eth.incantation+'/'+key
		else
			self.id = _eth.incantation+'/'+client_key

		@poetry = narrator.poetry
		@memory = narrator.memory[_eth.incantation]
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

		switch _eth.type
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
			el_opts = if _eth.encantador then {c: _eth.encantador+' '+_eth.incantation+' container-fluid'} else {}
		else if typeof self._el is \function
			self._el = self._el.call this, cE
		else if typeof self._el isnt \object
			throw new Error "I dunno what to do! "+typeof self._el
		self._el.dataset.blueprint = _eth.fqvn
		self._el._machina = self
		# console.error "Motivation: gonna call super", _eth._blueprint.machina
		# console.log "before super:", @states.ready, this


		if _eth.type is \Fixed and id
			@_loading = key

		if not @parts
			#TODO: remove this warning...
			# @debug.warn "your bluprint doesn't define any parts"
			@parts = {}

		super "#{_eth.encantador}:#{_eth.incantation}(#{if key => key else if _eth.type is \Fixed then \new else _eth.type })"

		if not @id
			debugger

		switch _eth.type
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
			if id and _eth._blueprint.presence isnt \Abstract
				# if key and experience = @narrator.memory.get[id]
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
			_.each @_eth.layout, (!(v, k) ->
				if v.required
					d[k] = @get k
			), this
		else
			d = {}
			_.each @_eth.layout, (!(v, k) ->
				if typeof (v = @get k, no_default) isnt \undefined
					d[k] = v
			), this
		return d
	get: (path, no_default) ->
		if @__loading
			# debugger
			# if we don't have the value, return the default if there's a default
			return "loadi___ng..."
		if typeof (v = if ~path.indexOf '.' then get_path(@_xp, path) else @_xp[path]) is \undefined and not no_default and typeof (s = @_eth.layout[path]) isnt \undefined
			if typeof (v = s.default) is \function
				v = v.call this, s
		return v
	set: (path, val) ->
		console.log "set:", path, val, @_xp
		assert @_eth._blueprint.type isnt \Abstract
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
		# assert @_eth._blueprint.presence isnt \Abstract
		if @_eth._blueprint.presence is \Abstract
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
			@debug "transitioning: #{@_eth.type} %s -> %s", evt.fromState, evt.toState
			# if evt.toState is '/' or @_eth.type is \Cardinal  #typeof evt.fromState is \undefined
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
				throw new Error "blueprint '#{@_eth.fqvn}' does not specify 'order' for its parts: #{Object.keys @parts} - or at least it's not an array..."
			if typeof parts isnt \object
				throw new Error "you have not defined this blueprint's parts or the state's parts..."

			# assert typeof @_parts is \object
			# be sure we have all parts, and in the right order
			# if @_eth.incantation is \Login
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
				# if @_eth.incantation is \Login
				# 	debugger
				# 	console.log "...", part_order
				while part and part = part.nextSibling
					@_el.removeChild part


			do_render = (renderer) ->
				# if @_eth.incantation is \Login
				# 	debugger
				# 	console.log "...", renderer
				if typeof self.state isnt \undefined
					if @cmds.field_entry and rr = @_eth.layout[renderer]
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
			@debug.error "oh shit we're invalid (#{e.state} -> #{e.attemptedState}) %s", @_eth.encantador
			@debug.todo "moved to invalid state... if in debug mode, try to load the bluprint so you get to make the state right there..."
			debugger

	'memory:found': (xp) !->
		# debugger
		@_loading = null
		# debugger
		@key = key = xp._key
		@id = xp._id
		@_is_new = false
		# if ~@key.indexOf "398444806567" # "462369604007"
		# 	debugger
		if ~@id.indexOf \Affinaty
			debugger
		@_is_new = !xp._rev
		if @_is_dirty
			@_is_dirty = false
			@_dirty_vals = {}
		if ~@id.indexOf \Affinaty
			debugger
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
			incantation = @_eth.incantation
			@debug "load: %s", key
			if typeof key is \number
				key = @_eth.incantation + '/' + key
			if typeof key is \string
				# if not ~key.indexOf '/'
				# 	key = @_eth.incantation + '/' + key
				if ~key.indexOf '/'
					debugger
				# if ~@id.indexOf \Affinaty
				# 	debugger
				# if we're already loading one, then go ahead and abort the load, then load again
				#TODO: add some sort of timeout here for long loadings.
				# if experience = @narrator.library.experiences[key]
				# memory = @narrator.memory[incantation]
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
		console.error "Motivation::initialize", @id

	states:
		uninitialized:
			onenter: ->
				console.log "Motivation::uninitialized"

		loading:
			render: (E) ->
				E \div c: \loading, "loading..."

		new:
			onenter: ->
				# debugger
				console.log "we are a new something!", @_eth.namespace
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
				console.log "Motivation::ready..."
				console.log "Motivation: waiting for a command or something"

			render: (E) ->
				# debugger
				E \h4 null "Motivation::ready", "(this is a bug because it stould initialize in the uninitialized state)"
				# E \h2 null "ready!"#, @get(\name)

			validate: ->
				console.error "TODO: @validate state??"
				_.each @_eth.layout, (v, k) ->
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

Magnetism =
	emit: ->
		debugger
		console.log "TODO"


class Process extends Fsm
	(@refs, opts) ->
		# unless refs.window
		# debugger
		# @processes[long_incantation] = bp = new Process {incantation, encantador, version}
					# get the process from the LocalDB / PublicDB / EtherDB
					# TODO: first get from localstorage, then from the DB...
					# TODO: if its version is latest then watch it for updates

					#first check local storage, then check disk (if latest)
					# then, check the db for an update (if it's a semver that's not definative)

			# incantation = opts
			# if ~(i = incantation.indexOf ':')
			# 	encantador = incantation.substr 0, i
			# 	incantation = incantation.substr i+1
			# 	if ~(i = incantation.indexOf '@')
			# 		version = incantation.substr i+1
			# 		incantation = incantation.substr 0, i
			# opts = {encantador, incantation, version}

		if typeof opts is \object
			if opts.encantador
				@encantador = opts.encantador
			if opts.incantation
				@incantation = opts.incantation
			if opts.version
				@version = opts.version
		else if typeof opts is \string
			throw new Error "TODO: fqvn parsing"
		else
			throw new Error "we don't know whot to do with your process, sorry"

		if typeof refs isnt \object
			@debug.error "you need to pass a 'refs' object to the StoryBook"
		else if not refs.narrator
			throw new Error "you have to reference a Narrator for a ether because we save the imbuement into his memory, obviously"

		@_process = opts

		unless @incantation
			console.error "you need a incantation for your process!"
			throw new Error "you need a incantation for your process!"

		unless @encantador
			console.error "you need a encantador for your process!"
			throw new Error "you need a encantador for your process!"

		# if typeof (XpDB = narrator.library[@incantation]) is \undefined
		# 	XpDB = narrator.library[@incantation] = new ExperienceDB @incantation

		# @XpDB = XpDB

		# if typeof @version is \object
		# 	_version = @version
		# 	version = @version.version
		# 	debugger
		# 	console.log "ALL WRONG"
		if not @version or @version is \*
			@version = \latest

		super "Process(#{@fqvn = @encantador+':'+@incantation+'@'+@version})"
		# if bp = Process._[long_incantation] and typeof DEBUG isnt \undefined
		# 	return bp

	imbue: (narrator) ->
		assert narrator instanceof StoryBook
		# debugger
		if @state is \ready
			console.log "we're gonna make a new imbuement here..."
			var process_inst
			library = @refs.library #.poetry
			_eth = @
			_deps = @_deps
			_process = @_process
			# if typeof narrator.library.memory[@incantation] is \undefined
			# 	narrator.library.memory[@incantation] = new ExperienceDB @incantation
			# I'm not terribly happy with this... I really want to sort out the library and the databases...
			# for now though, this is good enough
			if typeof narrator.memory[@incantation] is \undefined
				narrator.memory[@incantation] = new ExperienceDB @incantation
			#OPTIMIZE: this could be potentially costly to call ToolShed.extend ... I dunno...
			#OPTIMIZE: perhaps instead of eval, we should use new Function
			if typeof narrator.poetry[@encantador] is \undefined
				eval """
				(function(){
					var #{@encantador} = process_inst = (function(superclass){
						var prototype = extend$((import$(#{@encantador}, superclass).displayName = '#{@encantador}', #{@encantador}), superclass).prototype, constructor = #{@encantador};
						function #{@encantador} (narrator, _eth, key, opts) {
							if(!(this instanceof #{@encantador})) return new #{@encantador}(key, opts);
							//#{if @type is \Cardinal then 'ToolShed.extend(this, DefineTone);' else ''}
							//#{if @type is \Mutable then 'ToolShed.extend(this, DefineTiming);' else ''}
							//#{if @type is \Fixed then 'ToolShed.extend(this, DefineSymbolic);' else ''}
							#{@encantador}.superclass.call(this, narrator, _eth, key, opts);
						}
						ToolShed.extend(prototype, _process.machina);
						return #{@encantador};
					}(Motivation));
					ToolShed.extend(#{@encantador}, Magnetism);
					narrator.poetry['#{@encantador}'] = #{@encantador};
				}())
				"""

			if @encantador isnt @incantation
				eval """
				(function(){
					var #{@incantation} = process_inst = (function(superclass){
						var embodies = _deps.embodies, prototype = extend$((import$(#{@encantador}, superclass).displayName = '#{@encantador}', #{@encantador}), superclass).prototype, constructor = #{@encantador};
						function #{@encantador} (key, opts) {
							if(!(this instanceof #{@encantador})) return new #{@encantador}(key, opts);
							#{if @type is \Cardinal then 'ToolShed.extend(this, Tone);' else ''}
							#{if @type is \Mutable then 'ToolShed.extend(this, Timing);' else ''}
							#{if @type is \Fixed then 'ToolShed.extend(this, Symbolic);' else ''}
							#{@encantador}.superclass.call(this, narrator, _eth, key, opts);
						}
						/*
						if(embodies) {
							for(var i in _deps.embodies) {
								ToolShed.extend(prototype, narrator.poetry['#{@encantador}'].prototype);
							}
						}
						*/
						ToolShed.extend(prototype, _process.machina);
						return #{@encantador};
					}(narrator.poetry['#{@encantador}']));
					narrator.poetry['#{@encantador}']['#{@incantation}'] = #{@incantation};
					narrator.poetry['#{@encantador}']['#{@incantation}@#{@version}'] = #{@incantation};
				}())
				"""
			# else
				# debugger


			# console.log "going to extend element", element, "with", @_process.machina
			# debugger if @incantation is \Mun
			# lala = ToolShed.extend element::, @_process.machina

			# console.log "before funkify:", lala
			# debugger if @incantation is \Mun
			# lala = ToolShed.da_funk lala, {lala:1234}, name: @fqvn
			# console.log "after funkify:", lala
			# debugger if @incantation is \Mun
			# debugger

			### return @refs.narrator._[@encantador][@version][id] = lala
		# lala = @refs.narrator._[@encantador][@version][id] = new process_inst @, key # {lala:1234}
			# debugger

			return process_inst
		else
			@debug.error "you can't imbue a process that's not yet ready!: #{@fqvn}"
			# throw new Error "you can't imbue a process that's not yet ready!"
			# perrhaps in the future, we should use a yield and get rid of a bunch of these errors...
		# return @refs.library.processes[@encantador][@version][id] = lala
		# return UniVerse._[@encantador][version][id] = lala

	states:
		uninitialized:
			onenter: ->
				process_eth = ~>
					if not bp = @_process
						debugger
						console.log "wtf mate? the process doesnt exist"
						return
					@type = if bp.type then bp.type else
						switch bp.encantador
						| \Poem \Word => \Fixed
						| \Verse => \Mutable
						| \Voice => \Cardinal

					@layout = bp.layout || {}
					@_deps = {}
					deps = ToolShed.embody {}, bp.poetry
					long_incantation = @fqvn
					embodies = bp.embodies
					if typeof embodies is \string
						embodies = [embodies]
					@_deps.embodies = embodies
					UniVerse = @refs.UniVerse
					unless narrator = @refs.narrator
						debugger
					task = @task "get deps for #{@fqvn}"

					# console.warn @fqvn, "DEPS: ", deps, @refs.library.processes
					if @encantador isnt @incantation
						task.push "getting encantador: #{@encantador}" (done) ->
							encantador = incantation = @encantador
							version = \latest
							if ~(idx = incantation.indexOf '@')
								version = incantation.substr idx+1
								encantador = incantation = incantation.substr 0, idx
							# debugger
							UniVerse.library.exec \fetch {encantador, incantation, version}, @refs.narrator, (err, bp) ~>
								@debug "fetched... %s:%s", encantador, incantation
								# debugger
								@_deps.encantador = bp
								bp.once_initialized ~> done!

					# @debug.todo "add the ability for embodies to be abstract in some way"
					if embodies
						_.each embodies, (incantation, ii) ->
							console.log "embodies", embodies, incantation
							task.push "getting embodied: #{incantation}" (done) ->
								unless incantation
									debugger
								encantador = @encantador
								version = \latest
								# console.log "embodies", embodies, typeof embodies
								if ~(idx = incantation.indexOf '@')
									version = incantation.substr idx+1
									incantation := incantation.substr 0, idx
								UniVerse.library.exec \fetch {encantador, incantation, version}, @refs.narrator, (err, bp) ~>
									@_deps.embodies[ii] = bp
									bp.once_initialized ~> done!

					_.each deps, (deps, encantador) ~>
						_.each deps, (version, incantation) ~>
							task.push "getting element: #{encantador}:#{incantation}@#{version}" (done) ->
								# if typeof narrator.poetry[encantador] is \undefined
								# 	narrator.poetry[encantador] = {}
								# debugger
								# if bp = narrator.poetry[encantador][incantation]
								# 	done!
								# else
								UniVerse.library.exec \fetch {encantador, incantation, version}, @refs.narrator, (err, bp) ~>
									@_deps[bp.fqvn] = bp
									# bp.once_initialized ~> done!
									done!
								# remove me because it should just go into new bp mode... (things should never fail)
								# @once_initialized done
						# 	task.push (done) ->
						# 		UniVerse.UniVerse.emit "dep:#type", name
						# 		UniVerse.UniVerse.once "dep:#type:#name:ready" ->
						# 			console.log "we got dep:#type:#name:ready"
						# 			done!
						# 		UniVerse.UniVerse.on "update:#type:#name" (bp) ->
						# 			console.log "we got an update on #type:#name", @version
						# 			#TODO: do the version as "latest" and make sure te updates are semver compliant
						# 			console.log "TODO: replace the current process (done inside process)"
						# 			console.log "TODO: process has a node derivitave and a browser derivitave. one searches the localdb then does web updates, and the other gets from node"
						# 			console.log "TODO: add this functioality to process"

					# console.log "task:", task.fns, task.done, task
					task.end (err, res) ->
						console.log "done: #long_incantation"
						console.info "initialized process", @fqvn
						# debugger
						@transitionSoon \ready
				req = Http.get {
					path: "/db/_eth/#{@encantador}/#{@incantation}#{if @version and @version isnt \latest => '&version=' + @version else ''}"
				}, (res) !~>
					console.log "we are requesting...."
					data = ''
					res.on \error (err) ->
						console.error "we've got an error!!", err

					res.on \data (buf) ->
						# console.log "got data", data
						data += buf

					res.on \end ~>
						# console.log "done with the request:", res
						if res.statusCode is 200
							# console.log "gonna create a process...", data
							@_process = ToolShed.objectify data, {require: @refs.narrator.refs.require}, {name: @namespace}
							if @version is \latest
								@version = @_process.version
								@fqvn = @encantador+':'+@incantation+'@'+@version
								@refs.library.processes[@fqvn] = @
							# debugger
							if typeof @refs.narrator._[@encantador] isnt \object
								@refs.narrator._[@encantador] = {}
							if typeof @refs.narrator._[@encantador][@version] isnt \object
								@refs.narrator._[@encantador][@version] = {}
							process_eth!
						else
							@transition \error

				# machina = @
				# get_eth encantador, incantation, version, (err, res) ->
					# if err
					# 	@emit \error, err
					# 	@transition \error
					# else
						# @_process = _eth = {} <<< res
						# if bp._process?machina?states?ready?['onenter.js']
						# 	debugger



		ready:
			onenter: ->
				console.log "process ready", @incantation
				@emit \ready

			verify: (path, val) ->
				#TODO: add path splitting by '.'
				#unless s = process[path]
		error:
			onenter: ->
				console.error "you have tried to load a process which wasn't able to be fetched", @incantation

# motivation: \Service
# inception: \Http
# possesses:
# 	* \Desire
# 	* \Origin
# 	* \Agreement
# Creativity -> Origin
# Inception
# Motivation
# Timing -> Progress
# export Desire
# Tone -> Agreement
# export Agreement
export Motivation
export Process