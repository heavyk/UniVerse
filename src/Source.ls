
Fs = require \fs
Url = require \url
Path = require \path
# $p = require \procstreams
_ = require \lodash
Rimraf = require \rimraf
Walk = require \walkdir

Semver = require \semver
Ini = require \ini
sh = require \shelljs

# perhaps I can take advantage of fast server rollouts with zfs
# http://zef.me/6023/who-needs-git-when-you-got-zfs

# eventually I should output docker files and use libswarm
# https://github.com/docker/libswarm
# https://github.com/docker/libchan

# I imagine that we could make LiveScript compile the requires something like this:
# Object.defineProperty global, "Repo",
# 	get: ->
# 		version = module.dependencies.Repo
#  ... something like that. more later. gatta go.

# OH! the Archivista will take care of all file downloads.
# it'll be a process, that actually will save into GridFS as well
# also, I want to have it work with zofli to get best compression results
# Archivista = require \Archivista
if typeof process is \object
	process.env.MACHINA = 1234

{ ToolShed, Config, DaFunk, Fsm, Fabuloso, Machina, Debug } = require \MachineShop
{ Reality } = require Path.join __dirname, \Reality
{ LocalLibrary } = require Path.join __dirname, \LocalLibrary
debug = Debug 'Source'

# { PublicDB, LocalDB, Blueprint } = require './PublicDB'
# EtherDB = require './EtherDB' .EtherDB
# Library = require './Library' .Library

# Repo = require './repo' .Repo
ORIGINAL_CWD = process.cwd!
process.cwd AMBIENTE_PATH
SOURCE_PATH = global.SOURCE_PATH = SOURCE_PATH = process.env.SOURCE_PATH or Path.join process.env.HOME, ".Source"
SOURCE_DEPS_PATH = global.SOURCE_DEPS_PATH = Path.join SOURCE_PATH, '.deps'
SOURCE_PKGS_PATH = global.SOURCE_PKGS_PATH = Path.join SOURCE_DEPS_PATH, "npm"
MULTIVERSE = require '../multiverse'

var AMBIENTE_ID, AMBIENTE_PATH, AMBIENTE_JSON, AMBIENTE_LIB_PATH, AMBIENTE_SRC_PATH, AMBIENTE_BIN_PATH, AMBIENTE_MODULES_PATH
var TARGET_UNIVERSE
VERSE_PATH = Path.join SOURCE_PATH, ".verse"
VERSE_CONFIG_PATH = Path.join VERSE_PATH, \config.json
VERSE_PKG_JSON_PATH = Path.join VERSE_PATH, \package.json

set_uV_paths = (id) ->
	# TODO: make this a getter/setter on the global object
	AMBIENTE_ID := id
	AMBIENTE_PATH := Path.join SOURCE_PATH, id
	AMBIENTE_LIB_PATH := Path.join AMBIENTE_PATH, \lib
	AMBIENTE_SRC_PATH := Path.join AMBIENTE_PATH, \src
	AMBIENTE_BIN_PATH := Path.join AMBIENTE_PATH, \bin
	AMBIENTE_MODULES_PATH := Path.join AMBIENTE_LIB_PATH, \node_modules
	AMBIENTE_JSON := Path.join AMBIENTE_LIB_PATH, \package.json

Object.defineProperty exports, "AMBIENTE_ID", get: -> AMBIENTE_ID
Object.defineProperty exports, "AMBIENTE_PATH", get: -> AMBIENTE_PATH
Object.defineProperty exports, "AMBIENTE_JSON", get: -> AMBIENTE_JSON
Object.defineProperty exports, "AMBIENTE_MODULES_PATH", get: -> AMBIENTE_MODULES_PATH
Object.defineProperty exports, "AMBIENTE_LIB_JSON", get: -> AMBIENTE_LIB_JSON
Object.defineProperty exports, "AMBIENTE_LIB_PATH", get: -> AMBIENTE_LIB_PATH
Object.defineProperty exports, "AMBIENTE_SRC_PATH", get: -> AMBIENTE_SRC_PATH
Object.defineProperty exports, "AMBIENTE_BIN_PATH", get: -> AMBIENTE_BIN_PATH

VERSE_ID = process.env.VERSE_ID || 'shell'
VERSE_MODE = if VERSE_ID is \shell then 'client' else 'server'
uV_debug = "Verse(#{VERSE_ID})"

# TODO: prompting
# if VERSE_ID is \shell
# 	Prompt = require \prompt
# 	Prompt.message = ''
# 	Prompt.delimiter = ''
# 	Amaze = require './amaze' .Amaze

scope = {
	lala: 1234
	jaja: 1155
	mmmm: 1111
}

class Verse extends Fsm
	(amb, impl) ->
		if (impl.namespace.indexOf \Implementation) isnt 0
			throw new Error "you gatta have an Implementation"
		@ambiente = (@origin = [new Ambiente \UniVerse]).0
		console.log "welcome to Verse "

	eventListeners:
		connected: (uri) ->
			#@connected = uri
			debug "we're connected... %s", VERSE_MODE
			#if @amaze then @amaze.prompt!
		disconnected: ->
			#@connected = false
			#if @amaze then @amaze.prompt!
	states:
		uninitialized:
			onenter: ->
				task = @task 'Load Verse(main)'
				task.choke (done) -> ToolShed.mkdir VERSE_PATH, done
				unless @ambiente.initialzed
					task.push "wait for ambiente", (done) ~>
						@ambiente.on \state:ready, done
				task.push "load Verse config", (done) ->
					debug "loading gobal config: %s", VERSE_CONFIG_PATH
					cfg = Config VERSE_CONFIG_PATH
					cfg.on \ready (obj) ->
						if typeof obj.verses is \undefined
							obj.verses = {}
						Verse.CONFIG = obj
						# debug "Verse.CONFIG loaded.. verses:"
						# _.each Verse.CONFIG.verses, (v, id) ->
						# 	debug "%s::%O", id, v
						done!
				task.end (err, res) ~>
					if err then @error "unable to load Verse!"
					else
						if process.send and VERSE_ID isnt \shell
							@transition \server
						else
							@transition \main
							#@transition \connecting
	cmds:
		connect: (id) ->
			debug "connect (%s)", id
			if v = Verse.get id
				# for now, we're just going to assume everything is local (use pipes)
				#TODO: make this into a function to ignore these errors
				uri = Path.join VERSES_DIR, v.id, '.verse', 'pipe'
			debug "Verse(#{id}) has uri: #{uri}"
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
					debug "CLIENT: got remote"
					verse.remote = r
					@client[id] = client
					@emit "connected:#{id}"
					@emit \sync_scope, id
				client.on \end ~>
					debug "client connection ended"
					@transition \connecting
				client.on \fail ~>
					@client[id] = false
					debug "connect failed to %s", uri
					debug "client connect failed"
				client.on \error (ex) ~>
					@client[id] = false
					debug "client.error %s", ex.code
					if ex.code is \ENOENT
						@emit \spawn_server id
						setTimeout ->
							client.connect path: uri#, reconnect: 100
						, 1000
					else if ex.code is \ECONNREFUSED
						Fs.unlink uri, (err) ~>
							@emit \spawn_server id
					else
						debug "client connect error %s %s", ex.code, ex.stack
						@emit "connect_error:#{id}"

				debug "attempting to connect to %s", uri
				client.connect path: uri#, reconnect: 100

		sync_scope: (scope_name) ->
			debug "syncing scope #{scope_name} in connected #{VERSE_MODE} and state #{@state}"
			if VERSE_MODE isnt \server
				@remote.get_scope scope_name, (res) ~>
					dyn_scope = Scope scope_name, res
					if @amaze then @amaze.set_scope scope_name, dyn_scope
					debug "amaze = %s", typeof @amaze
					debug "setting 'set' event on dyn_scope"
					debug "got scope %s :: %O :: %O", scope_name, dyn_scope, res
					dyn_scope.on \set (prop, val) ~>
						@remote.set_scope scope_name, prop, val
					@emit "synced:#{scope_name}", dyn_scope
					@emit "synced", scope_name
			else
				throw new Error "you have an error somewhere. server shouldn't be syncing it's scope... duh"

		spawn_server: (id) ->
			debug "spawning server with #id"
			ForeverMonitor = require \forever-monitor .Monitor
			debug "spawning server with stdin: %s ", typeof process.stdin.on

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

			debug "spawn_server child: %s %s", typeof child, typeof child.on
			child.on \error ->
				debug "spawn error %O", &

			child.on \exit (code) ->
				debug "server(#id): exited with code (%s)", code

			child.on \restart (err, data) ->
				debug "restarted #id w/ args %O", &

			child.on \start (err, data) ->
				debug "started #id w/ args %O", &

			debug "saving service into: %s", id
			verse.services[id] = child
			var closing_tt
			child.on \message (msg) ->
				#debug "got message:%s data:%O", msg.type, msg
				switch msg.type
				#| \status =>
				#	debug "an unused status message"
				| \listening =>
					verse.emit \connect, id

			#IMPROVEMENT: check the contents of the pid file aed send it a kill signal if it exists, then respawn
			child.start true
			setInterval ->
				#debug "going to ping if running %s", child.running
				if child.running
					child.child.send "ping"
			, 1000

# if VERSE_ID is \shell
# 	Prompt = require \prompt
# 	Prompt.message = ''
# 	Prompt.delimiter = ''
# 	Amaze = require './amaze' .Amaze


# facilmente is the default universe
set_uV_paths \sencillo


# instead, do this as a prefix:
# https://gist.github.com/ypresto/2145498


# var AMBIENTE_PATH, AMBIENTE_JSON
# var AMBIENTE_MODULES_PATH, AMBIENTE_LIB_JSON, AMBIENTE_LIB_PATH
var UNIVERSE
var _uV

# TODO: move this over to the machina
CORES = 8
OS = switch process.platform
| \darwin => \osx
| \linux => \linux
| \android => \android
| otherwise => throw new Error "unsupported platform!"
global.ARCH = ARCH = switch process.arch
| \x64 => \x86_64
| \ia32 => \ia32
| otherwise => throw new Error "only 64 bits supported for now..."

# probably I will want to integrate the multiverse into a docker
#  https://github.com/dotcloud/docker

# UniVerse.modules.weak
#  -> rename Pkg -> Module
#  -> UniVerse.modules.mymodule['4.3.x'] (does magic to get that module)
#    -> _.each module.versions, (mod, v) ->

# class Verse extends Fsm
# 	# Verse is a singleton, so we can do this:
# 	self = {}
# 	self._id = void
# 	missing = []
# 	cmd_order = []
# 	commands = {}
# 	aliases = {}
# 	demanded = {}
# 	checks = []
# 	transforms = {}
# 	name = 'unnamed'
# 	version = '0.0.0'
# 	defaults = {}
# 	descriptions = {}
# 	description = ''
# 	usage = void
# 	wrap = null

# 	flags = {
# 		bools: {}
# 		strings: {}
# 	}

# 	(default_args, is_command = false) ->
# 		# self = this
# 		@@id := (id) ->
# 			if id isnt \shell
# 				id = Uuid.unparse Uuid.parse id
# 			Verse._id = id
# 			self
# 		if typeof default_args is \string
# 			#debug "loading verse with default args %s", default_args

# 			verse.exec \load default_args
# 			self.id default_args
# 			if id = process.env.VERSE_ID
# 				#verse.transition \hymbook
# 				if ~id.indexOf ','
# 					_.each id.split(','), (id) ->
# 						verse.exec \initialize id
# 				else
# 					verse.exec \initialize id
# 			if typeof inst is \object then return inst
# 			if process.send
# 				debug "WE GOT A VERSE_PIPE spawn"

# 		fail = (msg) ->
# 			self.showHelp!
# 			if msg then console.error msg
# 			if typeof process is \object
# 				process.exit 0
# 			else if typeof thread is \object
# 				thread.emit \err msg
# 		parseArgs = (args = []) ->
# 			if Array.isArray self._args and not args.length then args = self._args ++ args
# 			else args || []
# 			argv = {
# 				_: []
# 				self.$0
# 			}
# 			setArg = (key, val) ->
# 				#console.error "setArg", is_command, key, val#, argv
# 				num = Number val
# 				value = if typeof val isnt \string or isNaN num then val else num
# 				value = val if flags.strings[key]
# 				if val is true
# 					if typeof defaults[key] is not \undefined then value = defaults[key]
# 					if typeof defaults[key] is true then value = false
# 				if a = aliases[key]
# 					for k in a
# 						if val is true
# 							if typeof defaults[k] is not \undefined then value = defaults[k]
# 							if defaults[k] is true then value = false
# 						if t = transforms[k] then value = t value
# 				else if t = transforms[key] then value = t value
# 				if is_command is false or true
# 					setKey argv, (key.split '.'), value
# 					if a = aliases[key] then for k in a then argv[k] = argv[key]
# 				else
# 					setKey argv.cmd, (key.split '.'), value
# 					if a = aliases[key] then for k in a then argv.cmd[k] = argv.cmd[key]

# 			for key, v of flags.bools
# 				setArg key, defaults[key] || false

# 			i = 0
# 			while i < args.length
# 				arg = args[i]
# 				if arg is '--'
# 					argv._.push.apply argv._, args.slice i + 1
# 					break
# 				else
# 					if arg.match /^--.+=/
# 						m = arg.match /^--([^=]+)=(.*)/
# 						setArg m.1, m.2
# 					else if arg.match /^--no-.+/
# 						key = (arg.match /^--no-(.+)/).1
# 						setArg key, false
# 					else if arg.match /^--.+/
# 						key = (arg.match /^--(.+)/).1
# 						next = args[i + 1]
# 						if typeof next isnt \undefined and not next.match /^-/ and not flags.bools[key] and (if aliases[key] then not flags.bools[aliases[key]] else true)
# 							setArg key, next
# 							i++
# 						else
# 							if /^(true|false)$/.test next
# 								setArg key, next is 'true'
# 								i++
# 							else
# 								if demanded[key] then missing.push key
# 								else setArg key, true
# 					else
# 						if arg.match /^-[^-]+/
# 							letters = (arg.slice 1, -1).split ''
# 							broken = false
# 							j = 0
# 							while j < letters.length
# 								if letters[j + 1] and letters[j + 1].match /\W/
# 									setArg letters[j], arg.slice j + 2
# 									broken = true
# 									break
# 								else
# 									setArg letters[j], true
# 								j++
# 							if not broken
# 								key = (arg.slice -1).0
# 								if args[i + 1] and not args[i + 1].match /^-/ and not flags.bools[key] and (if aliases[key] then not flags.bools[aliases[key]] else true)
# 									setArg key, args[i + 1]
# 									i++
# 								else
# 									if args[i + 1] and /true|false/.test args[i + 1]
# 										setArg key, args[i + 1] is 'true'
# 										i++
# 									else
# 										setArg key, true
# 						else
# 							n = Number arg
# 							v = if flags.strings._ || isNaN n then arg else n
# 							argv._.push v
# 							if is_command is false and cmd_order.length and argv._.length and cc = commands[argv._.0]
# 								argv.cmd = cc.parse.call cc, args.slice i+1
# 								break
# 				i++
# 			for key, def of defaults
# 				if key not of argv and (key of demanded or key not of flags.strings)
# 					argv[key] = def
# 					argv[aliases[key]] = defaults[key] if key of aliases
# 			if demanded._ and argv._.length < demanded._
# 				fail 'Not enough non-option arguments: got ' + argv._.length + ', need at least ' + demanded._
# 			for key, v of demanded
# 				if typeof v is not \number and not argv[key]
# 					missing.push key
# 			if missing.length then fail 'Missing required arguments: ' + missing.join ', '
# 			checks.forEach ((f) ->
# 				try
# 					fail 'Argument check failed: ' + f.toString! if (f argv) is false
# 				catch err
# 					fail err)
# 			argv
# 		longest = (xs) -> Math.max.apply null, xs.map ((x) -> x.length)
# 		load_config = ->
# 		self.$0 = ((process.argv.slice 0, 2).map ((x) ->
# 			b = rebase process.cwd!, x
# 			if (x.match /^\//) && b.length < x.length then b else x)).join ' '
# 		if process.argv.1 is process.env._
# 			self.$0 = process.env._.replace (Path.dirname process.execPath) + '/', ''
# 		self.boolean = (bools) ->
# 			bools = [].slice.call arguments if not Array.isArray bools
# 			for name in bools
# 				flags.bools[name] = true
# 			self
# 		self.string = (strings) ->
# 			strings = [].slice.call arguments if not Array.isArray strings
# 			for name in strings then flags.strings[name] = true
# 			delete flags.bools[name]
# 			self
# 		self.terminal = (fn) ->
# 			verse.once \synced ->
# 				verse.exec \terminal fn
# 			self
# 		self.alias = (x, y) ->
# 			if typeof x is \object
# 				for key, val of x then self.alias key, val
# 			else
# 				if Array.isArray y
# 					for yy in y then self.alias x, yy
# 				else
# 					zs = ((aliases[x] || []).concat aliases[y] || []).concat x, y
# 					aliases[x] = zs.filter (z) -> z isnt x
# 					aliases[y] = zs.filter (z) -> z isnt y
# 			self
# 		self.demand = (keys) ->
# 			if typeof keys is 'number'
# 				demanded._ = 0 if not demanded._
# 				demanded._ += keys
# 			else
# 				if Array.isArray keys
# 					for key in keys then self.demand key
# 				else demanded[keys] = true
# 			self
# 		self.usage = (msg, opts) ->
# 			if not opts and typeof msg is \object
# 				opts = msg
# 				msg = null
# 			usage := msg
# 			if opts then self.options opts
# 			self
# 		self.check = (f) ->
# 			checks.push f
# 			self
# 		self.transform = (key, fn) ->
# 			transforms[key] = fn
# 			self
# 		self.default = (key, value) ->
# 			if typeof key is \object
# 				for k, v of key then self.default k, v
# 			else defaults[key] = value
# 			self
# 		self.describe = (key, desc) ->
# 			if typeof key is \object
# 				for k, v of keys then self.describe k, v
# 			else descriptions[key] = desc
# 			self
# 		self.description = (desc) ->
# 			description := desc
# 			self
# 		self.action = (fn) ->
# 			if is_command then self._action = fn
# 			else Verse._action = fn
# 			self
# 		self.autocomplete = (fn) ->
# 			if is_command then self._autocomplete = fn
# 			else Verse._autocomplete = fn
# 			self
# 		self.fsm = (fsm) ->
# 			if is_command then throw new Error "for now, commands cannot have fsm's -- yet"
# 			else Verse._fsm = fsm
# 			self
# 		self.init = (fn) ->
# 			if is_command
# 				#self._init = fn
# 				throw new Error "command initialization not yet supported"
# 			else Verse._init = fn
# 			self
# 		self.name = (name) ->
# 			debug "loading verse with name: %s", name
# 			Verse._name = name
# 			verse.exec \load name
# 			self
# 		self.version = (v) ->
# 			if is_command then self._version = v
# 			else Verse._version = v
# 			self
# 		self.schema = (s) ->
# 			Verse.emit \todo, "implement schemas"
# 			if is_command then self._schema = v
# 			else Verse._schema = v
# 			self
# 		self.timeout = (ms, fn) ->
# 			self._timeout = ms
# 			self._timeout_fn = fn
# 			Verse.emit \todo, "Verse.timeout(ms, fn) not yet implemented... make a pull request and help a brother out"
# 			self
# 		self.parse = (args, cb) ->
# 			debug "parse args: %O %s", args, !!is_command
# 			argv = parseArgs args
# 			debug "parsed argv (main:%s)", is_command is false
# 			if typeof cb is \function
# 				switch argv._.length is 1 and argv._.0
# 				| \version => cb Verse._version
# 				| \help =>
# 					debug "calling self.help %s %s" self.help!, cb
# 					cb self.help!
# 				| \quit => process.exit 0 # maybe this is a bit too abrupt :) perhaps a nice shutdown
# 				| otherwise => verse.exec \parse is_command, argv, cb
# 			argv
# 		self.option = self.options = (key, opt, transform_fn, defaultVal) ->
# 			if typeof key is \object
# 				(Object.keys key).forEach (k) -> self.option k, key[k]
# 			else
# 				if typeof opt is \string then opt = {describe: opt}
# 				else if typeof opt isnt \object then opt = {}
# 				if typeof transform_fn is \function then opt.transform = transform_fn
# 				else if typeof defaultVal is \undefined then defaultVal = transform_fn
# 				if ~key.indexOf '-no-'
# 					opt.default = true
# 				if ~key.indexOf '['
# 					opt.default = defaultVal or true
# 					delete opt.boolean
# 				else if ~key.indexOf '<'
# 					if typeof defaultVal isnt \undefined
# 						opt.default = defaultVal
# 					else opt.string = true
# 					opt.demand = 1
# 					delete opt.boolean
# 				else if typeof defaultVal isnt \undefined and typeof defaultVal isnt \boolean
# 					opt.default = defaultVal
# 					opt.string = true
# 				else opt.boolean = true
# 				key = key.split /[ ,|]+/
# 				if key.length > 1 and not /^[[<]/.test key.1
# 					opt.alias = key.shift! .replace /^-/, ''
# 				key = key.shift!replace '--', '' .replace 'no-', ''
# 				if key.indexOf '-' isnt -1 then key = camelcase key
# 				# ----
# 				if opt.alias then self.alias key, opt.alias
# 				if typeof opt.demand is \number then demanded[key] = opt.demand
# 				else if opt.demand then self.demand key
# 				if typeof opt.default isnt \undefined then self.default key, opt.default
# 				if opt.boolean or opt.type is \boolean then self.boolean key
# 				if opt.string or opt.type is \string then self.string key
# 				if typeof opt.transform is \function then self.transform key, opt.transform
# 				if desc = opt.describe or opt.description or opt.desc then self.describe key, desc
# 			self
# 		self.command = (cmd) ->
# 			#Verse.emit \todo, "rip off the commander command parser -- so that 'location <location>' works"
# 			#TODO: verify the command exists
# 			cmds = cmd.split RegExp ' +'
# 			c = cmds.shift!
# 			commands[c] = _argv = new Verse false, self
# 			cmd_order.push c
# 			_argv.signature = cmd
# 			_argv
# 		self.dependncy = (pkg, version) ->
# 			#TODO: add a npm dependency
# 			v = Verse._dependncies[pkg]
# 			if is_command
# 				# it should lazy load the dependency, if the dep is only used by a command
# 				if typeof v is \undefined
# 					self.emit \dep pkg, version
# 				else
# 					debug "this dependency already exists!"
# 					#TODO: add a semver check to the universe
# 			else
# 				if typeof v is \undefined
# 					Verse._dependncies[pkg] = version
# 				else
# 					debug "dependency conflict! #{v} vs. requested: #{version}"
# 					#TODO: add a semver check to the universe to see if it's the latest
# 					#  else prompt to see if we wanna upgrade
# 			self
# 		self.use = (service, opts = {}) ->
# 			#TODO: save the service, and make sure to launch it before loading is done
# 			svc = Verse._service[service]
# 			if not ~Verse.AVAILABLE_SERVICES.indexOf service
# 				debug "unknown service: #{service}"
# 			if is_command
# 				# it should lazy load the dependency, if the dep is only used by a command
# 				if typeof svc is \undefined
# 					self.emit \load_service service, opts
# 				else
# 					debug "this dependency already exists!"
# 					#TODO: add a semver check to the universe
# 			else
# 				if typeof svc is \undefined
# 					Verse._service[pkg] = service
# 				else
# 					debug "dependency conflict! #{v} vs. requested: #{version}"
# 					#TODO: add a semver check to the universe to see if it's the latest
# 					#  else prompt to see if we wanna upgrade
# 			self
# 		self.universe = (name, opts) ->
# 			#TODO: make sure to connect to this universe
# 			if is_command
# 				debug "for now, commands cannot connect to a different universe. this is soon possible"
# 				# 1. check to see if it's the same universe
# 				# 2. if it's different and not opts.autoconnect, connect to it lazily
# 				# 3. this is just a normal dnode connection to run the command over there
# 				#self._universe = new UniVerse opts, refs
# 			else
# 				debug "TODO: make sure to connect to te universe"
# 				Verse._universe = new UniVerse opts, refs
# 			self
# 		self.wrap = (cols) ->
# 			wrap := cols
# 			self
# 		self.showHelp = (fn) ->
# 			fn = console.error if not fn
# 			fn self.help!
# 		self.help = ->
# 			wordwrap = require 'wordwrap'
# 			# you can get self-help here! LOLz
# 			if is_command isnt false
# 				return "#description"
# 			keys = Object.keys (((Object.keys descriptions).concat Object.keys demanded).concat Object.keys defaults).reduce ((acc, key) ->
# 				acc[key] = true if key isnt '_'
# 				acc), {}
# 			help = [if usage then 'Usage: '+(usage.replace /\$0/g, VERSE_NAME) else "#{VERSE_NAME} v#{Verse._version}"]
# 			if description.length then help.push "  #description", ''
# 			if keys.length then help.push 'Options:'
# 			switches = keys.reduce ((acc, key) ->
# 				acc[key] = (([key].concat aliases[key] || []).map ((sw) -> (if sw.length > 1 then '--' else '-') + sw)).join ', '
# 				acc), {}
# 			switchlen = longest (Object.keys switches).map ((s) -> switches[s] || '')
# 			desclen = longest (Object.keys descriptions).map ((d) -> descriptions[d] || '')
# 			for key in keys
# 				kswitch = switches[key]
# 				desc = descriptions[key] || ''
# 				if wrap then desc = ((wordwrap switchlen + 4, wrap) desc).slice switchlen + 4
# 				spadding = (new Array Math.max switchlen - kswitch.length + 3, 0).join ' '
# 				dpadding = (new Array Math.max desclen - desc.length + 1, 0).join ' '
# 				type = null
# 				if flags.bools[key] then type = '[boolean]'
# 				if flags.strings[key] then type = '[string]'
# 				if not wrap && dpadding.length > 0 then desc += dpadding
# 				prelude = '  ' + kswitch + spadding
# 				extra = ([
# 					type
# 					if demanded[key] then '[required]' else null
# 					if typeof defaults[key] isnt \undefined then '[default: ' + defaults[key] + ']' else null
# 				].filter Boolean).join '  '
# 				body = ([desc, extra].filter Boolean).join '  '
# 				if wrap
# 					dlines = desc.split '\n'
# 					dlen = (dlines.slice -1).0.length + if dlines.length is 1 then prelude.length else 0
# 					body = desc + if dlen + extra.length > wrap - 2 then '\n' + (new Array wrap - extra.length + 1).join ' ' + extra else ((new Array wrap - extra.length - dlen + 1).join ' ') + extra
# 				help.push prelude + body
# 			help.push ''
# 			if cmd_order.length
# 				help.push 'Commands:'
# 				max_len = 0
# 				for cmd in cmd_order
# 					max_len = Math.max commands[cmd].signature.length, max_len
# 				wl = wordwrap max_len+8, process.stdout.columns-2
# 				for cmd in cmd_order
# 					sig = commands[cmd].signature
# 					help.push "  #{sig}#{wl(commands[cmd].help!).substr sig.length+2}"
# 					#help.push "  #{sig} #{commands[cmd].help!}"

# 			help.join '\n'
# 		Object.defineProperty self, '_cmds', {
# 			get: -> commands
# 		}
# 		Object.defineProperty self, 'argv', {
# 			get: parseArgs
# 			enumerable: true
# 		}
# 		/*
# 		Object.defineProperty self, 'scope', {
# 			get: ->
# 				throw new Error "could be a problem here with the scope..."
# 				scope
# 			enumerable: true
# 		}
# 		*/

# 		#TODO: save the cwd, and do an import
# 		if Array.isArray default_args then verse.on \connected ->
# 			if VERSE_MODE is \server
# 				args = _.filter default_args.slice(0), (arg) ->
# 					if typeof arg is \string and not ~arg.indexOf 'fallback.js' then arg

# 				debug "going to try parsing... %s", typeof inst
# 				argv = inst.parse args
# 				if (argv._.length is 0 and argv.version) or (argv._.length is 1 and argv._.0 is \version)
# 					exit = Verse._version
# 				else if (argv._.length is 0 and argv.help) or (argv._.length is 1 and argv._.0 is \help)
# 					exit = Verse.help!
# 				else if argv.cmd and (argv.cmd.version or argv.cmd.help)
# 					throw new Error "TODO: command versioning and help not yet implemented"
# 				if !!exit
# 					console.log if Array.isArray exit then exit.join '\n' else exit
# 					delete inst._args
# 					process.exit 0
# 				else # if cmd.trim!length
# 					debug "~~~~~~~~~~~exec server.... %s %s", process.execPath, process.execArgv.join ' '
# 					#ToolShed.exec process.execPath + ' '+ process.execArgv.join ' ', (err, code) ->
# 					return
# 					debug "execing cmd '%s'", args.join ' '
# 					verse.exec \cmd args, (ret) ->
# 						if ret not instanceof Error
# 							console.log if Array.isArray ret then ret.join '\n' else ret
# 						else
# 							console.log "ERRROR"
# 							console.log ret.message
# 						console.log "load termial"
# 						#verse.emit \load_terminal

# 			else
# 				# client
# 				console.log "we are a client???"
# 				#verse.exec \terminal, "MechanicOfTheSequence/Verse(master)"
# 		if Array.isArray default_args then self._args = default_args

class Ambiente extends Fsm # Verse
	(id, opts) ->
		# refs = uV: @
		# @refs = refs
		@id = if id => id else \sencillo
		@origin = [Infinity, id]
		@_modules = {}

		@library = new LocalLibrary [this],
			protos: __dirname + '/../protos'
			path: __dirname + '/../library'

		DaFunk.extend @, Fabuloso
		super "Ambiente(#id)", opts
		_uV := this

	states:
		uninitialized:
			onenter: ->
				# @refs.architect = @architect = new Architect @refs, name: "42"
				# @refs.library = @library = new Library @refs, name: \sencillo

				# this is a pretty interesting concept that an instantiation is extending another instantiation.
				# we could arrange these like puzzle pieces and create really dynamic machines
				# DaFunk.extend @refs.machina, @architect
				console.log "initializing..."
				console.log "TODO: install procstreams"
				if @id => console.log "@exec \load, #{@id}"
				if @id => @exec \load, @id

			'node:onenter': ->
				console.log "NODE UNIVERSE"
				err <~ ToolShed.mkdir SOURCE_DEPS_PATH
				if err => throw err
				# @refs.akasha = @akasha = new EtherDB @refs, name: \MultiVerse
				@refs.akasha = @akasha = new EtherDB @refs, name: \UniVerse

			'browser:onenter': ->
				@refs.archive = @archive = new PublicDB name: \UniVerse

		install_deps:
			onenter: ->
				#

		load_modules:
			onenter: ->
				console.log "using universe #{UNIVERSE.name} - v#{UNIVERSE.version}"
				debug "using universe #{UNIVERSE.name} - v#{UNIVERSE.version}"
				console.log "open", AMBIENTE_PATH
				repo = new Repo {uV: @}, {
					uri: AMBIENTE_PATH # AMBIENTE_LIB_PATH
				}
				console.log "opened..."
				repo.once \ready ->
					console.log "YAY! all ready"
				if err => @transition \error
				else
					@repo = repo
					uV transition \ready
			loader: ->
				load = @task "load universe modules"
				load.push (done) ->
					(err, files) <- Fs.readdir AMBIENTE_MODULES_PATH
					if err => return done err
					load_dir = @task "read node_modules dir"
					(file) <- _.each files
					load_dir.push (st_done) ->
						(err, st) <- module_dir = Fs.stat Path.join AMBIENTE_MODULES_PATH, file
						if err => return done err
						if st.isDirectory!
							# load
							(err, data) <- Fs.readFile Fs.stat Path.join module_dir, "package.json"
							if err => Rimraf module_dir, st_done
							try
								json = JSON.parse data
								if json.name and json.version
									if v = UNIVERSE.dependencies[file] and Semver.satisfies json.version
										console.log "yay for "+json.name+'@'+json.version
									/*
									@modules[json.name+'@'+json.version] = Pkg {
										name: json.name
										version: json.version
										path: Path.join repo.uri.path, \node_modules, p
										task: task
										repo: repo
									}, st_done
									*/
								else
									st_done!
							catch e
								Rimraf module_dir, st_done
						else
							st_done!
				load.end (err, res) ->
					if err => return @transition \download
					console.log "LOADED!!!!", res

				for k, v in UNIVERSE.bundle
					console.log " * ", k, "v"+v
				console.log UNIVERSE

		ready:
			onenter: ->
				console.log "we're technically ready now"
				@emit \ready
				debug "ready"

			build_pkg: ->
				# package the universe up here
				console.log "INCOMPLETE!!"

			check_update: ->
				# do a check to the download server to be sure it exists
				console.log "INCOMPLETE!!"

			hardlink_mod: (module, into, cb) ->
				# NO LONGER USED... this should be done Sencillo.modules.hardlink path, (err, mod) ->
				task = @task "hardlinking"
				mod = @modules[module]
				unless mod
					# install mod
					console.log "install mod", module

				Fs.readdir
			spawn: (bundle, bin, args) ->
				if ~(i = bundle.indexOf '@')
					bundle = bundle.substr 0, i
					version = bundle.version i+1
				else
					version = \latest

				var _bundle
				_each @UNIVERSE.bundle, (b, v) ->
					if (Semver.satisfies b.version, version) and (not _bundle or Semver.gt b.version, _bundle.version)
						_bundle = b

				if _bundle
					if path = b.bin[cmd]
						path = Path.join AMBIENTE_PATH, path
						console.log "spawning bundle binary: '#bin' with path: '#path'"
					else
						console.log "no idea dude..."
						console.log "bundle: '#bundle' bin: '#bin' args:", args
						console.log "universe bundle:", UNIVERSE.bundle

			create: (impl, ether) ->
				# this is to spawn a new instance
			connect: (impl) ->
				console.log "create!", impl._impl.idea
				if impl and impl._impl and (idea = impl._impl.idea)
					verse = new Verse impl, impl


				# for now, we assume that our execution is "node" (unless specified differently by the implementation)
				@debug.todo """
					TODO: spawn this in a separate instance
					 - [ ] compile the code
					 - [ ] write the output into a temp file (or a designated location)
					 - [ ] spawn node with this source.
					 - [ ] wrap the source in a shell (a verse) for easy communication
					"""


				# ToolShed.exec (Path.join AMBIENTE_PATH, \bin \node), [\library]


		download:
			onenter: ->
				# INCOMPLETE need to download the universe from the master universe
				# this should also read, `construct_uV`
				console.log "TODO: add updater..."
				return @transition \build
				build = @task 'download universe'
				# @updater = Updater {
				# 	manifest: "https://raw.github.com/MechanicOfTheSequence/UniVerse/master/manifest.json"
				# 	path: AMBIENTE_PATH
				# }

				build.end (err, res) ->
					console.error "done"

		bundle:
			onenter: ->
				# monitor build files with
				# https://github.com/yanush/directory-cache
				SOURCE_DEPS_PATH = Path.join SOURCE_PATH, '.deps'
				NODE_SRC_PATH = Path.join SOURCE_DEPS_PATH, \node
				BUILD_PATH = Path.join SOURCE_DEPS_PATH, \build
				BUILD_NODE = Path.join BUILD_PATH, \node

				# it would be nice to get this data from a different location :)
				TARGET_UNIVERSE = opts
				UNIVERSE := Config AMBIENTE_JSON

				NODE_VERSION = TARGET_UNIVERSE.bundle.node
				MONGO_VERSION = TARGET_UNIVERSE.bundle.mongo
				WEBKIT_VERSION = TARGET_UNIVERSE.bundle.webkit

				# INCOMPLETE: get versions / options from package.json
				# INCOMPLETE: check to see that the current version is installed, and if not, upgrade it
				# INCOMPLETE: universe should be downloaded with git!

				build = @task 'build universe'
				unless UNIVERSE.bundle => UNIVERSE.bundle = {}
				#unless UNIVERSE.dependencies => UNIVERSE.dependencies = {}
				for k, v of TARGET_UNIVERSE
					if typeof UNIVERSE[k] is \undefined
						UNIVERSE[k] = v

				# DEPS
				install_deps = (deps_done) ->
					repo = Repo {
						uV: uV
						uri: "file:"+AMBIENTE_LIB_PATH
						bootstrap: true
					}
					repo.on \ready ->
						console.log "Universe REPO emitted ready! we're done"
						deps_done ...

				# NODE
				if Semver.satisfies UNIVERSE.bundle.node, NODE_VERSION
					build.push install_deps
				else
					node = @task 'install node'
					node.choke (done) -> ToolShed.mkdir BUILD_NODE, done
					#/*
					node.choke (done) ->
						# TODO-SOON: use libgit magic instead of commandlines...
						if ToolShed.isDirectory NODE_SRC_PATH
							# OPTIMIZE: only pull if it doesn't satisfy the node version
							p = ToolShed.exec 'git pull', {cwd: NODE_SRC_PATH, stdio: \inherit}, (code) ->
								if code then done new Error "process exited with code: " + code
								else done null, {code}
						else
							p = ToolShed.exec "git clone --local git://github.com/joyent/node.git node", {cwd: SOURCE_DEPS_PATH, stdio: \inherit}, (code) ->
								if code then done new Error "process exited with code: " + code
								else then done null, {code}
					#*/
					node.choke (node_build_done) ->
						#unless ToolShed.isDirectory "#AMBIENTE_PATH/bin/node"
						#/*
						node_build = @task 'build node'
						node_build.choke (done) ->
							Rimraf Path.join(BUILD_PATH, \node), done
						node_build.choke (done) ->
							ToolShed.exec "git clone --local #{NODE_SRC_PATH} node", cwd: BUILD_PATH, done
						node_build.choke (done) ->
							ToolShed.exec 'git pull', cwd: NODE_SRC_PATH, done
						node_build.choke (done) ->
							ToolShed.exec 'git checkout -b v#{NODE_VERSION}', cwd: BUILD_NODE, done
						node_build.choke (done) ->
							# FUTURO: me gustaría sacar un chroot que sea el mismo que usa chromium o algo asi
							# eso seria mejor para compilar el universe para otras plataformas
							env = process.env <<< {
								CFLAGS: "-Os" # -march=native"
								CXXFLAGS: "-Os" # -march=native"
							}
							ToolShed.exec "./configure --prefix=#{AMBIENTE_PATH}", cwd: BUILD_NODE, done
						node_build.choke (done) ->
							ToolShed.exec "make -j#{CORES} install PORTABLE=1", cwd: BUILD_NODE, done
						node_build.choke (done) ->
							Rimraf Path.join(BUILD_PATH, \node), done
						node_build.end ->
							node_build_done ...
						#*/
						node_build_done null
					build.push (node_done) ->
						node.end (err) ->
							if err
								Rimraf NODE_SRC_PATH, ->
									node_done err
							else
								# INCOMPLETE: merge the deps here...
								UNIVERSE.bundle.'node@#{NODE_VERSION' = {
									version: NODE_VERSION
									bin:
										node: 'bin/node'
										npm: 'bin/npm'
								}
								# 1. write .Sencillo/lib/package.json
								ToolShed.writeFile AMBIENTE_LIB_JSON, JSON.stringify(UNIVERSE, null, '  ')
								# 2. open lib/ as a repository
								install_deps ->
									node_done ...
								#node_done ...
				# MONGO
				unless Semver.satisfies UNIVERSE.bundle.mongo, MONGO_VERSION
					MONGO_NAME = "mongodb-#{OS}-#{ARCH}-#{MONGO_VERSION}"
					MONGO_URL = "http://fastdl.mongodb.org/#{OS}/#{MONGO_NAME}.tgz"
					MONGO_SRC_PATH = Path.join SOURCE_DEPS_PATH, MONGO_NAME
					mongo = @task 'download mongo'
					mongo.choke (done) -> ToolShed.mkdir MONGO_SRC_PATH, ->
						done null, "mkdir done"
					mongo.push (done) ->
						#done = mongo_build_done
						mongo_local = Path.join SOURCE_DEPS_PATH, MONGO_NAME+'.tgz'
						rejects = <[bsondump mongodump mongoexport mongofiles mongoimport mongorestore mongos mongosniff mongostat mongotop mongooplog mongoperf]>
						Archivista.dl_and_untar {
							url: MONGO_URL
							file: mongo_local
							path: SOURCE_DEPS_PATH
							task: mongo
							filter: (header) -> ~rejects.indexOf header.path.substr ('bin/'+MONGO_NAME).length+1
						}, done
					mongo.choke (done) ->
						Rimraf Path.join(SOURCE_DEPS_PATH, MONGO_NAME), done
					build.push (done) ->
						mongo.end (err) ->
							UNIVERSE.bundle.mongo = TARGET_UNIVERSE.bundle.mongo
							done ...

				unless Semver.satisfies UNIVERSE.bundle.webkit, WEBKIT_VERSION
					if ToolShed.exists "/Applications/node-webkit.app"
						console.log "INCOMPLETE - make webkit"

				process.on \exit ->
					console.log "exiting"
					# console.log build.results
				build.end (err, res) ->
					console.log "build.end", &
					#throw new Error "build end"
					if err then throw err
					@transition \ready #Sencillo.priorState


				/*
				ToolShed.exec 'rm -rf node'
				ToolShed.exec "git clone #{TARGET_DIR}/.deps/node node"
				process.chdir 'node'
				ToolShed.exec 'git pull'
				*/

	cmds:
		begin: ->
			# console.log " [ * ] starting up the universe"
			@debug.info "starting up the universe"

		'node:begin': (opts, cb) ->
			console.log "begin", opts, cb
			# new StoryBook refs, opts
			# new Http
			@debug.info "starting up uV::Narrator"
			Narrator = require './Narrator' .Narrator

			cb new Narrator @refs, opts
			# walker = Walk \processes
			# walker.on \file (path, st) ->
			# 	console.log "processes:file", &

		'browser:begin': (el, cb) ->
			# refs <<< @refs
			refs.library = @library
			StoryBook = require './StoryBook' .StoryBook
			cb new StoryBook @refs, el, id

		load: (id, done) ->
			console.log "LOAD::::", id
			unless TARGET_UNIVERSE := MULTIVERSE[id]
				return
			@id = id

			# console.log "uV:", uV
			unless repos = TARGET_UNIVERSE.repos
				return

			set_uV_paths id
			empty_uV = {} <<< TARGET_UNIVERSE
			empty_uV.bundle = {}
			empty_uV.repos = {}
			console.log "going to read:" AMBIENTE_JSON
			UNIVERSE := Config AMBIENTE_JSON, empty_uV
			UNIVERSE.once \ready (config, data) ~>
				console.log "UNIVERSE READY"

				# the package should have bundle: {version, dependencies} etc.
				# @transition \install_deps
				# @transition \load_modules

				# modules_path = Path.join AMBIENTE_PATH, \node_modules
				# walker = Walk AMBIENTE_MODULES_PATH, max_depth: 1
				# walker.on \directory (path, st) ~>
				# 	console.log "dir:", path
				# 	mod_name = Path.basename path
				# 	if mod_name.0 isnt '.'
				# 		mod_path = Path.join modules_path, mod_name
				# 		pkg_json = Path.join mod_path, \package.json
				# 		task.push (done) ->
				# 			ToolShed.stat pkg_json, (err, p_st) ->
				# 				# if p_st
				# 				# 	console.log "st:", (+p_st.mtime), (+st.mtime)
				# 				# else
				# 				# 	console.log "err", err
				# 				if p_st and (+p_st.mtime < +st.mtime)
				# 					console.log "npm install .", {cwd: mod_path}
				# 					ToolShed.exec "#{AMBIENTE_BIN_PATH}/npm install .", {cwd: mod_path}, (err) ->
				# 						if err
				# 							done err
				# 						else
				# 							Fs.utimes pkg_json, st.atime, p_st.mtime, (err) ->
				# 								done err
				# 					# done!

				# task.push (done) ->
				# 	pkg_json = Path.join AMBIENTE_LIB_PATH, \package.json
				# 	ToolShed.stat AMBIENTE_LIB_PATH, (err, st) ->
				# 		if err => done err
				# 		else ToolShed.stat pkg_json, (err, p_st) ->
				# 			if p_st and (+p_st.mtime < +st.mtime)
				# 				ToolShed.exec "#{AMBIENTE_BIN_PATH}/npm install .", {cwd: AMBIENTE_LIB_PATH}, (err) ->
				# 					if err
				# 						done err
				# 					else
				# 						Fs.utimes pkg_json, st.atime, p_st.mtime, (err) ->
				# 							done err
				# 			else done err

				# for path, opts of TARGET_UNIVERSE.repos
				task = @task "fetch repos"
				task.push (done) ->	ToolShed.mkdir SOURCE_DEPS_PATH, done
				task.push (done) ->	ToolShed.mkdir AMBIENTE_PATH, done
				task.wait!
				_.each TARGET_UNIVERSE.repos, (opts, path) ->
					task.push (done) ->
						console.log "repo.get", path
						@exec \repo.get, path, opts, done

				get_version = (version) ->
					if typeof version is \string and version.indexOf('.') is version.lastIndexOf('.')
						version += '.0'
					version

				task.wait!

				_.each TARGET_UNIVERSE.bundle, (v, b) ~>
					console.log "UNIVERSE", UNIVERSE.bundle
					@debug "checking bundle: (%s@%s) satisfies (%s@%s)", b, UNIVERSE.bundle[b], b, TARGET_UNIVERSE.bundle[b]
					version = get_version UNIVERSE.bundle[b]
					wanted = get_version TARGET_UNIVERSE.bundle[b]
					console.log UNIVERSE.bundle[b], TARGET_UNIVERSE.bundle[b]
					unless Semver.satisfies version, wanted
						@debug "bundling: %s@%s", b, v
						task.push (done) ->
							@exec "bundle:#b", v, done

				task.choke (done) -> @exec \install_modules, done

				console.log "run task.end"
				(err, res) <~ task.end
				if err
					throw err
				else @transition \ready

		'repo.get': (path, opts, cmd_done) ->
			uri = Url.parse opts.upstream
			if uri.protocol isnt 'github:'
				cmd_done new Error "only github is supported for now"
			# task = @task "get #path"
			deps_path = Path.join SOURCE_DEPS_PATH, uri.hostname, uri.path
			repo_name = uri.path.substr 1
			# repo_path = Path.join deps_path, repo_name
			task = @task "checkout repo: '#path"
			task.push (done) ->
				ToolShed.stat deps_path+'/.git', (err, st) ->
					if err and err.code is \ENOENT
						ToolShed.exec "git clone -n https://github.com/#{uri.hostname}#{uri.path}.git #{deps_path}", {cwd: AMBIENTE_PATH}, ->
							ToolShed.exec "git clone #{deps_path} #{path}", {cwd: AMBIENTE_PATH}, (code) ->
								done code, path
							# ToolShed.exec "git checkout  -b default #{opts.revision || 'master'}", {cwd: deps_path}, ->
							# 	console.log "done checkout", &
					else
						# if (+st.atime - Date.now!) > 1000*60
						# 	ToolShed.exec "git fetch origin", {cwd: deps_path}, ->
						# 		console.log "done fetch", &
						checkout_path = Path.join AMBIENTE_PATH, path
						ToolShed.stat checkout_path, (err, st) ->
							if err
								if err.code is \ENOENT
									ToolShed.exec "git clone #{deps_path} #{path}", {cwd: AMBIENTE_PATH}, (err) -> done err
								else done err
							else
								ToolShed.exec "git checkout #{opts.revision || 'master'}", {cwd: checkout_path}, (code) ->
									# TODO: this is dangerous. make sure to save changes first before resetting
									if code
										ToolShed.exec "git reset --hard", cwd: checkout_path, (code) ->
											if code => done code
											else ToolShed.exec "git checkout #{opts.revision || 'master'}", {cwd: checkout_path}, done
										return
									done code
				task.end (err, res) ->
					unless err
						UNIVERSE.repos[path] = opts
					cmd_done err
			# exec ""
			# SOURCE_DEPS_PATH
		'install_modules': (cmd_done) ->
			# walker of node_modules dir comparing the package.json file time to the dir file time
			# cmd_done new Error "TODO: walk the modules dir and make sure everything is in order"
			cmd_done!

		'bundle:node': (version, cmd_done) ->
			SRC_PATH = Path.join AMBIENTE_PATH, \opt \third_party \node
			console.log "path:", SRC_PATH
			task = @task "build #version"
			task.choke (done) ->
				ToolShed.exec "git reset --hard", cwd: SRC_PATH, done
			task.choke (done) ->
				ToolShed.exec "git checkout v#{version}", cwd: SRC_PATH, done
			task.choke (done) ->
				# FUTURO: me gustaría sacar un chroot que sea el mismo que usa chromium o algo asi
				# eso seria mejor para compilar el universe para otras plataformas
				env = process.env <<< {
					CFLAGS: "-Os" # -march=native"
					CXXFLAGS: "-Os" # -march=native"
				}
				ToolShed.exec "./configure --prefix=#{AMBIENTE_PATH}", cwd: SRC_PATH, done
			task.choke (done) ->
				ToolShed.exec "make -j#{CORES} install PORTABLE=1", cwd: SRC_PATH, done
			task.end ->
				console.log "build node end", &
				UNIVERSE.bundle.node = version
				cmd_done ...

		'bundle:mongo': (version, cmd_done) ->
			# later do this with toku
			# /usr/local//Cellar/gcc/4.8.3/bin/gcc-4.8
			# https://github.com/Tokutek/mongo/blob/master/docs/building.md
			task = @task "build mongo #version"
			SRC_PATH = Path.join AMBIENTE_PATH, \opt \third_party \mongo
			task.choke (done) ->
				ToolShed.exec "git reset --hard", cwd: SRC_PATH, done
			task.choke (done) ->
				ToolShed.exec "git checkout r#{version}", cwd: SRC_PATH, done
			task.choke (done) ->
				# for some strange
				# if osx, --osx-version-min=10.9
				# if 64, add --64
				# --cc=gcc-4.8 --cxx=gcc-4.8
				prefix = AMBIENTE_PATH
				if OS is \osx
					console.log "replacing..."
					prefix = prefix.replace ToolShed.HOME_DIR+'', '~'
				extra = ''
				if ARCH is \x86_64
					extra += "--64"
				# if OS is \osx and sh.which 'gcc-4.8'
				console.log OS, ToolShed.HOME_DIR, prefix
				console.log "scons --prefix='#prefix' -j#{CORES} #extra install"
				ToolShed.exec "scons --prefix='#prefix' -j#{CORES} #extra install", cwd: SRC_PATH, done
			task.end (err) ->
				unless err
					UNIVERSE.bundle.mongo = version
				console.log "MONGO INSTALLED"
				cmd_done err

		# 'bundle:go': (version, cmd_done) ->
		# 	GO_SRC_PATH = Path.join AMBIENTE_PATH, \src, \third_party, \golang
		# 	ToolShed.stat GO_SRC_PATH, (err, st) ->
		# 		task = @task "build #version"
		# 		if err
		# 			if err.code is \ENOENT
		# 				task.choke (done) ->
		# 					ToolShed.exec "hg clone -u release https://code.google.com/p/go #{GO_SRC_PATH}", done
		# 		else
		# 			task.choke (done) ->
		# 				ToolShed.exec "hg pull", cwd: GO_SRC_PATH, (code) ->
		# 					if code
		# 						Rimraf GO_SRC_PATH, (err) ->
		# 							if err => done err
		# 							else ToolShed.exec "hg clone -u release https://code.google.com/p/go #{GO_SRC_PATH}", done

		# 		task.choke (done) ->
		# 			ToolShed.exec "hg checkout go#{version}", cwd: SRC_PATH, done
		# 		task.choke (done) ->
		# 			ToolShed.exec "sh all.bash" {cwd: "#{SRC_PATH}/src"} (err) ->
		# 				if err
		# 					console.warn "there might be an error in go:", err.message
		# 					console.log "continuing..."
		# 				# else
		# 				# 	console.log "ALL INSTALLED"
		# 				done!
		# 		task.end (err) ->
		# 			UNIVERSE.bundle.go = version
		# 			done err

		'bundle:arango': (version, cmd_done) ->
			task = @task "build arango #version"
			SRC_PATH = Path.join AMBIENTE_PATH, \opt, \third_party, \ArangoDB
			GO_PATH = Path.join SRC_PATH, \3rdParty, "go-#{if process.arch is \x64 => '64' else '32'}"
			GO_SRC_PATH = Path.join AMBIENTE_PATH, \opt, \third_party, \golang
			console.log "uV:go", UNIVERSE.bundle.go
			unless UNIVERSE.bundle.go => task.choke (done) ~> @exec \bundle:go done
			task.choke (done) ->
				Fs.lstat GO_PATH, (err, st) ->
					if st
						if st.isSymbolicLink!
							return done!
						else
							Rimraf GO_PATH (err) ->
								if err => return done err
								Fs.symlink GO_SRC_PATH, GO_PATH, done
					else
						Fs.symlink GO_SRC_PATH, GO_PATH, done
			task.push (done) ->
				ToolShed.exec "git reset --hard", cwd: SRC_PATH, done
			task.choke (done) ->
				ToolShed.exec "git checkout v#{version}", cwd: SRC_PATH, done
			task.choke (done) -> ToolShed.exec "cmake .", cwd: SRC_PATH, done
			task.choke (done) -> ToolShed.exec "automake-1.14 --add-missing", cwd: SRC_PATH, done
			task.choke (done) -> ToolShed.exec "autoreconf", cwd: SRC_PATH, done
			task.choke (done) ->
				ToolShed.exec <[ ./configure
					--enable-all-in-one-v8
					--disable-all-in-one-libev
					--enable-all-in-one-icu
					--enable-maintainer-mode
					--enable-internal-go
					--disable-mruby]>join(' ') + " --prefix=#{AMBIENTE_PATH}", cwd: SRC_PATH, done
			# task.choke (done) -> quick_exec "cmake .", done
			task.choke (done) -> ToolShed.exec "make -j#{CORES} install", cwd: SRC_PATH, done

			task.end (err) ->
				unless err
					UNIVERSE.bundle.arango = version
				cmd_done err

		'bundle:go': (cmd_done) ->
			GO_SRC_PATH = Path.join AMBIENTE_PATH, \opt, \third_party, \golang
			task = @task 'build go 1.2'
			ToolShed.stat GO_SRC_PATH, (err, st) ->
				if err
					if err.code is \ENOENT
						task.choke (done) ->
							ToolShed.exec "hg clone -u release https://code.google.com/p/go #{GO_SRC_PATH}", done
				else
					task.choke (done) ->
						ToolShed.exec "hg pull", cwd: GO_SRC_PATH, (code) ->
							if code
								Rimraf GO_SRC_PATH, (err) ->
									if err => done err
									else ToolShed.exec "hg clone -u release https://code.google.com/p/go #{GO_SRC_PATH}", done
							else done!

					task.choke (done) ->
						ToolShed.exec "hg checkout go1.2", cwd: GO_SRC_PATH, done
					task.choke (done) ->
						console.log "gonna build go now"
						ToolShed.exec "sh all.bash -j#{CORES}" {cwd: "#{GO_SRC_PATH}/src"} (err) ->
							if err
								console.warn "there might be an error in go:", err.message
								console.log "continuing..."
							# else
							# 	console.log "ALL INSTALLED"
							done!

					task.end (err) ->
						# TODO: from time to time this fails on the tests.
						# parse the output to see if it was the tests - or just don't run the tests
						UNIVERSE.bundle.go = '1.2'
						cmd_done! # err
		'process.start': (id, opts, cmd_done) ->

# # modules: Reflect.Proxy {}, {
# # 	enumerable: true
# # 	enumerate: (obj) -> Object.keys oo
# # 	hasOwn: (obj, key) -> typeof oo[key] isnt \undefined
# # 	keys: -> Object.keys oo
# # 	get: (obj, name) ->
# # 		#if uV._modules
# # 		if ~name.indexOf '@'
# # 			[name, version] = name.split '@'
# # 		unless version or version is \latest
# # 			version = \x

# # 		var vv
# # 		var mod
# # 		for k, m of uV._modules
# # 			v = k.substr 1+k.indexOf '@'
# # 			if not vv or (Semver.satisfies(v, version) and Semver.gt(v, vv))
# # 				vv = v
# # 				mod = m
# # 		uV.emit \INCOMPLETE title: "make sure to load the modules in the .deps dir"
# # 		return mod
# # }


# uV.modules = Proxy uV._modules, {
# 	enumerable: true
# 	enumerate: (obj) -> Object.keys oo
# 	hasOwn: (obj, key) -> typeof Sencillo._modules[key] isnt \undefined
# 	keys: -> Object.keys Sencillo._modules
# 	get: (obj, name) ->
# 		#if uV._modules
# 		console.log "get module:", name
# 		if ~name.indexOf '@'
# 			[name, version] = name.split '@'
# 		unless version or version is \latest
# 			version = \x

# 		var vv
# 		var mod
# 		_.each Sencillo._modules, (m, k) ->
# 			v = k.substr 1+k.indexOf '@'
# 			if not vv or (Semver.satisfies(v, version) and Semver.gt(v, vv))
# 				vv := v
# 				mod := m
# 		return mod
# export global.uV = uV
# if typeof global.abort is \undefined
# 	Object.defineProperty global, "abort", {
# 		get: ->
# 			if typeof uV.error is \function
# 				return _uV.error
# 			throw new Error " [FATAL] could not continue"
# 	}
# if typeof global.uV is \undefined
# 	Object.defineProperty global, "uV", {
# 		get: ->
# 			_uV || _uV := new UniVerse
# 			# debugger
# 			return _uV
# 	}
# Object.defineProperty exports, "uV", {
# 	get: ->
# 		_uV || _uV := new UniVerse
# 		# debugger
# 		return _uV
# }

export Ambiente