
Fs = require \fs
Path = require \path
assert = require \assert

# p$ = require \procstreams
# Ini = require \ini
# Github = require \github
Walk = require \walkdir
LiveScript = require \livescript
LSAst = require \livescript/lib/ast

# instead of doing source maps like this,
# I will definitely want to be doing this:
# https://github.com/blendmaster/LiveScript/tree/esprima
# { SourceMapGenerator, SourceMapConsumer, SourceNode } = require \source-map-cjs
# { SourceMapGenerator } = require \source-map-cjs

{ _, Debug, ToolShed, Fsm, Config, DaFunk } = MachineShop = require \MachineShop

class Reality extends Fsm
	embody: (concept) ->
		# console.log "embody", concept
		DaFunk.extend this, Reality.modifiers[concept]

		# add: (more) ->
		# 	if word = ToolShed.get_obj_path more, @concepts
		# 		@emit "added:#more", new word arg1, arg2
		# 	else
		# 		@debug.error "tried to add '#more' to the sentence, but I'm not sure what it is. add it to the concepts"
		# 		# @machina.send \blueprint.missing.concepts, more
		# 		@machina.send \blueprint://concepts/missing, more

		# addIn: (where, what) ->
		# 	if word = ToolShed.get_obj_path more, @concepts
		# 		@emit "addedIn:#more", arg1, new word arg2, arg3
		# 	else
		# 		@debug.error "tried to add '#more' to the sentence, but I'm not sure what it is. add it to the concepts"
		# 		@machina.send \blueprint://concepts/missing, more

		# added: (what) ->
		# 	@_sentence.push what

		# addedIn: (where, what) ->
		# 	@_sentence.splice arg1, 1, arg2


	(impl, opts) ->
		@_impl = impl
		if @initialState
			@_initialState = @initialState
		@initialState = false

		if typeof (modifier = @embodies) is \string
			@embody modifier
		else if Array.isArray modifier
			_.each modifier, @embody, this

		# TODO: super impl.name, impl.id, opts
		super impl.name, impl.id, opts

	initialize: ->
		console.log "initialize"
		self = this
		console.log "locals:", @_impl.local
		if locals = @_impl.local
			_.each locals, (uri, where) ~>
				console.log "get:", uri
				@refs.library.exec \get uri, (err, res) ->
					console.log "err", err
					console.log "ToolShed.set_obj_path", where, typeof self, typeof res
					locals[where] = res
					ToolShed.set_obj_path where, self, res
					do_trans = true
					for k, v of locals
						# console.log "l", k, v
						if typeof v is \string
							do_trans = false
							break

					if do_trans
						self.transition @_initialState || \uninitialized

		# if modifier = @improves
		# 	_.each modifier, (mod) ->
		# 		console.log "modifier", mod
		# 		the_concept = ToolShed.get_obj_path modifier, Concept.definitions
		# 		DaFunk.extend self, the_concept

		# if concept = @concepts
		# 	_.each concept (uri, where) ->
		# 		if ~(i = uri.indexOf '://')
		# 			proto = uri.substr 0, i
		# 			path = uri.substr i+3
		# 			@emit "load:#proto", path, "concepts.#where", @
		#TODO: poetry


	eventListeners:
		'load:node': (what, where, obj) ->
			ToolShed.set_obj_path where, obj, require what
			@emit "loaded:node:#what"

		'load:npm': (what, where, obj) ->
			@refs.library.exec \get,
			mod = new Module @refs, what
			mod.once \ready ->
				ToolShed.set_obj_path where, obj, mod.exports
				@emit "loaded:npm:#what"

		'load:blueprint': (what, where, obj) ->
			bp = new Blueprint @refs, what
			bp.once \ready ->
				ToolShed.set_obj_path where, obj, bp
				@emit "loaded:blueprint:#what"

		'load:git': (what, where, obj) ->
			bp = new Repo @refs, what
			bp.once \ready ->
				ToolShed.set_obj_path where, obj, bp
				@emit "loaded:blueprint:#what"

	states:
		uninitialized:
			onenter: ->

				# if improves = @improves
				# 	@once \loaded ~>


				# 	waiting_for = \reality:ready
				# 	for improvement in improves
				# 		@once "#waiting_for:ready", ->
				# 			@exec \self:improve improvement
				# 		waiting_for = improvement

Reality.modifiers =
	Idea:
		'and|initialize': ->
			if typeof @concepts isnt \object
				@concepts = {}
			if concepts = @concepts
				_.each concepts, (concept, uri) ->
					console.log "concept:", concept, uri
					ToolShed.set_obj_path concept, new Idea @refs, uri
			else
				@concepts = {}


		eventListeners:
			'*': (evt, arg1, arg2, arg3) ->
				console.log "*:", evt
				if evt.indexOf('add:concept:') is 0
					more = evt.substr('add:concept:'.length)
					if word = ToolShed.get_obj_path more, @concepts
						@emit "added:#more", new word arg1, arg2
					else
						@debug.error "tried to add '#more' to the sentence, but I'm not sure what it is. add it to the concepts"
						@machina.send \blueprint:missing:concepts, more
				else if evt.indexOf('addIn:') is 0
					if word = ToolShed.get_obj_path @concepts, more = evt.substr(4)
						@emit "addedIn:#more", arg1, new word arg2, arg3
					else
						@debug.error "tried to add '#more' to the sentence, but I'm not sure what it is. add it to the concepts"
						@machina.send \blueprint:missing:concepts, more
				# else if evt.indexOf('added:') is 0
				# 	@_sentence.push arg1
				# else if evt.indexOf('addedIn:') is 0
				# 	@_sentence.splice arg1, 1, arg2


	# gonna write that bitch a sonnet. bitches love sonnets -shakespeare
	Interactivity:
		prompt: (txt, data, fn) ->
			if typeof data is \function
				fn = data
			else if Array.isArray data
				_.each data, fn
			else
				fn data
			show_prompt = (prompt) ->
				console.log "#{prompt} PROMPT:", txt, data

	Verse:
		'and|initialize': ->
			@_verse = []
			console.log "INIT"

		each: (cb) -> _.each @_verse, cb, @

		eventListeners:
			'*': (evt, arg1, arg2, arg3) ->
				if evt is \transition
					cmds = @
				if evt.indexOf('add:') is 0
					more = evt.substr('add:'.length)
					console.log "add:", more
					if word = ToolShed.get_obj_path more, @concepts
						if typeof word is \string
							# @once "ready:#more" -> @emit "added:#more", new word arg1, arg2
							throw new Error "... '#more' is not ready yet"
						else if typeof word is \function
							@emit "added:#more", new word arg1, arg2
					else
						@debug.error "tried to add '#more' to the verse, but I'm not sure what it is. add it to the concepts"
						@machina.send \blueprint:missing:concepts, more
				else if evt.indexOf('addIn:') is 0
					more = evt.substr('addIn:'.length)
					if word = ToolShed.get_obj_path more, @concepts
						@emit "addedIn:#more", arg1, new word arg2, arg3
					else
						@debug.error "tried to add '#more' to the verse, but I'm not sure what it is. add it to the concepts"
						@machina.send \blueprint:missing:concepts, more
				else if evt.indexOf('added:') is 0
					@_verse.push arg1
				else if evt.indexOf('addedIn:') is 0
					@_verse.splice arg1, 1, arg2
				#TODO: remove (id)
				#TODO: update (id, diff)

	Form:
		'and|initialize': (key) ->

			if not @refs.memory
				throw new Error "for an something to take Form, it must have access to memory"

			self = @
			self._is_dirty = false
			self._dirty_vals = {}
			self._is_new = true
			client_key = Math.random!toString 32 .substr 2
			if typeof key is \object
				# debugger
				self._xp = key
				self._xp._k = client_key
				self._is_dirty = true
				key = key._key
				# @exec \verify

			self.id = @idea.concept+'/'+client_key

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
			invalidstate: (e) !->
				@debug.error "oh shit we're invalid (#{e.state} -> #{e.attemptedState}) %s", @_bp.encantador
				@debug.todo "moved to invalid state... if in debug mode, try to load the bluprint so you get to make the state right there..."

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
						@_loading = key
				else
					throw new Error "we don't know what kind of key this is: #{id} ... unable to load"

					console.log "going to extend this with the "
					@debug.todo "check to see if it has a key"
					@debug.todo "@exec"





export Reality
