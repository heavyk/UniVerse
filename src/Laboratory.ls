
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

{ _, ToolShed, Fsm, Config, DaFunk } = MachineShop = require \MachineShop
{ Debug } = ToolShed

Module = require './Module' .Module

CWD = process.cwd! #Path.resolve \..

# { PublicDB, Blueprint } = require Path.join __dirname, \.. \.. \Blueshift \src \db

# WIP
# 1. set git ini based on argv
# 2. integrate it with github
# 2a. api usage for each technician (stored in .Laboratory)
# 3. make it a verse
# 4. integrate this deeply with sencillo

# small things:
# 1. save the prompt responses to a json file (to avoid always asking them again - later, move this over to verse)
# 2. upgrade `Program.choose` to be nice and colorful like in `n`
# 3. check for README.md
# 4. compile package.json.ls
# --> keep a record of those being watched..

# exec osascript -e "delay .5" -e "tell application "node-webkit" to activate"

_log = console.log

echo = ->
	str = ''
	_.each &, (s) ->
		str += if typeof s is \object then JSON.stringify s else s + ' '
	console.log str

debug = Debug 'laboratory'

process.on \uncaughtException (e) ->
	debug "uncaught exception %s %s", e, e.stack
	if e+'' isnt \nothing
		console.log "ERRROR '#{e+''}'"
		console.log if e.stack then e.stack else "error: " +e
		console.log "\n"
		# TODO: log this to the verse error log


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


	(name, opts) ->
		self = this

		if typeof (modifier = @embodies) is \string
			@embody modifier
		else if Array.isArray modifier
			_.each modifier, @embody, this
		super name, opts

		# if modifier = @improves
		# 	_.each modifier, (mod) ->
		# 		console.log "modifier", mod
		# 		the_concept = ToolShed.get_obj_path modifier, Concept.definitions
		# 		DaFunk.extend self, the_concept

	# initialize: ->
		if locals = @local
			_.each locals, (uri, where) ~>
				console.log "get:", uri
				@refs.library.exec \get uri, (err, res) ->
					console.log "err", err
					console.log "ToolShed.set_obj_path", where, typeof self, typeof res
					ToolShed.set_obj_path where, self, res
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




class Idea extends Reality
	name: \Idea
	type: \Cardinal
	version: \0.1.0

	(@refs, opts) ->
		if typeof opts is \string
			opts = {uri}
		super ...
		if uri = opts.uri
			@refs.library.exec \get uri, (err, res) ~>
				console.log "err", err
				console.log "ToolShed.set_obj_path", where, typeof self, typeof res
				# ToolShed.set_obj_path where, self, res
				@implementation = res

	imbue: (xp) ->


class Technician extends Idea # Reality
	name: \Technician
	type: \Fixed
	version: \0.1.0
	improves:
		* \Mun
	concepts:
		* \blueprint://ProjectList@latest
	embodies:
		* \Verse
		# * \Mun
	(@refs, opts) ->
		super ...

	states:
		uninitialized:
			onenter: ->
				console.log "hey dude"


class Laboratory extends Idea


# things I'd like to add soon:
# 1. automatic project file conacatenation
# 1a. self reconfiguration (auto-reload when this file changes)
# 2. js ast transforms (falafel)
# 3. ls ast transforms (sweat ast manipulation)
# 4. npm module resolution (and host recompilation)
# 5. manifest file creation
# 6. release / zip file creation, etc.
# 7. src file based on a URI (for automatic file location resolution!!)
# 7a. file support (TODO)
# 7b. http/Request support (TODO)
# 7c. github support
# 7d. ssh and other protocols too
# 8. github hooks for receiving repo changes

# node-webkit interface:
# 1. tons of stuff, duh!

# current bugs:
# 1. for some strange reason, one time, it gave me a file rename, when the file already existed or something like that (race condition???)
# 2.

# current improvements:
# 1. automatically add index.js.ls which with either:
#  a. put exports for each of the files in src/*.ls
#  b. if concat is enabled, it'll just concat all src/* files into the resulting index.js

# quick note, I do track the package.json, but it should be dynamically configurable
# pkg_json.on \change:modules ... add a new module, etc.
# pkg_json.on \change:name ... change the project name, etc.
# pkg_json.on \change:version ... make a release, etc.
# see where I'm going here??

class Project extends Fsm
	(@opts, @refs) ->
		if typeof opts isnt \object
			throw new Error "you must pass an options object {name: '...', path: '...'}"
		unless opts.path
			throw new Error "you need a path for your project"
		else if opts.name
			opts.path = Path.join refs.lab.path, opts.name

		if typeof refs isnt \object
			throw new Error "you must pass in a reference to the lab"

		@lab = refs.lab
		@path = Path.resolve opts.path
		@name = opts.name
		unless @path => throw new Error "invalid path #{opts.path}"

		src_dir = Path.join @path, \src
		lib_dir = Path.join @path, \lib
		@dirs = {}

		# if not opts.src_dir and not opts.src_dirs
		# 	opts.src_dirs = [\src]
		# if not opts.lib_dir
		# 	opts.lib_dir = \lib
		# if not ~opts.lib_dir.indexOf path
		# 	opts.lib_dir = Path.join path, \lib

		# if not ~opts.lib_dir.indexOf path
		# 	opts.lib_dir = Path.join path, \lib

		super "Project(#{opts.name})"

	states:
		uninitialized:
			onenter: ->
				pkg_src_path = Path.join @path, "package.json.ls"
				pkg_json_path = Path.join @path, "package.json"
				pkg = @PACKAGE = Config pkg_json_path
				# pkg.once \new ->

				pkg.once \ready (config, data) ~>
					unless data
						pkg.name = @name or Path.basename @path
						pkg.version = '0.0.1'

					src_dir = Path.join @path, \src
					lib_dir = Path.join @path, \lib
					@exec \add_dir, \src, src_dir, lib_dir
					@transition \ready

		ready:
			onenter: ->
				@emit \ready
				# @refs.lab.emit 'Project:added', this

			add_dir: (name, path, into) ->
				# console.log "add dir #name - #path -> #into"
				@dirs[name] = src_dir = new SrcDir {path: path, into: into}, {prj: @}
				src_dir.once_initialized ~>
					# console.log "once_initialized SrcDir", @namespace
					# console.log "eventListeners", @eventListeners
					@emit \SrcDir:added, src_dir


		new:
			onenter: ->
				/*
				pkg_src = Src {
					path: pkg_src_path
					output: "name: 'untitled'"
					write: path
					watch: true
				}
				*/
				pkg.name = opts.name or Path.basename @path
				pkg.version = '0.0.1'

		close:
			onenter: ->
				_.each @dirs, (dir) ->
					dir.transition \close

class SrcDir extends Fsm
	(@opts, @refs) ->
		if typeof opts isnt \object
			throw new Error "SrcDir needs an object"
		if typeof opts.path isnt \string
			throw new Error "path must be provided"

		@dirs = {}
		@srcs = {}

		super "#{refs.prj.name}::SrcDir(#{Path.relative refs.prj.path, opts.path})"

	states:
		uninitialized:
			onenter: ->
				if @opts.into
					ToolShed.mkdir @opts.into, (err) ~>
						if err
							@emit \error new Error "SrcDir already exists"
							@transition \error
				else @opts.into = @opts.path

				if @opts.st and @opts.st.isDirectory!
					@transition \ready
					@exec \walk
				else Fs.stat @opts.path, (err, st) ~>
					if err
						if err.code is \ENOENT
							ToolShed.mkdir @opts.path, (err) ~>
								@emit \error err
								@transition \error
						else
							@emit \error, err
							@transition \error
					else if st.isDirectory!
						@transition \ready
						@exec \walk
					else
						@emit \error new Error "SrcDir already exists"
						@transition \error

		ready:
			onenter: ->
				@emit \ready

			rescan: ->
				console.log "XXX: we should be rescanning now"

			walk: ->
				@watcher = Fs.watch @opts.path, (evt, filename) ~>
					echo "disturbance", evt, filename, @opts.path
					if evt is \change
						if filename and s = @srcs[filename]
							s.exec \read
						else _.each @srcs, (s) ~>
							s.exec \check
					else if evt is \rename
						console.log "XXX: src file renaming not yet supported!!", &
						unless filename
							@transition \walk
						else
							if s = @srcs[filename]
								s.transition \destroy
								delete @srcs[filename]
							else if s = @dirs[filename]
								s.transition \destroy
								delete @dirs[filename]
							else
								path = Path.join @opts.path, filename
								Fs.stat path, (err, st) ~>
									unless err
										if st.isFile!
											switch ext = Path.extname filename
											#| \.ls \.coffee \.js => @srcs.push Src path, st
											#| \.ls => @srcs[filename] = new Src {path, file: filename, write: @opts.into, st, dir}
											| \.ls => @exec \add_src filename, path, @opts.into, st
										else if st.isDirectory!
											into_dir = Path.join @opts.into, filename
											@exec \add_dir filename, path, into_dir

				process.nextTick ~>
					d = Walk @opts.path, max_depth: 1
					d.on \error (err) ~>
						console.log "we got an error:", &
						# throw err
					d.on \end ~>
						@transition \ready
					d.on \file (path, st) ~>
						file = Path.basename path
						unless @srcs[file]
							switch ext = Path.extname file
							#| \.ls \.coffee \.js => @srcs.push Src path, st
							#| \.ls => @srcs[file] = new Src {path, file, write: @opts.into, st, dir}
							| \.ls => @exec \add_src file, path, @opts.into, st
					d.on \directory (path, st) ~>
						dir_name = Path.basename path
						into_dir = Path.join @opts.into, dir_name
						@exec \add_dir dir_name, path, into_dir

			add_src: (name, path, into, st) ->
				#TODO: check to see if src already exists
				# console.log "add src #name - #path -> #into"
				if @dirs[name]
					throw new Error "dir: #{name} already exists"
				@srcs[name] = src = new Src {path, file: name, write: into, st}, {prj: @refs.prj, dir: @}
				src.once_initialized ~>
					assert this instanceof SrcDir
					# console.log "once_initialized Src", @namespace
					@emit \new:Src, src

			add_dir: (name, path, into) ->
				#TODO: check to see if src_dir already exists
				# console.log "add dir #name - #path -> #into"
				if @dirs[name]
					throw new Error "dir: #{name} already exists"
				@dirs[name] = src_dir = new SrcDir {name, path, into}, {prj: @refs.prj, dir: @}
				src_dir.once_initialized ~>
					assert this instanceof SrcDir
					# console.log "once_initialized SrcDir ...", @namespace
					@emit \SrcDir:added, src_dir

		close:
			onenter: ->
				@watcher.close!
				console.log "closing..."
				_.each @dirs, (d, k) ~>
					d.transition \close
					delete @dirs[k]
				_.each @srcs, (s, k) ~>
					s.transition \close
					delete @srcs[k]
				@emit \closed


class Src extends Fsm
	(@opts, @refs) ->
		if typeof opts is \string => opts = {path: opts}
		else if typeof opts is \object
			if typeof @opts.path isnt \string
				throw new Error "Src must have at least a path"
		else throw new Error "Src not initialized correctly"

		outfile = file = Path.basename opts.path
		opts.lang = switch Path.extname file
		| \.ls => \LiveScript
		| \.coffee => \coffee-script
		| \.js => \js
		| \.json => \json

		unless opts.outfile
			if ~(idx_ext = file.lastIndexOf '.')
				ext = if opts.ext then opts.ext else file.substr idx_ext
				outfile = file.substr 0, idx_ext
				if ~(idx_ext2 = file.substr(0, idx_ext).lastIndexOf '.')
					ext = if opts.ext then opts.ext else file.substr idx_ext2
					outfile = file.substr 0, idx_ext2
				switch ext
				| '.blueprint.ls' =>
					opts.blueprint = true
					opts.result = true
					ext = \.blueprint
					#fallthrough
				| '.json.ls' =>
					opts.result = true
					opts.json = true
					ext = \.json
				| otherwise =>
					ext = ext.replace /(?:(\.\w+)?\.\w+)?$/, (r, ex) ~>
						if ex is \.json then opts.json = true
						return ex or if opts.json then \.json else \.js

				if ext isnt \.js and opts.result isnt false
					opts.result = true
				outfile = outfile + ext
			else if opts.ext
				outfile = file + opts.ext
			else
				throw new Error "source file does not have an extension"

			opts.ext = ext
			opts.outfile = Path.join(opts.write, outfile)

		super "#{refs.prj.name}::Src(#{Path.relative refs.prj.path, opts.path})"

	eventListeners:
		transition: ->
			@debug "transition path %s %s", @opts.path, @namespace

	states:
		uninitialized:
			onenter: ->
				if typeof @opts.st is \object and @opts.st.mtime instanceof Date
					@transition \ready
					@exec if @opts.src => \compile else \read
				else Fs.stat @opts.path, (err, st) ~>
					if err
						if err.code is \ENOENT
							# IMPROVEMENT: use the technician's default template for the file?
							@opts.src = ''
							now = new Date
							@st = {mtime: now, ctime: now}
							@transition \ready
						else throw err
					else
						@st = st
						@transition \ready
						@exec \read

		ready:
			onenter: ->
				if @opts.watch and not @watcher
					@watcher = Fs.watchFile @opts.path, (evt) ~>
						@debug "file %s changed %s", file, @path
						@exec \read
				@emit \ready

			read: ->
				Fs.readFile @opts.path, 'utf-8', (err, data) ~>
					if err
						@transition \error
					else if @opts.src isnt data or true
						@opts.src = data
						@exec \compile

			check: ->
				console.log "what are we checking???"
				try
					throw new Error "..."
				catch e
					console.log e.stack

			compile: ->
				try
					patch_ast = LiveScript.ast LiveScript.tokens "Mongoose = require 'Mongoose'"
					patch = patch_ast.toJSON!

					search_ast = LiveScript.ast LiveScript.tokens "Mongoose = require 'Mongooses'"
					search = search_ast.toJSON!
					j1 = JSON.stringify search.lines .replace /[,]*\"line\":[0-9]+/g, ''
					searchlen = search.lines.length

					options = {bare: true}
					@opts.tokens = LiveScript.tokens @opts.src
					@opts.ast = LiveScript.ast @opts.tokens

					if @opts.outfile is 'model.js'
						#console.log "ast", @opts.ast
						ast = JSON.parse JSON.stringify @opts.ast.toJSON!

						for i til width = ast.lines.length - searchlen
							# OPTIMIZE: this probably has to be the SLOWEST way to do do patching
							# IMPROVEMENT: I also want to improve patching, by maintaining variable names and the like
							# IMPROVEMENT: I want to search based on a certain pattern and replace based on that pattern
							l1 = ast.lines.slice i, i+searchlen
							j2 = JSON.stringify l1 .replace /[,]*\"line\":[0-9]+/g, ''
							if j1 is j2
								console.log "found target at line #", i
								ast.lines.splice.apply this, [i, searchlen] ++ patch.lines
								@opts.ast = LSAst.fromJSON ast
						#livescript.ast(livescript.tokens("\t\tif true then"))

					if @opts.result
						@opts.ast.makeReturn!

					@opts.output = @opts.ast.compileRoot options
					if @opts.result
						process.chdir Path.dirname @opts.path
						@opts.output = LiveScript.run @opts.output, options, true
						process.chdir CWD

					if @opts.blueprint
						@opts.output = DaFunk.stringify @opts.output, <[name encantador incantation version embodies concepts eventListeners layout]>
					else if @opts.json
						@opts.output = DaFunk.stringify @opts.output, <[name version]>

					@refs.prj.emit @opts.ext.substr(1), @opts.outfile, @opts.output
					if @opts.write
						Fs.writeFile @opts.outfile, @opts.output, (err) ~>
							if err
								@emit \error, new Error "unable to write output to #{@opts.outfile}"
								@transition \error
							else
								@debug "wrote %s", @opts.outfile
								@emit \success message: "compiled: '#{@opts.outfile}' successfully"
								@transition \ready
					else
						@transition \ready
				catch e
					if ~e.message.indexOf 'Parse error'
						console.log @opts.path, ':', e.message
					else
						console.log @opts.path, ':', e.stack
					@emit \error, e
					@transition \error

		destroy:
			onenter: ->
				if s = @watcher then s.close!
				Fs.unlink @opts.outfile, (err) ~>
					if err and err.code isnt \ENOENT
						@emit \error err
					@emit \closed

		close:
			onenter: ->
				@emit \closed

/*

lab = new Fsm {
	initialize: ->
		echo "welcome to my laboratory!"

	states:
		uninitialized:
			onenter: ->
				# ...
				ToolShed.mkdir LAB_PATH, (res) ->
					if res instanceof Error
						lab.emit \error, "could not initialize data directory!"
						lab.transition \error
					else if typeof res is \string
						# newly created, initialize the dir
						lab.transition \add_technician
					else lab.transition \load_technician

		init_repo:
			onenter: ->

		load_technician:
			onenter: ->
				if lab.technician
					console.log 'TODO:get technician data from the data store'

				else
					#echo "choose your character"
					technician_list = Object.keys TECHNICIANS
					Program.choose technician_list.concat('New character'), (i) ->
						if i is technician_list.length
							console "NEW TECHNICIAN!"
							console "INCOMPLETE!!"
						else if u = technician_list[i]
							technician = TECHNICIANS[u]
							echo "you choose", i, technician
							# check to see if git is configured in this directory
							if technician.git or technician.github or technician.gitlab
								Fs.readFile "./.git/config", 'utf-8', (err, data) ->
									#console.log "readfile", &
									if err
										if err.code is \ENOENT
											# not a git repository
											Program.confirm "git repository does not exist. create one?", (ok) ->
												if ok
													echo "initializing git..."
													task = lab.task 'init dir'
													task.push (done) ->
														p$ 'git init'
															.on \exit, (code) ->
																if code
																	emit \error, err = new Error "we could not init the git repository for some reason..."
																	lab.transition \error
																done err
													#p$ 'touch README.md'
													task.push (done) ->
														ToolShed.mkdir './src', done
													task.push (done) ->
														ToolShed.mkdir './lib', done
													#task.push (done) ->
													#	Updater {}
													#	Repository {}

												else
													echo "ok, no need for a repository then..."
									else
										# read the ini file
										console.log "TODO: read the ini file"
										lab._git_config = Ini.parse data
										console.log "INI", lab._git_config
										lab.transition \check_git_config
							else
								@emit \error "unidentified technician type"
								@transition \error


		check_git_config:
			onenter: ->
				#console.log PACKAGE.git
				git_config = lab._git_config
				if typeof git_config is \object
					unless _.isEqual gv = technician.technician, ini.technician
						debug "different technicians!"
						if typeof gv is \object
							ini.technician <<< gv
							console.log "writing ..."
							ToolShed.writeFile Path.join(".git", \config), Ini.stringify ini
		add_technician:
			onenter: ->
				echo "create an account"
				Program.choose [
					"GitHub technician"
					"GitLab technician"
				], (i) ->
					switch i
					| 0 \github =>

					| 1 \gitlab =>
}

class User
	(manifest) ->
		console.log "welcome!"

*/


export Laboratory
export Project
export SrcDir
export Src
