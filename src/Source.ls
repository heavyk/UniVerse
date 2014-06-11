
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
				err <~ ToolShed.mkdir SOURCE_DEPS_PATH
				if err => throw err
				if @id => @exec \load, @id

			'node:onenter': ->
				console.log "NODE UNIVERSE"
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
				#console.log "UNIVERSE", UNIVERSE
				#console.log "TARGET_UNIVERSE", TARGET_UNIVERSE

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
							console.log "build node end", &
							node_build_done ...
						#*/
						node_build_done null
					build.push (node_done) ->
						node.end (err) ->
							console.log "node done building", &
							if err
								Rimraf NODE_SRC_PATH, ->
									node_done err
							else
								# INCOMPLETE: merge the deps here...
								UNIVERSE.bundle.node = NODE_VERSION
								# 1. write .Sencillo/lib/package.json
								ToolShed.writeFile AMBIENTE_LIB_JSON, JSON.stringify(UNIVERSE, null, '  ')
								# 2. open lib/ as a repository
								install_deps ->
									console.log "emitted ready! we're done"
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
							console.log "mongo.end", &
							UNIVERSE.bundle.mongo = TARGET_UNIVERSE.bundle.mongo
							done ...

				unless Semver.satisfies UNIVERSE.bundle.webkit, WEBKIT_VERSION
					if ToolShed.exists "/Applications/node-webkit.app"
						console.log "INCOMPLETE - make webkit"

				process.on \exit ->
					console.log "exiting"
					console.log build.results
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