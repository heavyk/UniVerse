
Fs = require \fs
Path = require \path
assert = require \assert
cluster = require \cluster

# p$ = require \procstreams
# Ini = require \ini
# Github = require \github
Walk = require \walkdir
LiveScript = require \LiveScript
LSAst = require \LiveScript/lib/ast

# instead of doing source maps like this,
# I will definitely want to be doing this:
# https://github.com/blendmaster/LiveScript/tree/esprima
# { SourceMapGenerator, SourceMapConsumer, SourceNode } = require \source-map-cjs
# { SourceMapGenerator } = require \source-map-cjs

{ _, Debug, ToolShed, Fsm, Config, DaFunk } = MachineShop = require \MachineShop

# this really needs to be moved to the ambiente
VERSE_GLOBAL_CONFIG_DIR = Path.join ToolShed.HOME_DIR, '.verse'
VERSE_GLOBAL_CONFIG_PATH = Path.join VERSE_GLOBAL_CONFIG_DIR, \config.json
VERSE_CONFIG_DIR = Path.join ToolShed.HOME_DIR, '.verse', \lala
VERSE_ID = \lala
VERSE_MODE = \client

class Ether extends Fsm
	embody: (concept) ->
		DaFunk.extend this, Ether.abstracts[concept]


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
		services = {}
		client = {}
		if @initialState
			@_initialState = @initialState
		@initialState = false

		@_deps = []
		if @_impl
			if typeof (modifier = @_impl.embodies) is \string
				@embody modifier
			else if Array.isArray modifier
				_.each modifier, @embody, this

		# TODO: super impl.name, impl.id, opts
		# TODO: make the initialize function return the name
		# @namespace = \Word (will change the channel and everything)
		# @namespace = <[Word Mun]> (will change the channel and everything)
		# @namespace = <[Word Mun xyz123]> (will change the channel and everything)
		# it'd be interesting if we listened on wildcards too, for controllers
		super impl.inception, opts
		# DaFunk.extend this, Ether.abstracts.Verse
		@_dep_done!

	_dep_done: (dep) ->
		if dep
			if ~(i = @_deps.indexOf(dep))
				v = @_deps.splice i, 1
			else
				@debug.warn "you claim dep '#dep' is done. however it was never even started"

		if @_deps.length is 0 and @initialState is false
			@transitionSoon @initialState = @_initialState || \uninitialized

	initialize: ->
		self = this
		if locals = @_impl.local
			_.each locals, (uri, _where) ~>
				@_deps.push uri
				@origin.0.library.exec \get uri, (err, res) ~>
					if err
						@debug.error ''+err.stack
					else
						# if _where.0 isnt '{'
						# 	m = res[_where]
						# 	if _where is \Url
						# 		console.log "Url::", res, _where, m
						# 	if typeof m is \object or typeof m is \function => _where := "{#_where}"
						ToolShed.set_obj_path _where, self, res
						@_dep_done uri
		# in the future this will be used to persist the state for each concept / whatever
		# @_deps.push \config
		# @origin.0.library.exec \get \npm://MachineShop.Config, (err, Config) ~>
		# 	console.log "TODO: really, this should be (for o in @origin => o.name).join '.' ::", (Array.isArray @origin), (for o in @origin => o.name).join '.'
		# 	console.log "LOAD CONFIG:", Path.join @origin.0.library.path, 'config.'+@_impl.idea
		# 	@_dep_done \config
			# @config = new Config Path.join @origin.0.library.path, @_impl.name
		# @config = @Config
		# @origin.0.exec \motivator, @impl.motivator,

	eventListeners:
		connected: (uri) ->
			#@connected = uri
			@debug "we're connected... %s", VERSE_MODE
			#if @amaze then @amaze.prompt!

		disconnected: ->
			#@connected = false
			#if @amaze then @amaze.prompt!

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
				task = @task 'Load Verse(main)'
				task.choke (done) -> ToolShed.mkdir VERSE_CONFIG_DIR, done
				task.push "load Verse config", (done) ->
					@debug "loading gobal config: %s", VERSE_GLOBAL_CONFIG_PATH
					cfg = Config VERSE_GLOBAL_CONFIG_PATH
					cfg.on \ready (obj) ~>
						if typeof obj.verses is \undefined
							obj.verses = {}
						global.GLOBAL_CONFIG = obj
						@debug "GLOBAL_CONFIG loaded.. verses:"
						_.each GLOBAL_CONFIG.verses, (v, id) ->
							@debug "%s::%O", id, v
						done!
				task.end (err, res) ~>
					if err then @error "unable to load Verse!"
					else
						if process.send and VERSE_ID isnt \shell
							@transition \server
						else
							@transition \main
							#@transition \connecting
			_onExit: ->

		hymnbook:
			onenter: ->
				@debug "entered hymbook state"
				@debug "do nothing"
				@debug "TODO: launch the hymbook verse"
				#if process.send
				# TODO: make a hymbook verse
				# make dnode bindings to load the verses and everything

		main:
			onenter: ->
				@debug "entered main state... do nothing"
				@debug "check if we're connected. if not, mode:%s", VERSE_MODE
				#@exec \terminal, "MechanicOfTheSequence/Verse(master)"

			login: ->
				@debug "TODO:login event"
				@debug "prompt: username"
				@debug "prompt: password"

			spawn_server: (id) ->
				# first, try to connect to the hymbook


			parse: (is_command, argv, cb) ->
				@debug "parse: %s %O %s %s", is_command, argv, typeof cb, typeof Verse._action
				if is_command is false and typeof cb is \function
					future = new Cmd @, argv, cb
					if argv._.length and is_command is false
						cmd = argv._.0
						@debug "cmd: '%s'", cmd
						@debug "builtin cmd: %s", typeof builtins[cmd]
						@debug "inst cmd: %s", typeof inst._cmds[cmd]
						if cc = inst._cmds[cmd]
							if typeof cc._action is \function
								@debug "calling #{cmd}._action"
								cc._action.call @scope, argv, future
							else
								ret = new Error "action not implemented for command: #{cmd}"
						else if typeof (cc = builtins[cmd]) is \function
							@debug "cc %s", cc.call @scope, argv, future
						else if typeof Verse._action is \function
							Verse._action.call @scope, argv, future
						else ret = new Error "command '#{cmd}' not found"
					else if typeof Verse._init is \function
						Verse._init.call @scope, argv, future
						delete Verse._init
					else if typeof Verse._action is \function
						Verse._action.call @scope, argv, future
					else ret = new Error "no main level action"
					if typeof ret is \undefined then ret = future
					while typeof ret is \function
						ret argv, future
					future

			cmd: (id, cmd, cb) ->
				@debug "cmd '%s', mode:%s connected:%s", cmd, VERSE_MODE, @clients
				if typeof cmd is \string then cmd = cmd.split ' '
				switch VERSE_MODE
				| \client =>
					@debug "client: gonna try parsing cmd on %s", typeof @remote.cmd
					@remote.cmd cmd.join(' '), (res) ->
						@debug "remote RES:", res
						cb res
				| \server =>
					@debug "server: gonna try parsing cmd on %s", typeof inst
					inst.parse cmd, (msg, res) ->
						cb msg, res
				| otherwise =>
					@once \connected ->
						@exec \cmd cmd, (res) ->
							cb res
				if typeof cb isnt \function then throw new Error
				this

			terminal: (fn) ->
				#TODO: if new verse, transition to that state
				console.log "want to start the terminal in state:#{@state}", fn
				if typeof fn is \function and motd = fn.call @scope
					console.log motd+'\n\n'

					@debug "loading amaze with id: %s", VERSE_ID

					@amaze = new Amaze VERSE_ID, historyPath: VERSE_HISTORY_PATH
					@amaze.emit \load
					@amaze.on \exec (frag) ->
						@debug "amaze.exec -> @cmd '%s'", frag.code
						@debug "cur state %s", @state
						@exec \cmd, frag.id, frag.code, frag.result
				else
					@exec \terminal, ...

			load: (id) ->
				@debug "loading id: %s from %s", id, GLOBAL_CONFIG.verses
				if typeof (v = GLOBAL_CONFIG.verses[id]) is \object
					@exec \initialize, v
				else
					if id is '.'
						#ToolShed.stat VERSE_CONFIG_DIR
						ToolShed.searchDownwardFor "package.json" (err, path) ->
							dir = Path.dirname path
							process.chdir dir
							#@exec /import
							# pkg = require path
							# check to see if the verse exists in the PACKAGE
					else
						#v = Verse.get id
						#TODO: Move this ti Verse.get/find
						available_verses = []
						cwd = process.cwd!
						_.each GLOBAL_CONFIG.verses, (v) ->
							if cwd is v.path
								available_verses.push v
							else if v.name is id
								available_verses.push v
						@debug "available_verses %d", available_verses.length
						if available_verses.length is 0
							@transition \import
						else if available_verses.length is 1
							@debug "load up the verse: %s", available_verses.0.id
							@exec \load, available_verses.0.id
						else
							@prompt "which verse do you want to load?", available_verses

			initialize: (v) ->
				#console.log "@initialize", v
				#console.log "GLOBAL_CONFIG.verses", GLOBAL_CONFIG.verses
				@debug "TODO: check to see if this verse is already initialized"
				v = Verse.get v if typeof v is \string
				@debug "initializing verse: %O", v
				# this doesn't feel right at all...
				#process.chdir v.path
				task = @task 'initialize verse'
				task.push "load package.json" (done) ->
					cfg = Config v.pkg_json
					cfg.on \ready, (cfg) ->
						global.PACKAGE = cfg
						done!

				if VERSE_ID is \shell
					@exec \connect, v.id
					@on "connected:#{v.id}", ->
						@debug "connected to %s - TODO: do something", v.id
				else
					@debug "we are the shell(%s) -- no need to connect", @state
				#task.push "connect to the server" (done) ->
				task.choke 'making sure .verse dir exists' (done) ->
					ToolShed.mkdir VERSE_CONFIG_DIR, done
				task.push 'load verse config' (done) ->
					done!
				task.end (err, res) ->
					if VERSE_ID isnt \shell
						@transition \server
					else if @amaze
						@amaze.add_scope v
						@amaze = new Amaze VERSE_ID, historyPath: VERSE_HISTORY_PATH
						@amaze.emit \load
						@amaze.on \exec (frag) ->
							@debug "amaze.exec -> @cmd '%s'", frag.code
							@debug "cur state %s", @state
							@exec \cmd, frag.id, frag.code, frag.result
					#@exec \terminal, v.id

		import:
			onenter: ->
				try
					throw new Error 'importing...'
				catch e
					@debug e.stack
				@debug "prompt: would you like to import the current dir?"
				ToolShed.searchDownwardFor "package.json", (err, path) ->
					if err
						@debug """
						prompt: could not find any projects in this directory or below
						would you like to create a new verse in this directory? #{process.cwd!}
						"""
					else
						cfg = require path
						if cfg.name and cfg.version
							@debug """
							prompt: would you like to import this project:
								name: #{cfg.name}
								version: #{cfg.version}
								path: #{path}
							"""
							# for now we'll assume a yes
							if true
								id = Uuid.v4!
								GLOBAL_CONFIG.verses[id] = vcfg = {
									cfg.name
									cfg.version
									cfg.description
									id
									pkg_json: path
									path: Path.dirname path
								}
								@debug "added verse with the id: #{id}"
								@exec \load id
								@transition \main
						else
							@debug "project does not have a name or a version..."
							@debug "move to new"
							@transition \new

		new:
			onenter: ->
				cfg = Config Path.join process.cwd!, 'package.json'
				cfg.on \ready (cfg) ->
					unless cfg.name
						@debug "prompt: ask for the verse name (default: example)"
						cfg.name = \example
					unless cfg.version
						@debug "prompt: ask for the verse version (default: 0.0.1)"
						cfg.version \0.0.1
					global.PACKAGE = cfg
					#cfg.name
					id = Uuid.v4!
					GLOBAL_CONFIG.verses[id] = {
						cfg.name
						cfg.version
						cfg.description
						id: id
					}
					# transition ...


			github: (lala) -> console.log "local:github event", lala

		disconnected:
			onenter: ->
				console.log "TODO... reconnect and disconnected state"

		server:
			onenter: ->
				@debug "entering server state #{VERSE_ID}"
				# ----------------
				@clients = []
				if process.send
					process.on \message (msg) ->
						if msg is \ping
							process.send {
								type: \status
								clients: @clients.length
							}
				#TODO: resolve the parent scope
				#dyn_scope = Scope "Verse", scope
				dyn_scope = Config VERSE_SCOPE_PATH, scope
				dyn_scope.on \ready (dyn_scope) ~>
					# this should never happen...
					#if @amaze then @amaze.set_scope dyn_scope
					dyn_scope.on \set (prop, val) ~>
						@debug "setting property value on %d clients ", @clients.length
						for c in @clients
							c.set_scope VERSE_ID, prop, val
					#@emit \synced
					@dnode = Dnode {
						cmd: (cmd, cb) ->
							@debug "SERVER: gonna try parsing cmd %s", typeof inst
							inst.parse (if typeof cmd is \string then cmd.split ' ' else cmd), cb
						get_scope: (scope_name, cb) ->
							@debug "get_scope %s %O", scope_name, Config._[VERSE_SCOPE_PATH]
							cb Config._[VERSE_SCOPE_PATH]
					}
					@debug "attempting to start dnode server on %s", VERSE_PIPE_PATH
					@server = @dnode.listen path: VERSE_PIPE_PATH
					last_disconnect = Date.now!
					ttl_timeout = setInterval ~>
						if @clients.length <= 0 and Date.now! - last_disconnect > VERSE_TTL
							process.emit \exit 0
							clearInterval ttl_timeout
					, 2000
					@server.on \remote (remote, client) ~>
						client.on \end ~>
							@debug "ended remote connection"
							if ~(c = @clients.indexOf remote) then @clients.splice c, 1
							last_disconnect := Date.now!
						@debug "remote client connected"
						@clients.push remote
					@server.on \fail (remote) ->
						@debug "server fail %O", &
					@server.on \error (err) ~>
						@debug "attempt to listen on #{VERSE_PIPE_PATH} failed"
						if err.code is \EADDRINUSE
							#TODO: use backoff
							setTimeout (~>
								Fs.unlink VERSE_PIPE_PATH, (err) ~>
									@server.listen VERSE_PIPE_PATH
							), 5000
						else @debug "server error %s", err.stack
					@server.on \listening ->
						@debug "started dnode server on %s %s", VERSE_PIPE_PATH, typeof inst
						if process.send
							process.send {
								type: \listening
								id: VERSE_ID
								pipe: VERSE_PIPE_PATH
							}
						@emit \connected, \server
					@server.on \close ->
						@debug "server closed %O", &
					@server.on \end ->
						@debug "server end %O", &
					exit_count = 0
					process.on \exit (num) !~>
						if exit_count++ <= 0
							@debug "exiting(%s) UNLINKING PIPE %s", num, VERSE_PIPE_PATH
							Fs.unlink VERSE_PIPE_PATH, (err) ->
								console.log '\n'
						process.exit 0
						return true
				#@transition \main
	cmds:
		connect: (id) ->
			@debug "connect (%s)", id
			if v = Verse.get id
				# for now, we're just going to assume everything is local (use pipes)
				#TODO: make this into a function to ignore these errors
				uri = Path.join VERSES_DIR, v.id, '.verse', 'pipe'
			@debug "Verse(#{id}) has uri: #{uri}"
			#prolly going to want to parse the url
			if client = @client[id]
				@emit \already_connecting, id
			else
				@client[uri] = true
				client = Dnode {
					set_scope: (scope_name, prop, val) ->
						if typeof s = Scope._[scope_name] is \object
							(new Function "s,val", "s.#{prop} = val;").call null, Scope._[id], val
				}
				client.uri = uri
				client.id = id
				client.on \remote (r) ~>
					@debug "CLIENT: got remote"
					@remote = r
					@client[id] = client
					@emit "connected:#{id}"
					@exec \sync_scope, id
				client.on \end ~>
					@debug "client connection ended"
					@transition \connecting
				client.on \fail ~>
					@client[id] = false
					@debug "connect failed to %s", uri
					@debug "client connect failed"
				client.on \error (ex) ~>
					@client[id] = false
					@debug "client.error %s", ex.code
					if ex.code is \ENOENT
						@exec \spawn_server id
						setTimeout ->
							client.connect path: uri#, reconnect: 100
						, 1000
					else if ex.code is \ECONNREFUSED
						Fs.unlink uri, (err) ~>
							@exec \spawn_server id
					else
						@debug "client connect error %s %s", ex.code, ex.stack
						@emit "connect_error:#{id}"

				@debug "attempting to connect to %s", uri
				client.connect path: uri#, reconnect: 100

		sync_scope: (scope_name) ->
			@debug "syncing scope #{scope_name} in connected #{VERSE_MODE} and state #{@state}"
			if VERSE_MODE isnt \server
				@remote.get_scope scope_name, (res) ~>
					dyn_scope = Scope scope_name, res
					if @amaze then @amaze.set_scope scope_name, dyn_scope
					@debug "amaze = %s", typeof @amaze
					@debug "setting 'set' event on dyn_scope"
					@debug "got scope %s :: %O :: %O", scope_name, dyn_scope, res
					dyn_scope.on \set (prop, val) ~>
						@remote.set_scope scope_name, prop, val
					@emit "synced:#{scope_name}", dyn_scope
					@emit "synced", scope_name
			else
				throw new Error "you have an error somewhere. server shouldn't be syncing it's scope... duh"

		spawn_server: (id) ->
			@debug "spawning server with #id"
			ForeverMonitor = require \forever-monitor .Monitor
			@debug "spawning server with stdin: %s ", typeof process.stdin.on

			child = new ForeverMonitor __filename,
				command: Path.join \bin, \verse # get the universes' node processs
				silent: false,
				minUptime: 2000,
				max: 1,
				fork: true,
				options: ['--harmony-collections', '--harmony-proxies'] #, 'hymnbook'
				cwd: Path.resolve __dirname, \..
				stdio: ['pipe', 'pipe', 'pipe', 'ipc']
				env:
					VERSE_ID: id
				spawnWith:
					detached: true
				pidFile: Path.join VERSES_DIR, id, '.verse', 'pid'
				#kill-tree: false

			@debug "spawn_server child: %s %s", typeof child, typeof child.on
			child.on \error ->
				@debug "spawn error %O", &

			child.on \exit (code) ->
				@debug "server(#id): exited with code (%s)", code

			child.on \restart (err, data) ->
				@debug "restarted #id w/ args %O", &

			child.on \start (err, data) ->
				@debug "started #id w/ args %O", &

			@debug "saving service into: %s", id
			@services[id] = child
			var closing_tt
			child.on \message (msg) ~>
				#@debug "got message:%s data:%O", msg.type, msg
				switch msg.type
				#| \status =>
				#	@debug "an unused status message"
				| \listening =>
					@exec \connect, id

			#IMPROVEMENT: check the contents of the pid file aed send it a kill signal if it exists, then respawn
			child.start true
			setInterval ->
				#@debug "going to ping if running %s", child.running
				if child.running
					child.child.send "ping"
			, 1000

Ether.abstracts =
	Idea:
		'also|initialize': ->
			if concepts = @_impl.concept
				if typeof @concept isnt \object
					@concept = {}
				_.each concepts, (concept, uri) ~>
					for _where, uri of concepts
						@_deps.push uri
						@refs.library.exec \get uri, (err, res) ~>
							if err => @debug.error ''+err.stack
							else
								@concept[_where] = res
								# if _where.0 isnt '{'
								# 	m = res[_where]
								# 	if typeof m is \object or typeof m is \function => _where := "{#_where}"
								ToolShed.set_obj_path _where, @concept, res
							@_dep_done err, uri
			else
				@concepts = {}


		eventListeners:
			'*': (evt, arg1, arg2, arg3) ->
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
		'also|initialize': ->
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
		'also|initialize': (key) ->
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
				@debug.todo "moved to invalid state... if in @debug mode, try to load the bluprint so you get to make the state right there..."

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





export Ether
