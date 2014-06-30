
Fs = require \fs
Url = require \url
Path = require \path
# $p = require \procstreams
_ = require \lodash
Rimraf = require \rimraf
Walk = require \walkdir

Semver = require \semver
# Ini = require \ini
# sh = require \shelljs

# docker run  -t -i base /bin/bash

# vagrant start
# parse for export DOCKER_HOST=tcp://192.168.59.103:2375

# monitor build files with
# https://github.com/yanush/directory-cache

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
# if typeof process is \object
# 	process.env.MACHINA = 1234

{ ToolShed, Config, DaFunk, Fsm, Machina, Debug } = require \MachineShop
{ Reality } = require Path.join __dirname, \Reality
{ LocalLibrary } = require Path.join __dirname, \LocalLibrary
{ Implementation } = require Path.join __dirname, \Implementation
debug = Debug 'Source'

# { PublicDB, LocalDB, Blueprint } = require './PublicDB'
# EtherDB = require './EtherDB' .EtherDB
# Library = require './Library' .Library

# Repo = require './repo' .Repo
ORIGINAL_CWD = process.cwd!

SOURCE_PATH = global.SOURCE_PATH = SOURCE_PATH = process.env.SOURCE_PATH or Path.join process.env.HOME, ".Source"
SOURCE_DEPS_PATH = global.SOURCE_DEPS_PATH = Path.join SOURCE_PATH, '.deps'
SOURCE_PKGS_PATH = global.SOURCE_PKGS_PATH = Path.join SOURCE_DEPS_PATH, "npm"


var THE_SOURCE
var AMBIENTE_ID, AMBIENTE_PATH, AMBIENTE_JSON, AMBIENTE_LIB_PATH, AMBIENTE_INSTALL_PATH, AMBIENTE_SRC_PATH, AMBIENTE_BIN_PATH, AMBIENTE_MODULES_PATH
var TARGET_UNIVERSE, MULTIVERSE
VERSE_PATH = Path.join SOURCE_PATH, ".verse"
VERSE_CONFIG_PATH = Path.join VERSE_PATH, \config.json
VERSE_PKG_JSON_PATH = Path.join VERSE_PATH, \package.json

#TODO: move these to properties of verse
set_uV_paths = (id) ->
	AMBIENTE_ID := id
	AMBIENTE_PATH := Path.join SOURCE_PATH, id
	AMBIENTE_LIB_PATH := Path.join AMBIENTE_PATH, \lib
	AMBIENTE_SRC_PATH := Path.join AMBIENTE_PATH, \src
	AMBIENTE_BIN_PATH := Path.join AMBIENTE_PATH, \bin
	AMBIENTE_INSTALL_PATH := Path.join AMBIENTE_PATH, \opt \ambiente
	AMBIENTE_MODULES_PATH := Path.join AMBIENTE_LIB_PATH, \node_modules
	AMBIENTE_JSON := Path.join AMBIENTE_LIB_PATH, \package.json

Object.defineProperty exports, "AMBIENTE_ID", get: -> AMBIENTE_ID
Object.defineProperty exports, "AMBIENTE_PATH", get: -> AMBIENTE_PATH
Object.defineProperty exports, "AMBIENTE_JSON", get: -> AMBIENTE_JSON
Object.defineProperty exports, "AMBIENTE_MODULES_PATH", get: -> AMBIENTE_MODULES_PATH
Object.defineProperty exports, "AMBIENTE_INSTALL_PATH", get: -> AMBIENTE_INSTALL_PATH
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

# cluster = require \cluster


class Verse extends Fsm
	(ambiente, implementation) ->
		if typeof implementation is \undefined
			implementation = ambiente
			ambiente = null
		if (implementation.namespace.indexOf \Implementation) isnt 0
			throw new Error "you gatta have an Implementation"
		# @ambiente = (@origin = [new Ambiente \UniVerse]).0

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
				# this should never happen:
				# unless @ambiente.initialzed
				# 	task.push "wait for ambiente", (done) ~>
				# 		@ambiente.on \state:ready, done
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

# probably I will want to integrate the multiverse into a docker
#  https://github.com/dotcloud/docker

# UniVerse.modules.weak
#  -> rename Pkg -> Module
#  -> UniVerse.modules.mymodule['4.3.x'] (does magic to get that module)
#    -> _.each module.versions, (mod, v) ->


class Ambiente extends Fsm # Verse
	(id, opts) ->
		# refs = uV: @
		# @refs = refs
		@id = if id => id else \sencillo
		@origin = [Infinity, id]
		@_modules = {}

		# library -> akasha (this is the library in local + connections out to more)
		# library = LocalLibrary(AMBIENTE_LIB_PATH, [proto|concept|etc.])
		@bin = {}
		@library = new LocalLibrary [this],
			protos: __dirname + '/../protos'
			path: __dirname + '/../library'

		DaFunk.extend this, Fsm.Empathy
		super "Ambiente(#id)", opts
		console.log "eventListeners:", this.eventListeners.executed
		_uV := this

	states:
		uninitialized:
			onenter: ->
				@CORES = require \os .cpus!length
				@ENV = process.env
				@OS = switch process.platform
				| \darwin => \darwin
				| \linux => \linux
				| \android => \android
				| otherwise => throw new Error "unsupported platform!"
				@ARCH = switch process.arch
				| \x64 => \x64
				| \ia32 => \ia32
				| otherwise => throw new Error "only 64 bits supported for now..."

				# @refs.architect = @architect = new Architect @refs, name: "42"
				# @refs.library = @library = new Library @refs, name: \sencillo

				# this is a pretty interesting concept that an instantiation is extending another instantiation.
				# we could arrange these like puzzle pieces and create really dynamic machines
				# DaFunk.extend @refs.machina, @architect
				console.log "initializing...", @OS
				console.log "TODO: install procstreams"
				if @ENV.AMBIENTE_ID
					console.log "yay we are already docker"
					@exec \load, @id if @id
				else
					THE_SOURCE := require '../source'
					unless THE_SOURCE := DaFunk.freedom THE_SOURCE
						done new Error "could not give the source its basic funk freedom! (lol)"
						return
					#TODO: move this configuration into the source...
					config =
						cpus: @CORES
						ram: Math.max 2048, Math.floor (require \os).freemem! / 1024 / 1024 * 0.75
					switch @OS
					| \darwin =>
						console.log "HI, I'M STEVE. WE'RE GOING TO LOAD vagrant now..."
						task = @task 'initialize source'
						task.push (done) -> ToolShed.mkdir SOURCE_PATH, done
						task.push (done) ->
							(code, stdout) <~ ToolShed.exec "which vagrant"
							if @bin.vagrant = stdout.trim!
								console.log "using vagrant: #{@bin.vagrant}"
								done null, @bin.vagrant
							else
								console.error "minimum requrements for this virtualbox and vagrant"
								console.error " brew cask install virtualbox"
								console.error " brew cask install vagrant"
								console.error "(they will require you to type in your admin password"
								done new Error "minimum requirement of vagrant not satisfied"
								# ToolShed.exec "brew cask install vagrant" -> done.dover 1

						task.push (done) ~>
							(err, stdout) <~ ToolShed.exec "which docker", @env
							if @bin.docker = stdout.trim!
								console.log "using docker: #{@bin.docker}"
								done null, @bin.docker
							else
								ToolShed.exec "brew install docker" -> done.dover 1

						task.push (done) ->
							Fs.writeFile (Path.join SOURCE_PATH, \Vagrantfile), (THE_SOURCE.Vagrantfile config), done
						task.push (done) ->
							user-data = THE_SOURCE.'user-data' config
							Fs.writeFile (Path.join SOURCE_PATH, \user-data), (THE_SOURCE.'user-data' config), done

						# RETURNING WITH INTERNET
						task.wait!
						task.push (done) ~>
							(err, stdout) <~ ToolShed.exec "#{@bin.vagrant} up --provision", cwd: SOURCE_PATH
							if err => done err
							else
								done err
						# END RETURNING WITH INTERNET

						# task.choke (done) ~>
						# 	(code, stdout, stderr) <~ ToolShed.exec "#{@bin.vagrant} init"
						# 	if not code or ~stderr.indexOf 'vagrant-vm already exists'
						# 		done!
						# 	else
						# 		console.log &
						# 		done new Error "wtf?"

						# task.choke (done) ~> ToolShed.exec "#{@bin.vagrant} up", {detached: true}, done
						# task.choke (done) ~>
						# 	console.log "gets here"
						# 	(code, stdout, stderr) <~ ToolShed.exec "#{@bin.vagrant} start", {detached: true}
						# 	console.log "start:", stderr, &
						# 	if ~(i = stderr.indexOf 'export DOCKER_HOST=')
						# 		host = (stderr.substr i + 'export DOCKER_HOST='.length).trim!
						# 		if ~(i = host.indexOf '\n')
						# 			host = host.substr 0, i .trim!
						# 		done null, @docker_host = host
						# 	else if ~stderr.indexOf 'Your DOCKER_HOST env variable is already set correctly'
						# 		done null, process.env.DOCKER_HOST
						# 	else done new Error "could not load vagrant"
						# console.log "task.end"
						task.end (err, res) ~>
							throw err if err
							@docker_host = 'tcp://127.0.0.1:1133'
							if @id => @exec \load, @id

					| otherwise =>
						throw new Error "only mac is supported right now"

			# TODO: this isn't working
			'node:onenter': ->
				console.log "NODE UNIVERSE"
				err <~ ToolShed.mkdir SOURCE_DEPS_PATH
				if err => throw err
				# @refs.akasha = @akasha = new EtherDB @refs, name: \MultiVerse
				# @refs.akasha = @akasha = new EtherDB @refs, name: \UniVerse
				@debug.todo "get EtherDB working..."
				@env = {}


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

		loading:
			onenter: ->
				console.log "entered loading stage..."

			'node:onenter': ->
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
				task = @task "load ambiente in node"
				if @ENV.AMBIENTE_ID
					if @ENV.VERSE_ID
						console.log "load verse id:", @ENV.VERSE_ID

				else
					task.push (done) -> ToolShed.mkdir SOURCE_DEPS_PATH, done
					task.push (done) -> ToolShed.mkdir AMBIENTE_PATH, done
					# these are necessary for bootstrap. a little verbose, but it can be optimized later
					if typeof TARGET_UNIVERSE.prepare is \function
						task.push 'calling prepare' (done) ->
							TARGET_UNIVERSE.prepare.call @, done
					# else
					# 	throw new Error "you should have a prepare function..."
					# task.push (done) -> @exec \hardlink \src, (Path.join AMBIENTE_PATH, \src), done
					# task.push (done) -> @exec \hardlink \origin, (Path.join AMBIENTE_PATH, \origin), done
					# task.push (done) -> @exec \hardlink \node_modules/LiveScript, (Path.join AMBIENTE_PATH, \node_modules/), done
					# task.push (done) -> @exec \hardlink \node_modules/harmony-reflect, (Path.join AMBIENTE_PATH, \node_modules/), done
					# task.push (done) -> @exec \hardlink \node_modules/MachineShop, (Path.join AMBIENTE_PATH, \node_modules/), done
					# task.push (done) -> @exec \hardlink \node_modules/growl, (Path.join AMBIENTE_PATH, \node_modules/), done
					# task.push (done) -> @exec \hardlink \node_modules/prelude-ls, (Path.join AMBIENTE_PATH, \node_modules/), done
					# task.push (done) -> @exec \hardlink \node_modules/lodash, (Path.join AMBIENTE_PATH, \node_modules/), done
					# task.push (done) -> @exec \hardlink \node_modules/mkdirp, (Path.join AMBIENTE_PATH, \node_modules/), done
					# task.push (done) -> @exec \hardlink \node_modules/walkdir, (Path.join AMBIENTE_PATH, \node_modules/), done
					# task.push (done) -> @exec \hardlink \node_modules/semver, (Path.join AMBIENTE_PATH, \node_modules/), done
					# task.push (done) -> @exec \hardlink \node_modules/rimraf, (Path.join AMBIENTE_PATH, \node_modules/), done
					# task.push (done) -> @exec \hardlink \node_modules/printf, (Path.join AMBIENTE_PATH, \node_modules/), done
					# task.push (done) -> @exec \hardlink \node_modules/eventemitter3, (Path.join AMBIENTE_PATH, \node_modules/), done
					# task.push (done) -> @exec \hardlink \node_modules/postal, (Path.join AMBIENTE_PATH, \node_modules/), done
					# task.push (done) -> @exec \hardlink \node_modules/deep-diff, (Path.join AMBIENTE_PATH, \node_modules/), done
					# task.push (done) -> @exec \hardlink \multiverse.json, (Path.join AMBIENTE_PATH, \multiverse.json), done
					# task.push (done) -> @exec \hardlink \verse.js, (Path.join AMBIENTE_PATH, \verse.js), done
					# task.push (done) -> @exec \hardlink \install_salt.sh, AMBIENTE_PATH, done
				task.wait!
				# _.each TARGET_UNIVERSE.local_fs ()
				_.each TARGET_UNIVERSE.repos, (opts, path) ->
					console.log "repo.get", path
					# task.push (done) ->
					# 	console.log "repo.get", path
						# @exec \repo.get, path, opts, done

				get_version = (version) ->
					if typeof version is \string and (version.indexOf('.') is version.lastIndexOf('.'))
						version += '.0'
					else if typeof version is \object
						version = version.version
					version

				# task.wait!

				_.each TARGET_UNIVERSE.bundle, (v, b) ~>
					version = get_version UNIVERSE.ambiente[b]
					wanted = get_version TARGET_UNIVERSE.bundle[b]
					@debug "checking bundle: (%s@%s) satisfies (%s@%s)", b, version, b, wanted
					# unless Semver.satisfies version, wanted
					# 	@debug "bundling: %s@%s", b, v
					# 	task.push (done) ->
					# 		@exec "bundle:#b", v, done

				# task.choke (done) -> @exec \install_modules, done
				unless @ENV.AMBIENTE_ID
					env = {} <<< @env
					task.choke (done) ->
						Dockerfile = TARGET_UNIVERSE.Dockerfile
						console.log "run task.end", Path.join AMBIENTE_PATH, 'Dockerfile'
						# this is the machina id and will be used to identify the instances
						Dockerfile.push "ENV AMBIENTE_ID #{@id}"

						# Dockerfile.push "RUN node --harmony verse.js"
						ToolShed.writeFile (Path.join AMBIENTE_PATH, 'Dockerfile'), (Dockerfile.join '\n'), done
					# RETURNING WITH INTERNET
					task.choke (done) ->
						console.log "#{@bin.docker} build -t #{@id} ."
						(err, stdout) <~ ToolShed.exec "#{@bin.docker} build --rm=false -t #{@id} .", @env
						if not err
							# (err) <~ ToolShed.exec "#{@bin.docker} build -t #{@id} .", @env
							if ~(i = stdout.indexOf "Successfully built")
								# eg. ebb4d24bffd4
								console.log " ::: ", stdout.substr i+"Successfully built ".length, 12
								id = stdout.substr i+"Successfully built ".length, 12
								(err) <~ ToolShed.exec "#{@bin.docker} tag #id #{@id}:latest", @env
								done err
						else done err
					# END RETURNING WITH INTERNET

				task.end (err, res) ~>
					if err
						console.log "NOOOO", err
						throw err
					else @transition \ready

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

		docker: (cmd, opts, cb) ->
			cwd = ''
			if typeof opts is \function
				cb = opts
			else if typeof opts is \object
				cwd = "cd '#{opts.cwd} && " if opts.cwd
			ToolShed.exec "#cwd#{@bin.docker} run base #{cmd}", @env, cb

		load: (id, done) ->
			console.log "LOAD::::", id
			MULTIVERSE := require '../multiverse'
			unless TARGET_UNIVERSE := DaFunk.freedom MULTIVERSE[id]
				return
			@id = id

			# console.log "uV:", uV
			unless repos = TARGET_UNIVERSE.repos
				return

			set_uV_paths id
			@PATH = Path.join SOURCE_PATH, id
			@env = {
				cwd: @PATH
				env:
					PWD: @PATH
					DOCKER_HOST: @docker_host
			}
			@LIB_PATH = Path.join @PATH, \lib
			@SRC_PATH = Path.join @PATH, \src
			@BIN_PATH = Path.join @PATH, \bin
			@INSTALL_PATH = Path.join @PATH, \opt \ambiente
			@MODULES_PATH = Path.join @LIB_PATH, \node_modules
			@JSON = Path.join @LIB_PATH, \package.json
			empty_uV = {} <<< TARGET_UNIVERSE
			empty_uV.ambiente = {}
			empty_uV.repos = {}
			console.log "going to read:" @JSON
			UNIVERSE := @config = Config @JSON, empty_uV
			UNIVERSE.once \ready (config, data) ~>
				@transition \loading

		hardlink: (input, output, cmd_done) ->
			task = @task "hardlink #input -> #output"
			if (input.substr -1) is '/'
				input = Path.resolve input
				walker = Walk input
				walker.on \directory (path) ->
					task.push (done) -> @exec \hardlink path, output + (path.substr input.length+1), done
				walker.on \end ->
					task.end (err, res) ->
						if typeof cmd_done is \function => cmd_done err
			else
				if (output.substr -1) is '/'
					output = Path.join output, (Path.basename input)

				input = Path.resolve input
				output = Path.resolve output

				task.choke (done) ~>
					(err, st) <~ Fs.stat output
					if err
						if err.code is \ENOENT
							(err) <~ ToolShed.mkdir output
							done err
						done err
					else if st.isDirectory!
						# TODO: don't like this ':=' at all. make a place to store things in a task
						# output := Path.join output, (Path.basename input)
						done!
					else
						done err

				task.choke (done) ~>
					(err, st) <~ Fs.stat input
					if err
						done err
					else if st.isFile!
						(err) <~ Fs.link input, output
						if err and err.code isnt \EEXIST
							done err
						else done!
					else if st.isDirectory!
						(err) <~ ToolShed.mkdir output
						if err
							done err
						else
							# console.log "create walker #input"
							walker = Walk input, {+no_recurse}, (path, st) ~>
								src = path.substr input.length+1
								dest = Path.join output, src
								basename = Path.basename path
								if st.isFile!
									src = path.substr input.length+1
									dest = Path.join output, src
									(err) <~ Fs.link path, dest
									# XXX - if EEXIST, be sure it's a link to the same file. else force removal and a redo
									if err and err.code isnt \EEXIST
										console.log "weird error: (#input) #src -> #dest", err
										done err
									@debug "hardlink: #src -> #dest"
								else if st.isDirectory!
									task.push (done) -> @exec \hardlink path, dest, done
								# else
								# 	console.log "we have something else", path, st
							walker.on \end ~>
								# task.end (err, res) ->
								done err if typeof done is \function
					else done new Error "unknown input type. should be a file or a directory"
				task.end ->
					process.nextTick ->
						cmd_done!


		'add:verse': (name) ->
			console.log "ADD VERSE: - #name"
			# TODO: properly look this up
			impl = new Implementation @, "origin/#{name}.ls"
			impl.once \compile:success ~>
				console.log "compile:success", name
				task = @task 'run verse'
				# _.each impl._instances, (inst) ->
				# 	inst.exec \destroy
				Dockerfile = impl._impl.Dockerfile
				if typeof Dockerfile is \string
					Dockerfile = [Dockerfile]
				else if not Array.isArray Dockerfile
					Dockerfile = []
				fullname = impl.name + '-' + (version = impl._impl.version)
				# console.log "name:", name, "impl.name:", impl.name, "fullname:", fullname
				env = {} <<< @env
				impl.PATH = Path.join AMBIENTE_PATH, '.verse', fullname
				task.choke (done) -> ToolShed.mkdir (env.env.PWD = env.cwd = impl.PATH), done
				console.log "impl.PATH", impl.PATH
				if typeof impl._impl.prepare is \function
					task.choke 'calling prepare' (done) ->
						impl._impl.prepare.call impl, done
				task.choke (done) ->
					Dockerfile.unshift "FROM #{@id}:latest"
					# TODO: add maintainer
					Dockerfile.push "ENV VERSE_ID #{name}"
					Dockerfile.push "ENV VERSE_VERSION #{version}"
					console.log " -> Dockerfile:\n#{Dockerfile.join '\n'}"
					ToolShed.writeFile (Path.join AMBIENTE_PATH, '.verse', fullname, \Dockerfile), (Dockerfile.join '\n'), done
				task.choke (done) ~>
					# uid = @id + '-' + Math.random!toString 32 .substr 2
					uid = @id + '/' + fullname.toLowerCase!
					console.log "container: #uid", env
					# when running the container, use this: -v ./origin:/opt/Blueshift/origin
					# or, transfer it over ssh
					console.log "exec: #{@bin.docker} build --rm=false -t #uid .", env
					(err) <~ ToolShed.exec "#{@bin.docker} build --rm=false -t #uid .", env

					# (err) <~ ToolShed.exec "#{@bin.docker} commit #uid .", env
					# if err then return done err
					# (err) <~ ToolShed.exec "#{@bin.docker} run -t #uid node --harmony verse.js #{name} #{version}", env
				task.end (err, res) ->
					if err
						# throw err
						console.log "we encountered an error:", err.stack
					else
						# (err) <~ ToolShed.exec "#{@bin.docker} commit #uid #{@id}:#{fullname.toLowerCase!}", env
						# (err) <~ ToolShed.exec "#{@bin.docker} run -t #uid node --harmony verse.js #{name} #{version}", env

					console.log "all setup!"

			# new Implementation ...
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
				(err, st) <- ToolShed.stat deps_path+'/.git'
				if err and err.code is \ENOENT
					(err) <-! Rimraf deps_path
					(err) <-! @exec \docker "git clone -n https://github.com/#{uri.hostname}#{uri.path}.git #{deps_path}", {cwd: AMBIENTE_PATH}, (err) ->
					# done.exit it
					if err
						console.log "TODO: abstract this funcion out and deal with the errors"
						throw err
					code <-! ToolShed.exec "git clone #{deps_path} #{path}", {cwd: AMBIENTE_PATH}, (code) ->
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
								ToolShed.exec "git clone --local #{deps_path} #{path}", {cwd: AMBIENTE_PATH}, (err) -> done err
							else done err
						else
							ToolShed.exec "git checkout #{opts.revision || 'master'}", {cwd: checkout_path}, (code) ->
								# TODO: this is dangerous. make sure to save changes first before resetting
								if code
									ToolShed.exec "git reset --hard", cwd: checkout_path, (code) ->
										if code => done code
										else ToolShed.exec "git checkout #{opts.revision || 'master'}", {cwd: checkout_path}, (code) ->
											if code
												ToolShed.exec "git pull", {cwd: deps_path} (code) ->
													if code
														done code
													else done!
											else
												done!
									return
								done code
				task.end (err, res) ->
					unless err
						UNIVERSE.repos[path] = opts
					cmd_done err
		'install_modules': (cmd_done) ->
			# walker of node_modules dir comparing the package.json file time to the dir file time
			# cmd_done new Error "TODO: walk the modules dir and make sure everything is in order"
			cmd_done!

		'bundle:node': (version, cmd_done) ->
			cmd_done new Error "TODO: YOU SOULDN'T BE HERE. do this in docker"
			SRC_PATH = Path.join AMBIENTE_PATH, \opt \third_party \node
			INSTALL_PATH = Path.join AMBIENTE_INSTALL_PATH, "node-#version"
			task = @task "build #version"
			task.choke (done) ->
				ToolShed.exec "git reset --hard", cwd: SRC_PATH, done
			task.choke (done) ->
				ToolShed.exec "git checkout v#{version}", cwd: SRC_PATH, (code) ->
					if code
						ToolShed.exec "git config remote.origin.url" (code, origin) ->
							console.log "origin is:::", &
							done new Error "couldn't checkout"
					else done!
			task.choke (done) ->
				# FUTURO: me gustaría sacar un chroot que sea el mismo que usa chromium o algo asi
				# eso seria mejor para compilar el universe para otras plataformas
				env = process.env <<< {
					CFLAGS: "-Os" # -march=native"
					CXXFLAGS: "-Os" # -march=native"
				}
				ToolShed.exec "./configure --prefix=#{INSTALL_PATH}", cwd: SRC_PATH, done
			task.choke (done) ->
				ToolShed.exec "make -j#{@CORES} install PORTABLE=1", cwd: SRC_PATH, done
			task.end ->
				console.log "build node end", &
				UNIVERSE.ambiente.node = {
					version: version
					src_path: SRC_PATH
					bin:
						'node': Path.join INSTALL_PATH, \bin \node
						'npm': Path.join INSTALL_PATH, \bin \npm
				}
				cmd_done ...

		'bundle:mongo': (version, cmd_done) ->
			cmd_done new Error "TODO;: YOU SOULDN'T BE HERE. do this in docker"
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
				if @OS is \osx
					console.log "replacing..."
					prefix = prefix.replace ToolShed.HOME_DIR+'', '~'
				extra = ''
				if @ARCH is \x64
					extra += "--64"
				# if @OS is \osx and sh.which 'gcc-4.8'
				console.log @OS, ToolShed.HOME_DIR, prefix
				console.log "scons --prefix='#prefix' -j#{@CORES} #extra install"
				ToolShed.exec "scons --prefix='#prefix' -j#{@CORES} #extra install", cwd: SRC_PATH, done
			task.end (err) ->
				unless err
					UNIVERSE.ambiente.mongo = {
						version
					}
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
			cmd_done new Error "TODO;: YOU SOULDN'T BE HERE. do this in docker"
			task = @task "build arango #version"
			SRC_PATH = Path.join AMBIENTE_PATH, \opt, \third_party, \ArangoDB
			INSTALL_PATH = Path.join AMBIENTE_INSTALL_PATH, "arango-#version"
			GO_PATH = Path.join SRC_PATH, \3rdParty, "go-#{if process.arch is \x64 => '64' else '32'}"
			GO_SRC_PATH = Path.join AMBIENTE_PATH, \opt, \third_party, \golang
			unless UNIVERSE.ambiente.go => task.choke (done) ~> @exec \bundle:go done
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
				ToolShed.exec "git checkout v#{version}", cwd: SRC_PATH, (code) ->
					if code
						code, origin <-! ToolShed.exec "git config remote.origin.url", cwd: SRC_PATH
						origin = origin.trim!
						if origin.0 is '/'
							code <-! ToolShed.exec "git fetch #origin", cwd: SRC_PATH
							code <-! ToolShed.exec "git fetch origin", cwd: if origin.0 is '/' => origin.trim! else SRC_PATH
							code <-! ToolShed.exec "git fetch origin", cwd: SRC_PATH
							done.dover 1
						else
							code <- ToolShed.exec "git fetch origin", cwd: SRC_PATH
							done.dover 1
					else done!
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
					# --disable-mruby]>join(' ') + " --prefix=#{INSTALL_PATH}", cwd: SRC_PATH, done
			# task.choke (done) -> quick_exec "cmake .", done
			task.choke (done) -> ToolShed.exec "make -j#{@CORES} install", cwd: SRC_PATH, done

			task.end (err) ->
				unless err
					UNIVERSE.ambiente.arango = {
						version: version
						src_path: SRC_PATH
						bin:
							'arango-dfdb': Path.join AMBIENTE_PATH, \sbin \arango-dfdb
							'arangod': Path.join AMBIENTE_PATH, \sbin \arangod
							'arangob': Path.join AMBIENTE_PATH, \bin \arangob
							'arangodump': Path.join AMBIENTE_PATH, \bin \arangodump
							'arangoimp': Path.join AMBIENTE_PATH, \bin \arangoimp
							'arangorestore': Path.join AMBIENTE_PATH, \bin \arangorestore
							'arangosh': Path.join AMBIENTE_PATH, \bin \arangosh
							'bsondump': Path.join AMBIENTE_PATH, \bin \bsondump
							'foxx-manager': Path.join AMBIENTE_PATH, \bin \foxx-manager
					}
				cmd_done err

		'bundle:go': (cmd_done) ->
			cmd_done new Error "TODO;: YOU SOULDN'T BE HERE. do this in docker"
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
						ToolShed.exec "sh all.bash -j#{@CORES}" {cwd: "#{GO_SRC_PATH}/src"} (err) ->
							if err
								console.warn "there might be an error in go:", err.message
								console.log "continuing..."
							# else
							# 	console.log "ALL INSTALLED"
							done!

					task.end (err) ->
						# TODO: from time to time this fails on the tests.
						# parse the output to see if it was the tests - or just don't run the tests
						UNIVERSE.ambiente.go = {
							version: '1.2'
							path: GO_SRC_PATH
						}
						cmd_done! # err
		'process.start': (id, opts, cmd_done) ->

# throw new Error "Empathy:"+ Fsm.Empathy

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