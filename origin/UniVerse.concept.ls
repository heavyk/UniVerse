
# charting / graph library
# http://dc-js.github.io/dc.js/

# credit card form
# http://jessepollak.github.io/card/

# split the ssl into a subsystem
# https://github.com/gozdal/accessl/

idea: \UniVerse
version: \0.1.0
type: \Abstract
description: "the origin of Reality"
proto: \universe
embodies:
	* \Idea
	* \Verse
	* \Interactivity

local:
	Fs:
		\node://fs
	Path:
		\node://path
	Walk:
		\npm://walkdir
	# Rimraf:
	# 	\npm://rimraf
	# Semver:
	# 	\npm://semver
	# Ini:
	# 	\npm://ini
	MachineShop:
		\npm://MachineShop
	ToolShed:
		\npm://MachineShop.ToolShed
	Config:
		\npm://MachineShop.Config

concept:
	Library:
		\concept://Library
	Architect:
		\concept://Architect
	Ambiente:
		\concept://Ambiente

# poetry:
# 	Word:
# 		Technician:			\latest
# 		Project:				\latest

# ether:
# 	Service:
# 		Http:
# 			Experience:		\latest
# 			Image:				\latest
# 	Narrator:
# 		Poem:
# 			Universe:			\latest


# TODO: make this possible, but the short form should be used when possible
# TODO: to make short-form possible, Word should define its proto as "blueprint"
# TODO: Service.proto = \proroces
# TODO: Http.proto = \http
# TODO: Poem.proto = \poem
# mutable:
# TODO: Word.proto = \xp
# TODO: Verse.proto = \quest
# cardinal:
# TODO: Form.concept = \word
# TODO: Word.concept = \word
# TODO: Form.proto = \xp

# TODO: short form
concept:
	Library: origin: \0.1.0
		Local: \0.1.0
		PublicDB: \0.1.0
		EtherDB: \0.1.0
	Architect: \0.1.0
	Ambiente: \0.1.0
	StoryBook: \0.1.0
	Word: origin: \0.1.0
		Technician: \0.1.0
		Project: \0.1.0
	Service: origin: \0.1.0
		Http: origin:	\0.1.0
			Experience: \0.1.0
			Image: \0.1.0
	Narrator: origin: \0.1.0
		Poem: origin: \0.1.0
			UniVerse: \0.1.0

# long form:
# concept:
# 	Library:
# 		\concept://Library
# 	Architect:
# 		\concept://Architect
# 	Ambiente:
# 		\concept://Ambiente
# 	Word: origin: \concept://Word
# 		Technician:
# 			\blueprint://Technician
# 		Project:
# 			\blueprint://Project
# 	Service: origin: \concept://Service
# 		Http: origin:	\process://Http
# 			Experience:
# 				\http://Experience
# 			Image:
# 				\http://Experience
# 	Narrator: origin: \concept://Narrator
# 		Poem: origin: \concept://Poem
# 			UniVerse:
# 				\poem://UniVerse


ambiente: ->
	@process = process

machina:
	brand: (E) -> @name "UniVerse"
	initialize: ->
		# TODO: do the constant resolution here
		@env = env = new ToolShed.Environment

		@MULTIVERSE_PATH = @process.env.MULTIVERSE_PATH or @env.HOME_DIR, ".UniVerse"
		@MULTIVERSE_DEPS_PATH = @Path.join MULTIVERSE_PATH, '.deps'
		@MULTIVERSE_PKGS_PATH = @Path.join MULTIVERSE_DEPS_PATH, "npm"
		if not @UNIVERSE_ID
			@UNIVERSE_ID = \sencillo
		@_set_uV_paths!

	_set_uV_paths: ->
		id = @UNIVERSE_ID
		@UNIVERSE_PATH = @Path.join @MULTIVERSE_PATH, id
		@UNIVERSE_LIB_PATH = @Path.join @UNIVERSE_PATH, \lib
		@UNIVERSE_SRC_PATH = @Path.join @UNIVERSE_PATH, \src
		@UNIVERSE_BIN_PATH = @Path.join @UNIVERSE_PATH, \bin
		@UNIVERSE_MODULES_PATH = @Path.join @UNIVERSE_LIB_PATH, \node_modules
		@UNIVERSE_JSON = @Path.join @UNIVERSE_LIB_PATH, \package.json


	states:
		uninitialized:
			onenter: ->
				@refs.architect = @architect = new @concept.Architect @refs, name: "42"
				@refs.library = @library = new @concept.Library @refs, name: \sencillo

				# this is a pretty interesting concept that an instantiation is extending another instantiation.
				# we could arrange these like puzzle pieces and create really dynamic machines
				DaFunk.extend @refs.machina, @architect
				console.log "initializing..."
				console.log "TODO: install procstreams"
				if @id
					@path = @Path.join MULTIVERSE_PATH, @id
					console.log "mkdir", @path
					ToolShed.mkdir @path, (err) ~>
						if err
							console.log "ERROR MAKING DIR", err
							throw err
						# UNIVERSE.path = @path

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
				console.log "open", UNIVERSE_PATH
				repo = new Repo {uV: @}, {
					uri: @UNIVERSE_PATH # UNIVERSE_LIB_PATH
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
					(err, files) <- @Fs.readdir UNIVERSE_MODULES_PATH
					if err => return done err
					load_dir = load.branch "read node_modules dir"
					(file) <- _.each files
					load_dir.push (st_done) ->
						(err, st) <- module_dir = @Fs.stat @Path.join UNIVERSE_MODULES_PATH, file
						if err => return done err
						if st.isDirectory!
							# load
							(err, data) <- @Fs.readFile @Fs.stat @Path.join module_dir, "package.json"
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
										path: @Path.join repo.uri.path, \node_modules, p
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
				throw new Error "....."
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

				@Fs.readdir


		download:
			onenter: ->
				# INCOMPLETE need to download the universe from the master universe
				# this should also read, `construct_uV`
				console.log "TODO: add updater..."
				return @transition \build
				build = @task 'download universe'
				# @updater = Updater {
				# 	manifest: "https://raw.github.com/MechanicOfTheSequence/UniVerse/master/manifest.json"
				# 	path: UNIVERSE_PATH
				# }

				build.end (err, res) ->
					console.error "done"

		bundle:
			onenter: ->
				# monitor build files with
				# https://github.com/yanush/directory-cache
				MULTIVERSE_DEPS_PATH = @Path.join MULTIVERSE_PATH, '.deps'
				NODE_SRC_PATH = @Path.join MULTIVERSE_DEPS_PATH, \node
				BUILD_PATH = @Path.join MULTIVERSE_DEPS_PATH, \build
				BUILD_NODE = @Path.join BUILD_PATH, \node

				# it would be nice to get this data from a different location :)
				TARGET_UNIVERSE = opts
				@UNIVERSE = @Config UNIVERSE_JSON
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
						uri: "file:"+UNIVERSE_LIB_PATH
						bootstrap: true
					}
					repo.on \ready ->
						console.log "Universe REPO emitted ready! we're done"
						deps_done ...

				# NODE
				console.log "node ", UNIVERSE.bundle.node
				if Semver.satisfies UNIVERSE.bundle.node, NODE_VERSION
					#console.log "saving???", UNIVERSE_LIB_PATH
					#console.log "saving???", @Config._saving
					build.push install_deps
				else
					node = build.branch 'install node'
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
							p = ToolShed.exec "git clone --local git://github.com/joyent/node.git node", {cwd: MULTIVERSE_DEPS_PATH, stdio: \inherit}, (code) ->
								if code then done new Error "process exited with code: " + code
								else then done null, {code}
					#*/
					node.choke (node_build_done) ->
						#unless ToolShed.isDirectory "#UNIVERSE_PATH/bin/node"
						#/*
						node_build = node.branch 'build node'
						node_build.choke (done) ->
							Rimraf @Path.join(BUILD_PATH, \node), done
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
							ToolShed.exec "./configure --prefix=#{UNIVERSE_PATH}", cwd: BUILD_NODE, done
						node_build.choke (done) ->
							ToolShed.exec "make -j#{CORES} install PORTABLE=1", cwd: BUILD_NODE, done
						node_build.choke (done) ->
							Rimraf @Path.join(BUILD_PATH, \node), done
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
								ToolShed.writeFile UNIVERSE_LIB_JSON, JSON.stringify(UNIVERSE, null, '  ')
								# 2. open lib/ as a repository
								install_deps ->
									console.log "emitted ready! we're done"
									node_done ...
								#node_done ...
				# MONGO
				unless Semver.satisfies UNIVERSE.bundle.mongo, MONGO_VERSION
					MONGO_NAME = "mongodb-#{OS}-#{ARCH}-#{MONGO_VERSION}"
					MONGO_URL = "http://fastdl.mongodb.org/#{OS}/#{MONGO_NAME}.tgz"
					MONGO_SRC_PATH = @Path.join MULTIVERSE_DEPS_PATH, MONGO_NAME
					mongo = build.branch 'download mongo'
					mongo.choke (done) -> ToolShed.mkdir MONGO_SRC_PATH, ->
						done null, "mkdir done"
					mongo.push (done) ->
						#done = mongo_build_done
						mongo_local = @Path.join MULTIVERSE_DEPS_PATH, MONGO_NAME+'.tgz'
						rejects = <[bsondump mongodump mongoexport mongofiles mongoimport mongorestore mongos mongosniff mongostat mongotop mongooplog mongoperf]>
						Archivista.dl_and_untar {
							url: MONGO_URL
							file: mongo_local
							path: MULTIVERSE_DEPS_PATH
							task: mongo
							filter: (header) -> ~rejects.indexOf header.path.substr ('bin/'+MONGO_NAME).length+1
						}, done
					mongo.choke (done) ->
						Rimraf @Path.join(MULTIVERSE_DEPS_PATH, MONGO_NAME), done
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

		load: (id, task, done) ->
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
			console.log "going to read:" UNIVERSE_JSON
			@UNIVERSE = @Config UNIVERSE_JSON, empty_uV
			@UNIVERSE.once \ready (config, data) ~>

				# the package should have bundle: {version, dependencies} etc.
				# @transition \install_deps
				# @transition \load_modules
				task = @task "starting up.."
				task.concurrency = 20
				modules_path = @Path.join UNIVERSE_SRC, \node_modules
				# walker = Walk UNIVERSE_MODULES_PATH, max_depth: 1
				# walker.on \directory (path, st) ~>
				# 	console.log "dir:", path
				# 	mod_name = @Path.basename path
				# 	if mod_name.0 isnt '.'
				# 		mod_path = @Path.join modules_path, mod_name
				# 		pkg_json = @Path.join mod_path, \package.json
				# 		task.push (done) ->
				# 			ToolShed.stat pkg_json, (err, p_st) ->
				# 				# if p_st
				# 				# 	console.log "st:", (+p_st.mtime), (+st.mtime)
				# 				# else
				# 				# 	console.log "err", err
				# 				if p_st and (+p_st.mtime < +st.mtime)
				# 					console.log "npm install .", {cwd: mod_path}
				# 					ToolShed.exec "#{UNIVERSE_BIN_PATH}/npm install .", {cwd: mod_path}, (err) ->
				# 						if err
				# 							done err
				# 						else
				# 							@Fs.utimes pkg_json, st.atime, p_st.mtime, (err) ->
				# 								done err
				# 					# done!

				task.push (done) ->
					pkg_json = @Path.join UNIVERSE_LIB_PATH, \package.json
					ToolShed.stat UNIVERSE_LIB_PATH, (err, st) ->
						if err => done err
						else ToolShed.stat pkg_json, (err, p_st) ->
							if p_st and (+p_st.mtime < +st.mtime)
								ToolShed.exec "#{UNIVERSE_BIN_PATH}/npm install .", {cwd: UNIVERSE_LIB_PATH}, (err) ->
									if err
										done err
									else
										@Fs.utimes pkg_json, st.atime, p_st.mtime, (err) ->
											done err
							else done err

				# for path, opts of TARGET_UNIVERSE.repos
				repo_task = task.branch "install repo..."
				_.each TARGET_UNIVERSE.repos, (opts, path) ->
					repo_task.push (done) ->
						@exec \repo.get, path, opts, task, (err) ->
							unless err
								UNIVERSE.repos[path] = opts
							done err
				task.choke (done) ->
					repo_task.end (err, res) ->
						console.log "!!!!!!!!!!!!!!!!!!!! repo done"
						done err

				get_version = (version) ->
					if typeof version is \string and version.indexOf('.') is version.lastIndexOf('.')
						version += '.0'
					version
				bundle_task = task.branch "bundle repo..."
				_.each TARGET_UNIVERSE.bundle, (v, b) ~>
					console.log "UNIVERSE", UNIVERSE.bundle
					@debug "checking bundle: (%s@%s) satisfies (%s@%s)", b, UNIVERSE.bundle[b], b, TARGET_UNIVERSE.bundle[b]
					version = get_version UNIVERSE.bundle[b]
					wanted = get_version TARGET_UNIVERSE.bundle[b]
					console.log UNIVERSE.bundle[b], TARGET_UNIVERSE.bundle[b]
					unless Semver.satisfies version, wanted
						@debug "bundling: %s@%s", b, v
						bundle_task.push (done) ->
							@exec "bundle:#b", v, task, done
				task.choke (done) ->
					bundle_task.end (err, res) ->
						done err
				task.push (done) -> @exec \install_modules task, done
				task.end (err, res) ->
					console.log "TASK.END"
					if err
						throw err
					else @transition \ready

		'repo.get': (path, opts, _task, done) ->
			uri = Url.parse opts.upstream
			if uri.protocol isnt 'github:'
				done new Error "only github is supported for now"
			# task = _task.branch "get #path"
			deps_path = @Path.join MULTIVERSE_DEPS_PATH, uri.hostname, uri.path
			repo_name = uri.path.substr 1
			# repo_path = @Path.join deps_path, repo_name
			ToolShed.stat deps_path+'/.git', (err, st) ->
				if err and err.code is \ENOENT
					ToolShed.exec "git clone -n https://github.com/#{uri.hostname}#{uri.path}.git #{deps_path}", {cwd: UNIVERSE_PATH}, ->
						console.log "done clone", &
						ToolShed.exec "git clone #{deps_path} #{path}", {cwd: UNIVERSE_PATH}, (code) ->
							done code, path
						# ToolShed.exec "git checkout  -b default #{opts.revision || 'master'}", {cwd: deps_path}, ->
						# 	console.log "done checkout", &
				else
					# if (+st.atime - Date.now!) > 1000*60
					# 	ToolShed.exec "git fetch origin", {cwd: deps_path}, ->
					# 		console.log "done fetch", &
					uv_path = @Path.join UNIVERSE_PATH, path
					ToolShed.stat uv_path, (err, st) ->
						if err
							if err.code is \ENOENT
								ToolShed.exec "git clone #{deps_path} #{path}", {cwd: UNIVERSE_PATH}, ->
									console.log "local clone done", &
							else done err
						else
							ToolShed.exec "git checkout #{opts.revision || 'master'}", {cwd: uv_path}, (code) ->
								console.log "done checkout", &
								if code
									console.log "git checkout #{opts.revision || 'master'}", {cwd: uv_path}
								done code, path
			# exec ""
			# MULTIVERSE_DEPS_PATH
		'install_modules': (task, cmd_done) ->
			# walker of node_modules dir comparing the package.json file time to the dir file time
			cmd_done!

		'bundle:node': (version, task, cmd_done) ->
			SRC_PATH = @Path.join UNIVERSE_PATH, \src, \third_party, \node
			build_task = task.branch "build #version"
			build_task.choke (done) ->
				ToolShed.exec "git reset --hard", cwd: SRC_PATH, done
			build_task.choke (done) ->
				ToolShed.exec "git checkout v#{version}", cwd: SRC_PATH, done
			build_task.choke (done) ->
				# FUTURO: me gustaría sacar un chroot que sea el mismo que usa chromium o algo asi
				# eso seria mejor para compilar el universe para otras plataformas
				env = process.env <<< {
					CFLAGS: "-Os" # -march=native"
					CXXFLAGS: "-Os" # -march=native"
				}
				ToolShed.exec "./configure --prefix=#{UNIVERSE_PATH}", cwd: SRC_PATH, done
			build_task.choke (done) ->
				ToolShed.exec "make -j#{CORES} install PORTABLE=1", cwd: SRC_PATH, done
			build_task.end ->
				console.log "build node end", &
				UNIVERSE.bundle.node = version
				cmd_done ...

		'bundle:mongo': (version, task, cmd_done) ->
			# later do this with toku
			# /usr/local//Cellar/gcc/4.8.3/bin/gcc-4.8
			# https://github.com/Tokutek/mongo/blob/master/docs/building.md
			build_task = task.branch "build #version"
			SRC_PATH = @Path.join UNIVERSE_PATH, \src, \third_party, \mongo
			build_task.choke (done) ->
				ToolShed.exec "git reset --hard", cwd: SRC_PATH, done
			build_task.choke (done) ->
				ToolShed.exec "git checkout r#{version}", cwd: SRC_PATH, done
			build_task.choke (done) ->
				ToolShed.exec "scons --prefix=#{UNIVERSE_PATH} install -j#{CORES}", cwd: SRC_PATH, done
			task.push (done) ->
				console.log "PUSH MONGO"
				build_task.end (err) ->
					console.log "mongo.end", &
					UNIVERSE.bundle.mongo = version
					done err
			task.end (err, res) ->
				console.log "MONGO INSTALLED"
				cmd_done!

		# 'bundle:go': (version, task, cmd_done) ->
		# 	GO_SRC_PATH = @Path.join UNIVERSE_PATH, \src, \third_party, \golang
		# 	ToolShed.stat GO_SRC_PATH, (err, st) ->
		# 		build_task = task.branch "build #version"
		# 		if err
		# 			if err.code is \ENOENT
		# 				build_task.choke (done) ->
		# 					ToolShed.exec "hg clone -u release https://code.google.com/p/go #{GO_SRC_PATH}", done
		# 		else
		# 			build_task.choke (done) ->
		# 				ToolShed.exec "hg pull", cwd: GO_SRC_PATH, (code) ->
		# 					if code
		# 						Rimraf GO_SRC_PATH, (err) ->
		# 							if err => done err
		# 							else ToolShed.exec "hg clone -u release https://code.google.com/p/go #{GO_SRC_PATH}", done

		# 		build_task.choke (done) ->
		# 			ToolShed.exec "hg checkout go#{version}", cwd: SRC_PATH, done
		# 		build_task.choke (done) ->
		# 			ToolShed.exec "sh all.bash" {cwd: "#{SRC_PATH}/src"} (err) ->
		# 				if err
		# 					console.warn "there might be an error in go:", err.message
		# 					console.log "continuing..."
		# 				# else
		# 				# 	console.log "ALL INSTALLED"
		# 				done!
		# 		task.push (done) ->
		# 			build_task.end (err) ->
		# 				UNIVERSE.bundle.go = version
		# 				done err

		'bundle:arango': (version, task, cmd_done) ->
			build_task = task.branch "build #version"
			SRC_PATH = @Path.join UNIVERSE_PATH, \src, \third_party, \ArangoDB
			GO_PATH = @Path.join SRC_PATH, \3rdParty, "go-#{if process.arch is \x64 => '64' else '32'}"
			GO_SRC_PATH = @Path.join UNIVERSE_PATH, \src, \third_party, \golang
			build_task.push (done) ->
				@Fs.lstat GO_PATH, (err, st) ->
					if st and st.isSymbolicLink!
						done!
					else
						go_src = @Path.join UNIVERSE_PATH, \src, \third_party, \golang
						@Fs.symlink go_src, GO_PATH, done
			build_task.choke (done) -> ToolShed.exec "automake-1.14 --add-missing", cwd: SRC_PATH, done
			build_task.choke (done) -> ToolShed.exec "autoreconf", cwd: SRC_PATH, done
			build_task.choke (done) ->
				ToolShed.exec <[ ./configure
					--enable-all-in-one-v8
					--disable-all-in-one-libev
					--enable-all-in-one-icu
					--enable-maintainer-mode
					--enable-internal-go
					--disable-mruby]>join(' ') + " --prefix=#{UNIVERSE_PATH}", cwd: SRC_PATH, done
			# build_task.choke (done) -> quick_exec "cmake .", done
			unless UNIVERSE.bundle.go
				build_task.choke (done) ->
					build_go_task = build_task.branch "build go"
					ToolShed.stat GO_SRC_PATH, (err, st) ->
						if err
							if err.code is \ENOENT
								build_go_task.choke (done) ->
									ToolShed.exec "hg clone -u release https://code.google.com/p/go #{GO_SRC_PATH}", done
						else
							build_go_task.choke (done) ->
								ToolShed.exec "hg pull", cwd: GO_SRC_PATH, (code) ->
									if code
										Rimraf GO_SRC_PATH, (err) ->
											if err => done err
											else ToolShed.exec "hg clone -u release https://code.google.com/p/go #{GO_SRC_PATH}", done
									else done!

							build_go_task.choke (done) ->
								ToolShed.exec "hg checkout go1.2", cwd: GO_SRC_PATH, done
							build_go_task.choke (done) ->
								console.log "gonna build go now"
								ToolShed.exec "sh all.bash -j#{CORES}" {cwd: "#{GO_SRC_PATH}/src"} (err) ->
									if err
										console.warn "there might be an error in go:", err.message
										console.log "continuing..."
									# else
									# 	console.log "ALL INSTALLED"
									done!

							build_go_task.end (err) ->
								console.log "go built...", err
								UNIVERSE.bundle.go = '1.2'
								done err
			build_task.choke (done) -> ToolShed.exec "make -j#{CORES} install", cwd: SRC_PATH, done
			build_task.end (err) ->
				if err
					@debug "compilation fiAILED	"
					console.log "compilation fiAILED	"
					# throw err

				done err
			task.push (done) ->
					build_task.end (err) ->
						UNIVERSE.bundle.arango = version
						done err


		'process.start': (id, opts, task, cmd_done) ->
