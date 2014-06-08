
{ Debug, EventEmitter, _, ToolShed, Fsm, DaFunk } = require \MachineShop

LiveScript = require \LiveScript

Fs = require \fs
Path = require \path

/*
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
				DaFunk.extend self, opts

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
						@transition \error err
					else
						@emit \created, xp
					if typeof cb is \function
						cb ...
			else if @_is_dirty
				console.log "saving dirty experience", @_xp, @_dirty_vals
				@memory.patch @key, @_dirty_vals, (err, xp) ~>
					if err
						@transition \error err
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
					@_xp = DaFunk.extend {}, @_xp_tpl
				else
					@_xp = DaFunk.extend {}, @_xp
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

*/

class Implementation extends Fsm # Reality
	(opts) ->
		if typeof opts is \string
			opts = {path: opts}
		else if typeof opts.path isnt \string
			throw new Error "you must define a path for your Implementation"

		@impl = {}
		@src = ''

		super "Implementation(#{opts.path})", opts
		@exec \read opts.path

	imbue: (essence) ->
		idea = (impl = @impl).idea
		console.log "IMBUE", typeof @impl
		machina = @impl.machina
		eval """
		(function(){
			var #{idea} = idea_inst = (function(superclass){
				var prototype = extend$((import$(#{idea}, superclass).displayName = '#{idea}', #{idea}), superclass).prototype, constructor = #{idea};
				function #{idea} (refs, opts) {
					//console.log("creating '#idea'...", this.displayName)
					if(!(this instanceof #{idea})) return new #{idea}(key, opts);
					//#{if @type is \Cardinal then 'DaFunk.extend(this, Tone);' else ''}
					//#{if @type is \Mutable then 'DaFunk.extend(this, Timing);' else ''}
					//#{if @type is \Fixed then 'DaFunk.extend(this, Symbolic);' else ''}
					this.refs = refs;
					#{idea}.superclass.call(this, impl, opts);
				}
				DaFunk.extend(prototype, machina);
				return #{idea};
			}(essence));
		}())
		"""

		return idea_inst
	states:
		uninitialized:
			onenter: ->
				@debug "waiting for impl..."

		ready:
			onenter: ->
				console.log "ready"
				@emit \ready @impl, @src

			save:
				onenter: ->
					obj = @impl
					json_str = if opts.ugly => JSON.stringify obj else DaFunk.stringify obj, DaFunk.stringify.desired_order path
					if json_str isnt @src
						path = @path
						Fs.writeFile path, json_str, (err) ~>
							if err
								if err.code is \ENOENT
									dirname = Path.dirname path
									ToolShed.mkdir dirname, (err) ~>
										if err
											@transition \error, err
										else @transition \retry
								else
									@transition \error, err
							else
								@src = json_str
								@emit \saved obj, path, json_str
							@transition \ready
					else @transition \ready

			retry:
				onenter: ->
					# TODO: add backoff support
					setTimeout ~>
						@transition @previousState
					, 500

			error:
				onenter: (err) ->
					console.log "OH NO AN ERROR", err

	cmds:
		read: (path) ->
			if typeof path isnt \string
				return

			Fs.readFile path, 'utf-8', (err, data) ~>
				is_new = false
				if err
					if err.code is \ENOENT
						@emit \new
						@is_new = true
					else
						@transition \error e
				else
					@src = data
					@exec cmd = "compile:#{@lang}"
					@once "executed:#cmd" ->
						@transition \ready
					# try
					# 	switch ext = @parts[*-1]
					# 	| \ls =>

					# 	| \json =>
					# 		_impl = JSON.parse data
					# 		DaFunk.merge @impl, _impl
					# catch e
					# 	@transition \error e
				# @transition \ready
			file = Path.basename path
			@parts = file.split '.'
			if @parts.length > 1
				@lang = @parts[*-1]
			if @parts.length > 2
				@proto = @parts[*-2]

		'compile:ls': ->
			try
				console.log "gonna compile with lang: '#{@lang}'"
				console.log "gonna compile with proto: '#{@proto}'"
				if @lang isnt \ls
					return

				patch_ast = LiveScript.ast LiveScript.tokens "Mongoose = require 'Mongoose'"
				patch = patch_ast.toJSON!

				search_ast = LiveScript.ast LiveScript.tokens "Mongoose = require 'Mongooses'"
				search = search_ast.toJSON!
				j1 = JSON.stringify search.lines .replace /[,]*\"line\":[0-9]+/g, ''
				searchlen = search.lines.length

				options = {bare: true}
				res = {}
				res.tokens = LiveScript.tokens @src
				res.ast = LiveScript.ast res.tokens

				if @outfile is 'model.js'
					#console.log "ast", res.ast
					ast = JSON.parse JSON.stringify res.ast.toJSON!

					for i til width = ast.lines.length - searchlen
						# OPTIMIZE: this probably has to be the SLOWEST way to do do patching
						# IMPROVEMENT: I also want to improve patching, by maintaining variable names and the like
						# IMPROVEMENT: I want to search based on a certain pattern and replace based on that pattern
						l1 = ast.lines.slice i, i+searchlen
						j2 = JSON.stringify l1 .replace /[,]*\"line\":[0-9]+/g, ''
						if j1 is j2
							console.log "found target at line #", i
							ast.lines.splice.apply this, [i, searchlen] ++ patch.lines
							res.ast = LSAst.fromJSON ast
					#livescript.ast(livescript.tokens("\t\tif true then"))

				if res.result or true
					res.ast.makeReturn!

				res.output = res.ast.compileRoot options
				if res.result or true
					# console.log "run", res.output
					CWD = process.cwd!
					process.chdir Path.dirname res.path
					res.output = LiveScript.run res.output, options, true
					process.chdir CWD

				@impl = res.output

				if res.blueprint or true
					res.output = DaFunk.stringify res.output, <[name encantador incantation version embodies concepts eventListeners layout]>
				else if res.json
					res.output = DaFunk.stringify res.output, <[name version]>

				@emit @lang, @outfile, res.output
				if @outfile
					Fs.writeFile @outfile, res.output, (err) ~>
						if err
							@emit \error, new Error "unable to write output to #{@outfile}"
							@transition \error
						else
							@debug "wrote %s", @outfile
							@emit \success message: "compiled: '#{@outfile}' successfully"
							@transition \ready
				# else
				# 	@transition \ready
			catch e
				if ~e.message.indexOf 'Parse error'
					console.log @path, ':', e.message
				else
					console.log @path, ':', e.stack
				@transition \error, e


# class Src extends Fsm
# 	(@opts, @refs) ->
# 		if typeof opts is \string => opts = {path: opts}
# 		else if typeof opts is \object
# 			if typeof @opts.path isnt \string
# 				throw new Error "Src must have at least a path"
# 		else throw new Error "Src not initialized correctly"

# 		outfile = file = Path.basename opts.path
# 		opts.lang = switch Path.extname file
# 		| \.ls => \LiveScript
# 		| \.coffee => \coffee-script
# 		| \.js => \js
# 		| \.json => \json

# 		unless opts.outfile
# 			if ~(idx_ext = file.lastIndexOf '.')
# 				ext = if opts.ext then opts.ext else file.substr idx_ext
# 				outfile = file.substr 0, idx_ext
# 				if ~(idx_ext2 = file.substr(0, idx_ext).lastIndexOf '.')
# 					ext = if opts.ext then opts.ext else file.substr idx_ext2
# 					outfile = file.substr 0, idx_ext2
# 				switch ext
# 				| '.blueprint.ls' =>
# 					opts.blueprint = true
# 					opts.result = true
# 					ext = \.blueprint
# 					#fallthrough
# 				| '.json.ls' =>
# 					opts.result = true
# 					opts.json = true
# 					ext = \.json
# 				| otherwise =>
# 					ext = ext.replace /(?:(\.\w+)?\.\w+)?$/, (r, ex) ~>
# 						if ex is \.json then opts.json = true
# 						return ex or if opts.json then \.json else \.js

# 				if ext isnt \.js and opts.result isnt false
# 					opts.result = true
# 				outfile = outfile + ext
# 			else if opts.ext
# 				outfile = file + opts.ext
# 			else
# 				throw new Error "source file does not have an extension"

# 			opts.ext = ext
# 			opts.outfile = Path.join(opts.write, outfile)

# 		super "#{refs.prj.name}::Src(#{Path.relative refs.prj.path, opts.path})"

# 	eventListeners:
# 		transition: ->
# 			@debug "transition path %s %s", @opts.path, @namespace

# 	states:
# 		uninitialized:
# 			onenter: ->
# 				if typeof @opts.st is \object and @opts.st.mtime instanceof Date
# 					@transition \ready
# 					@exec if @opts.src => \compile else \read
# 				else Fs.stat @opts.path, (err, st) ~>
# 					if err
# 						if err.code is \ENOENT
# 							# IMPROVEMENT: use the technician's default template for the file?
# 							@opts.src = ''
# 							now = new Date
# 							@st = {mtime: now, ctime: now}
# 							@transition \ready
# 						else throw err
# 					else
# 						@st = st
# 						@transition \ready
# 						@exec \read

# 		ready:
# 			onenter: ->
# 				if @opts.watch and not @watcher
# 					@watcher = Fs.watchFile @opts.path, (evt) ~>
# 						@debug "file %s changed %s", file, @path
# 						@exec \read
# 				@emit \ready

# 			read: ->
# 				Fs.readFile @opts.path, 'utf-8', (err, data) ~>
# 					if err
# 						@transition \error
# 					else if @opts.src isnt data or true
# 						@opts.src = data
# 						@exec \compile

# 			check: ->
# 				console.log "what are we checking???"
# 				try
# 					throw new Error "..."
# 				catch e
# 					console.log e.stack

# 			compile: ->
# 				try
# 					patch_ast = LiveScript.ast LiveScript.tokens "Mongoose = require 'Mongoose'"
# 					patch = patch_ast.toJSON!

# 					search_ast = LiveScript.ast LiveScript.tokens "Mongoose = require 'Mongooses'"
# 					search = search_ast.toJSON!
# 					j1 = JSON.stringify search.lines .replace /[,]*\"line\":[0-9]+/g, ''
# 					searchlen = search.lines.length

# 					options = {bare: true}
# 					@opts.tokens = LiveScript.tokens @opts.src
# 					@opts.ast = LiveScript.ast @opts.tokens

# 					if @opts.outfile is 'model.js'
# 						#console.log "ast", @opts.ast
# 						ast = JSON.parse JSON.stringify @opts.ast.toJSON!

# 						for i til width = ast.lines.length - searchlen
# 							# OPTIMIZE: this probably has to be the SLOWEST way to do do patching
# 							# IMPROVEMENT: I also want to improve patching, by maintaining variable names and the like
# 							# IMPROVEMENT: I want to search based on a certain pattern and replace based on that pattern
# 							l1 = ast.lines.slice i, i+searchlen
# 							j2 = JSON.stringify l1 .replace /[,]*\"line\":[0-9]+/g, ''
# 							if j1 is j2
# 								console.log "found target at line #", i
# 								ast.lines.splice.apply this, [i, searchlen] ++ patch.lines
# 								@opts.ast = LSAst.fromJSON ast
# 						#livescript.ast(livescript.tokens("\t\tif true then"))

# 					if @opts.result
# 						@opts.ast.makeReturn!

# 					@opts.output = @opts.ast.compileRoot options
# 					if @opts.result
# 						process.chdir Path.dirname @opts.path
# 						@opts.output = LiveScript.run @opts.output, options, true
# 						process.chdir CWD

# 					if @opts.blueprint
# 						@opts.output = DaFunk.stringify @opts.output, <[name encantador incantation version embodies concepts eventListeners layout]>
# 					else if @opts.json
# 						@opts.output = DaFunk.stringify @opts.output, <[name version]>

# 					@refs.prj.emit @opts.ext.substr(1), @opts.outfile, @opts.output
# 					if @opts.write
# 						Fs.writeFile @opts.outfile, @opts.output, (err) ~>
# 							if err
# 								@emit \error, new Error "unable to write output to #{@opts.outfile}"
# 								@transition \error
# 							else
# 								@debug "wrote %s", @opts.outfile
# 								@emit \success message: "compiled: '#{@opts.outfile}' successfully"
# 								@transition \ready
# 					else
# 						@transition \ready
# 				catch e
# 					if ~e.message.indexOf 'Parse error'
# 						console.log @opts.path, ':', e.message
# 					else
# 						console.log @opts.path, ':', e.stack
# 					@emit \error, e
# 					@transition \error

# 		destroy:
# 			onenter: ->
# 				if s = @watcher then s.close!
# 				Fs.unlink @opts.outfile, (err) ~>
# 					if err and err.code isnt \ENOENT
# 						@emit \error err
# 					@emit \closed

# 		close:
# 			onenter: ->
# 				@emit \closed

export Implementation