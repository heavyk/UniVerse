
Url = require \url
Path = require \path

Semver = require \semver
_ = require \lodash
Fstream = require \fstream

#Fsm = require \Mental .Fsm
#ToolShed = require \ToolShed
# Archivista = require \Archivista
{ ToolShed, Fsm } = require \MachineShop
spawn = require \child_process .spawn

Uri = require './Blueprint' .Uri

gyp_build = (mod_dir, done) ->
	#console.error "TODO: check to see if output_dir exists and the file is new"
	#console.error "TODO: first try building, and then if that doesn't work rebuild it"
	#console.log "gyp", ToolShed.nw_version, mod_dir
	p = spawn if ToolShed.nw_version then \nw-gyp else \node-gyp, ['rebuild'], {cwd: mod_dir}
	p.stdout.on \data (d) ->
		console.log (d+'').trim!
	tt = setTimeout ->
		done new Error "timed out..."
		# TODO: do this with lodash's debounce
	, 10000
	p.on \exit (code) ->
		clearTimeout tt
		if code
			done new Error "process exited with code: " + code
		else
			#done null, {code}
			<- ToolShed.mkdir outdir = Path.join mod_dir, \build, ToolShed.v8_mode, ToolShed.v8_version
			reader = Fstream.Reader path: Path.join mod_dir, \build, ToolShed.v8_mode
			reader.pipe lo = Fstream.Writer path: outdir
			lo.on \error done
			lo.on \end done

class Module extends Fsm
	(refs, opts) ->

		@refs = refs
		if typeof opts is \string
			# uri = new Uri opts
			if ~(i = opts.indexOf '@')
				@name = opts.substr 0, i
				@version = opts.substr i+1
			else
				@name = opts
				@version = \latest
		else
			@name = opts.name
			@version = opts.version || \latest
			@path = opts.path || @name

		super "Module(#{@name}@#{@version})"
		if opts.path
			@exec \open opts.path

	initialize: (refs, opts) ->
		uri = if opts.path =>	'npm:'+opts.name else opts.uri
		unless (@name = opts.name) is \string
			@emit \error "need name!"
			@transition \error
		unless (@name = opts.name) is \string
			@emit \error "need name!"
			@transition \error
		@installed_into = []

	states:
		uninitialized:
			onenter: ->
				#task = @task 'initialize'
				#console.log "open?", mod
				#settings = ToolShed.Config Path.join ""
				if false and Sencillo.state isnt \ready
					debug "waiting to initialize. Sencillo is currently '%s'", Sencillo.state
					Sencillo.on \ready, ->
						mod.transition \open
				else @transition \open

			open: (path) ->
				#console.log "onenter", mod, qs
				#console.log "Sencillo", Sencillo.modules
				unless qs.slashes
					qs.protocol = \npm:
				if qs.protocol is \npm: and qs.auth
					mod.name = qs.auth
				unless opts.version => opts.version = 'x'
				mod.transition \download
				#Sencillo.get_module opts.name+'@'+opts.version, (err, m) ->
					#m.hardlink opts.path
					#console.log "INCOMPLETE: hardlink this bitch!!"
				/*
				if m = Sencillo.modules[opts.name+'@'+opts.version]
					mod.transition \linking
				else

					mod.version = opts.version
					mod.transition \download
					# download and install
					# Sencillo.packages[mod].latest should exist alongside the version
					else
						var big_v
						for v in Object.keys p
								big_v = v
						if big_v
							mod.version = big_v
							mod.transition \linking
						else
							mod.transition \download
				else
					mod.transition \download
				*/

		download:
			onenter: ->
				#console.log "handle download", qs
				# INCOMPLETE: this should be moved over to the universe!!
				# first, the file needs to be downloaded to the universe
				# then, the file needs to be be hardlinked
				install_dep = (opts, dep_done) ->
					name = opts.name
					var v
					#v = opts.version
					into = opts.path or Path.join process.cwd!, \node_modules, name
					# first check to see if the local version exists...
					# if it does do hardlinks
					# INCOMPLETE: don't forget to record this in the universe
					# if it doesn't we go here:
					if opts.force or true # not ToolShed.exists
						task = mod.task "install dep: #{name}"
						debug "http://registry.npmjs.org/#{name}"
						task.push (mod_done) ->
							console.log "need metadata:", name
							Sencillo.mod_metadata name, (err, res) ->
								if err then return dep_done err
								var manifest
								json = JSON.parse res.body
								switch opts.version
								| \* \latest =>
									v := json.'dist-tags'.latest
									fallthrough
								| otherwise =>
									unless manifest = json.versions[opts.version]
										debug "version #{name}@#{opts.version} could not be found."
										debug "looking inside: %s", Object.keys(json.versions).join ', '
										_.each json.versions, (m, vv) ->
											#console.error vv, m.version
											#console.error Semver.satisfies(vv, opts.version), Semver.gt vv, v
											if Semver.satisfies vv, opts.version
												console.log vv, v
												if not v or Semver.gt vv, v
													v := vv
													manifest := m
										unless manifest
											manifest := json.versions[json.'dist-tags'.latest]
										debug "resolved to #{manifest.version}"
								archive_filename = Path.join MULTIVERSE_PKGS_PATH, Path.basename manifest.dist.tarball
								dest_local = Path.join MULTIVERSE_PKGS_PATH, manifest.name, manifest.version
								Archivista.dl_and_untar {
									url: manifest.dist.tarball
									file: archive_filename
									path: dest_local
									sha1: manifest.dist.shasum
									strip: 1 # npm files always prefix "package/"
								}, ->
									console.log "untar done"
									#dep_task = task.branch "install deps for #{name}@#{v}"
									# this assumes that gyp does not require a certein dep to be installed... but it could be!
									if manifest.gypfile => task.push (done) -> gyp_build dest_local, done
									if manifest.dependencies and false
										# INCOMPLETE: this should be a new Module.
										# each new module should look into the main lib node_modules dir first
										# then, if the dependency cannot be satisfied, it will install into the local node_modules dir
										deps_task = task.branch "install dependencies"
										_.each manifest.dependencies, (vv, name) ->
											console.log "manifest dep:", name, vv
											deps_task.push (done) ->
												console.log "installing dep:", name
												install_dep opts <<< {
													name: name
													version: vv
													path: Path.join dest_local, \node_modules, name
													#task: task
												}, (err) ->
													console.log "subtask done", name, vv
													if err then done err
													else # do copy
														ToolShed.mkdir into, (err) ->
															console.log "mkdir results", &
															if err then return done err
															dir = Fstream.Reader path: dest_local
															dir.pipe lo = Fstream.Writer path: into
															lo.on \error done
															lo.on \end, done
										deps_task.end ->
											mod_done null, manifest
									else
										mod_done null, manifest
										#done null, json._attachments
										#done ... #null, manifest
										console.log "dist", manifest.dist

						process.nextTick ->
							console.log "gonna do task.end"
							task.end (err, manifests) ->
								console.log "all module deps task done!", &
								dep_done null, manifest.0
					else dep_done null, manifest

				#if typeof repo.uri is \undefined
				#	return @prompt 'uri', "if this repo is a clone, please insert its uri"
				switch qs.protocol
				| \npm: =>
					task = mod.task 'install dep:'+mod.name
					install_dep {
						name: mod.name
						version: opts.version
						task: task
					}, (err, p) ->
						console.log "GOT HERE",mod.name, &
						#throw new Error "wtf?"
						if err
							mod.emit \error err
							mod.transition \error
						else
							#### SAVE THE MODULE INTO THE UNIVERSE OR WHATEVER ####
							# KENNY YOU ARE HERE #
							#console.log "",
							#mod.exec \installed res.package_json
							console.log "module installed", mod.name, &
							#mod.version = v = p.version
							#Sencillo.packages[v] = p
							console.log "package installed"
							mod.transition \linking

				| \git: =>
					console.error "INCOMPLETE - we gatta do a local clone before we can get this one goin!"
					# open a repository

					@prompt "where would you like to clone this repository into?"
					return
				| otherwise =>
					console.log "uri", uri
					console.error "unknown protocol - #{qs.protocol}"
					return

			installed: (p) ->
				# this should be:
				# Sencillo.handle \installed, mod_json
				console.log "this should get here too"
				mod.version = v = p.version
				Sencillo.packages[v] = p

		linking:
			onenter: ->
				console.log "get ready to do linking now..."
				# do hardlinking to uV/lib/node_modules/#{module}-#{version} & uV/lib/node_modules/#{module}-#{latest}
				# do hardlinking from uV/lib/node_modules/#{module} to #{path}/#{module}
				/*
				# TODO: ToolShed.Config 'package.json'
				sencillo_mod_json = require './package.json'
				ToolShed.readFile Path.resolve(Path.join(qs.path, 'package.json')), 'utf-8', (err, mod_json) ->
					if err
						console.error "this project doesn't have a package.json file"
						console.error "TODO: ask the user the questions to create them"
						# touch/load empty package.json
						# repo.transition \package_json
						# process.nextTick ->
						#		mod.emit \prompt ...
						throw err
						return bootstrap_cb "creating new package.json"
					console.log "mod_json", mod_json
					mod_json = JSON.parse mod_json
					console.log "mod_json", mod_json
					Npm.load mod_json, (err, Npm) ->
						if err then bootstrap_cb err
						debug "loaded! now doing checks..."
						repo.name_json = mod_json
						runtime-dependencies = []
						mod_deps = {}

						for p, v of mod_json.dependencies
							mod_deps[p] = v
						console.log "mods:", mod_deps
						console.log "install_dep {}"
						mod = Module {
							#mod: mod.0
							#version: mod.1
							path: Path.join node_modules, mod.0
							task: task
							repo: repo
						}, (err, res) ->
							if err then repo.transition \error
							else repo.transition \ready
				*/
				console.log "finished the race!!"
				mod.transition \ready

		ready:
			onenter: ->
				@emit \ready
				debug "todo listo!"



# export Module = (opts, refs, mod_ready_cb) ->
# 	uri = if opts.path =>	'npm:'+opts.name else opts.uri
# 	repo = refs.repo
# 	uV = refs.uV

# 	debug = Debug "Module(#{uri})"

# 	#if typeof into is \string
# 	#	Fs.exists
# 	console.log "before getting module: " + opts.name+'@'+opts.version
# 	#console.log "try module:", Sencillo.modules, Sencillo.modules[opts.name+'@'+opts.version]
# 	console.log uV
# 	#if p = uV.modules[opts.name+'@'+opts.version]
# 	#	p.install opts.path, (err) ->

# 	if typeof uri is \string
# 		qs = Url.parse uri
# 		if uri.charAt(0) is '/' or uri.substr(0, 2) is './'
# 			qs.protocol = \file:
# 	else return mod_ready_cb new Error "unknown uri: #{uri}"

# 	mod = new Fsm "Module(#{opts.name})" {
# 		initialize: ->

# 			debug "init package #{opts.name}@#{opts.version}"

# 		events:
# 			error: (err) ->
# 				console.error "ERR:", err
# 				@transition \error



# 	}
# 	if typeof mod_ready_cb is \function
# 		mod.once \ready, ->
# 			debug "repo is ready!!"
# 			mod_ready_cb ...
# 	return mod

export Module
