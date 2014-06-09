
Path = require \path
Url = require \url
spawn = require \child_process .spawn

_ = require \lodash
Rimraf = require \rimraf

#Fsm = require \Mental .Fsm
{ ToolShed, Fsm } = require \MachineShop
#ToolShed = require \ToolShed
Module = require './module' .Module

var Npm

class Repo extends Fsm
	(refs, opts) ->
		# @uri = opts.uri
		# @uV = refs.uV
		@refs = refs
		super "Repo(#{opts.uri})"
		console.log "we made our repo..."
		if opts.uri
			@exec \open opts.uri

	initialize: ->
		console.log "init repooo", @uri

	open: (p) ->
		throw new Error "NOT ALLOWED - make this a command if really necessary..."
		console.log "calling open", p
		if typeof p isnt \undefined
			# check path exists, etc.
			repo.uri = {
				path: p
				protocol: 'file:'
			}
		@transition \open

	events:
		error: (err) ->
			console.error "ERR:", err
			@transition \error

	states:
		uninitialized:
			onenter: ->
				# task = @task 'initialize'
				# if @refs.uV.state isnt \ready and not opts.bootstrap
				# 	debug "waiting to initialize. Sencillo is currently '%s'", Sencillo.state
				# 	Sencillo.on \ready, -> @transition \open
				# else
					# @transition \open

			open: (uri) ->
				unless typeof uri is \string then return null
				# qs = Url.parse uri
				# if uri.charAt(0) is '/' or uri.substr(0, 2) is './'
				# 	qs.protocol = \file:
				# return qs

				console.log "getting ready to open: #uri"
				@uri = Url.parse uri
				@uri.protocol = \file: unless @uri.protocol
				console.log "onenter", @uri
				if typeof @uri is \undefined
					return @prompt 'uri', "if this repo is a clone, please insert its uri"
				console.log "opening", @uri
				switch @uri.protocol
				| \file: =>
					@path = @uri.path
					console.log "initializing in #{@uri.path}"
					return @transition \package_json
				| \git: =>
					console.error "INCOMPLETE - we gatta do a local clone before we can get this one goin!"
					#@prompt "where would you like to clone this Repo into?"
					#@prompt "where would you like to clone this Repo into?", path: (v) -> Url.parse v
					return @transition \download
				| otherwise =>
					console.log "proto:", @uri
					console.error "unknown protocol - #{@uri.protocol}"
					return @transition \error

		download:
			onenter: ->
				switch @uri.protocol
				| \file: =>
					if @path is @uri.path
						@transition \package_json
					else
						@transition \INCOMPLETE {
							title: "hardlink the files from `uri` to `path`"
						}
				| \git: =>
					@transition \INCOMPLETE {
						title: "clone the git repo"
					}


		package_json:
			onenter: ->
				# if not loaded, load it
				# unless @PACKAGE.name
				#		@prompt "what is the name of this repository?"
				# unless ... etc.
				path = @path
				@emit \FEATURE {
					title: "clone the git repo"
				}
				ToolShed.mkdir path, (err) ->
					console.log "mkdir.cb", err
					if err then return @transition \error err
					# TODO: ToolShed.Config 'package.json'
					PACKAGE = @PACKAGE = ToolShed.Config Path.join path, 'package.json'
					console.log "PACKAGE", PACKAGE
					pkg_deps = {}

					#for p, v of PACKAGE.dependencies
					task = @task "resolve dependencies"
					task.push (done) ->
						_.each PACKAGE.dependencies, (v, p) ->
							#Sencillo.handle \install_dep
							console.log "install_dep", p, Path.join @uri.path, \node_modules, p

							pkg = Module {
								name: p
								version: v
								path: Path.join @uri.path, \node_modules, p
							}, { task, repo: @, uV: @refs.uV }, done
					task.end (err, res) ->
						console.log "all dependencies installed"
						if err then @transition \error
						else @transition \ready

						/*
						Npm.load PACKAGE, (err, Npm) ->
							if err then bootstrap_cb err
							debug "loaded! now doing checks..."
							@name_json = PACKAGE
							runtime-dependencies = []

						*/
					if @PACKAGE.git
						Fs.readFile Path.join(".git", \config), 'utf-8', (err, file) ->
							if err then throw err
							# TODO: init the git repository?
							ini = Ini.parse file
							#console.log PACKAGE.git
							if typeof PACKAGE.git is \object
								console.log ini.user, PACKAGE.git.user
								#gv = ini.user
								#if gv = ini.user is \object
								#console.log PACKAGE.git.user, '=', gv, _.isEqual PACKAGE.git.user, gv
								unless _.isEqual gv = PACKAGE.git.user, ini.user
									debug "different users!"
									if typeof gv is \object
										ini.user <<< gv
										console.log "writing ..."
										ToolShed.writeFile Path.join(".git", \config), Ini.stringify ini


		ready:
			onenter: ->
				@emit \ready
				debug "Sencillo está listo! comenzamos!"


export Repo

# export Repo = (opts, refs, repo_ready_cb) ->
# 	if typeof opts is \function
# 		repo_ready_cb = opts
# 	if typeof opts isnt \object
# 		opts = {}
# 	if typeof refs isnt \object
# 		refs = {}
# 	uri = opts.uri
# 	uV = refs.uV

# 	debug = Debug "Repo(#{uri})"
# 	repo = new Fsm "Repo" {

# 	}
# 	if typeof repo_ready_cb is \function
# 		repo.once \ready, ->
# 			debug "repo is ready!!"
# 			repo_ready_cb ...
# 	return repo
