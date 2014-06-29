Path = require \path
Fs = require \fs
Url = require \url
Http = require \http

{ Fsm, ToolShed, Debug, DaFunk, _ } = require 'MachineShop'

debug = Debug \PublicDB

throw new Error "wtf"

# al final, a blueprint will also be a poem (to be able to edit it)
export Blueprint = (refs, opts) ->
	if typeof opts is \string
		incantation = opts
		if ~(i = incantation.indexOf ':')
			encantador = incantation.substr 0, i
			incantation = incantation.substr i+1
			if ~(i = incantation.indexOf '@')
				version = incantation.substr i+1
				incantation = incantation.substr 0, i
		opts = {encantador, incantation, version}
	else if typeof opts is \object
		encantador = opts.encantador
		incantation = opts.incantation
		version = opts.version

	unless incantation
		console.error "you need a incantation for your blueprint!"
		throw new Error "you need a incantation for your blueprint!"

	unless encantador
		console.error "you need a encantador for your blueprint!"
		throw new Error "you need a encantador for your blueprint!"

	if typeof version is \object
		_version = version
		version = version.version
	if not version or version is \*
		version = \latest

	long_incantation = encantador+':'+incantation+'@'+version
	if bp = Blueprint._[long_incantation] and typeof DEBUG isnt \undefined
		return bp

	window = refs.window
	$ = window.$

	if typeof UniVerse._[encantador] isnt \object
		UniVerse._[encantador] = {}

	if typeof UniVerse._[encantador][version] isnt \object
		UniVerse._[encantador][version] = {}

	get_bp = (encantador, incantation, version, cb) ->
		# TODO: first get from localstorage, then from the DB...
		# TODO: if its version is latest then watch it for updates

		#first check local storage, then check disk (if latest)
		# then, check the db for an update (if it's a semver that's not definative)

		$.ajax {
			url: "/bp/#encantador/#incantation"
			type: \get
			dataType: \json
			context: @
			data: if version and version isnt \latest => $.param {version}
			success: (res) ->
				cb void, res if typeof cb is \function
			error: (err) ->
				cb err if typeof cb is \function
		}

	Blueprint._[long_incantation] = machina = new Fsm "Blueprint(#{long_incantation})" {
		refs: refs
		renderers: <[header render footer]>
		#verses: verses
		incantation: incantation
		fqvn: long_incantation
		encantador: encantador
		version: version

		inst: (key) ->
			console.log "instatantiate #{encantador}(#key)"
			# else if typeof doc is \object
			# 	if id = doc._id and not doc._rev
			# 		is_new = true
			# 	else if doc._key and id = machina.incantation+'/'+doc._key
			# 		if not doc._rev
			# 			is_new = true
			# 	# todo check dirty!
			# 	#dirty_vals <<< doc

			if key and element = UniVerse._[machina.encantador][version][id = machina.incantation+'/'+key]
				return element
			else
				console.error "inst:", machina.encantador, version, id, machina
				eval """
				(function(){
					archive.blueprints['#{machina.encantador}'] = #{machina.encantador} = (function(superclass){
						var prototype = extend$((import$(#{machina.encantador}, superclass).displayName = '#{machina.encantador}', #{machina.encantador}), superclass).prototype, constructor = #{machina.encantador};
						ToolShed.extend(prototype, machina._blueprint.machina);
						function #{machina.encantador}(_bp, key){
							#{machina.encantador}.superclass.call(this, _bp, key);
						}
						return #{machina.encantador};
					}(Meaning));
					element = new #{machina.encantador}(machina, key);
				}())
				"""

				console.log "going to extend element", element, "with", machina._blueprint.machina
				debugger if machina.incantation is \Mun
				# lala = ToolShed.extend element::, machina._blueprint.machina

				console.log "before funkify:", lala
				debugger if machina.incantation is \Mun
				lala = DaFunk.freedom lala, {lala:1234}, name: machina.fqvn
				console.log "after funkify:", lala
				debugger if machina.incantation is \Mun
				# debugger

				return UniVerse._[machina.encantador][version][id] = lala

		states:
			uninitialized:
				onenter: ->
					# machina = @
					get_bp encantador, incantation, version, (err, res) ->
						if err
							machina.emit \error, err
							machina.transition \error
						else
							machina._blueprint = _bp = {} <<< res
							# if bp._blueprint?machina?states?ready?['onenter.js']
							# 	debugger
							console.error "objectify res:", res, _bp
							machina.layout = res.layout || {}
							deps = DaFunk.embody {}, res.elements #, @elements
							task = machina.task "get deps for #long_incantation"
							console.warn long_incantation, "DEPS: ", deps
							_.each deps, (deps, encantador) ->
								_.each deps, (version, incantation) ->
									# task.push (done) ->

									task.push (done) ->
										if typeof UniVerse.poetry[encantador] is \undefined
											UniVerse.poetry[encantador] = {}
										console.log "poetry", UniVerse.poetry
										# debugger
										unless bp = UniVerse.poetry[encantador][incantation]
											UniVerse.poetry[encantador][incantation] = bp = UniVerse.storage.get encantador, incantation, version
										if bp.state is void
											bp.once_initialized ->
												# console.info "dep!:", encantador, incantation, version, "machina.state", machina.state
												console.warn long_incantation, "READY:dep:", encantador, incantation, version, machina.state
												done!
										else done!
										# remove me because it should just go into new bp mode... (things should never fail)
										# machina.once_initialized done
								# 	task.push (done) ->
								# 		UniVerse.UniVerse.emit "dep:#type", name
								# 		UniVerse.UniVerse.once "dep:#type:#name:ready" ->
								# 			console.log "we got dep:#type:#name:ready"
								# 			done!
								# 		UniVerse.UniVerse.on "update:#type:#name" (bp) ->
								# 			console.log "we got an update on #type:#name", machina.version
								# 			#TODO: do the version as "latest" and make sure te updates are semver compliant
								# 			console.log "TODO: replace the current blueprint (done inside blueprint)"
								# 			console.log "TODO: blueprint has a node derivitave and a browser derivitave. one searches the localdb then does web updates, and the other gets from node"
								# 			console.log "TODO: add this functioality to blueprint"

							task.end (err, res) ->
								console.log "DEPS done: #long_incantation"
								console.info "initialized blueprint", machina.fqvn
								@transitionSoon \ready


			ready:
				onenter: ->
					console.log "blueprint ready", incantation, machina
					@emit \ready

				verify: (path, val) ->
					#TODO: add path splitting by '.'
					#unless s = blueprint[path]
			error:
				onenter: ->
					console.error "you have tried to load a blueprint which wasn't able to be fetched", incantation

	}
	return machina
Blueprint._ = {}
Blueprint._db_refs = {}
Blueprint.db_ref = (name, host) ->
	Blueprint._db_refs[name] = host
	unless Blueprint._db_default
		Blueprint._db_default = name
Blueprint.db_default = (db) ->
	Blueprint._db_default = db

#TODO: store the blueprint into arango...
#TODO: if we're a node instance, allow the proxy interfaces for Config (blueprint-less records)
#       same thing for scope
#TODO: if node instance save into redis and auto update through dnode
level-js = require \level-js
export class LocalDB extends Fsm
	(options) ->
		console.log "options", options
		unless name = options.name
			throw new Error "you must provide a 'name' for your LocalDB"
		# debugger
		@storage = level-js name

		super "LocalDB"

	states:
		uninitialized:
			onenter: ->
				#task = @task 'initialize...'
				@storage.open (err) ~>
					if err
						@transition \error
					else
						@transition \ready

				# @storage.initialized.fail (err) ~>
				# 	console.log "local storage error:", err
				# 	@transition \error
				# @storage.initialized.done ~>
				# 	if typeof cb is \function then cb ...
				# 	@transition \ready

		ready:
			onenter: ->
				@emit \ready

		error:
			onenter: ->
				@emit \error

	for k in <[get set remove list clear]>
		@@::[k] = ((k) -> (key, options, cb) ->
			if @state is \error
				if typeof cb is \function
					cb {code: \ERRNOTAVAILABLE}
			else
				dfd = @storage[k].call @storage, key, options
				if typeof cb is \function
					dfd.then cb
				dfd)(k)
	@@::query = (query) ->
		console.log "TODO: query the LocalDB/PubliCDB"

export PublicDB = (opts, db_ready) ->
	debug = Debug "PublicDB"
	if typeof opts is \string
		opts = {name: opts}
	else if typeof opts isnt \object
		opts = {}

	unless name = opts.name
		console.error "you need a name for your database!"
		throw new Error "you need a 'name' for your database"

	if db = PublicDB.dbs[opts.name]
		return db

	unless opts.host
		opts.host = '127.0.0.1'

	unless opts.port
		opts.port = 8529


	# launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist
	self = PublicDB.dbs[opts.name] = new Fsm "PublicDB(#{opts.name})" {
		name: opts.name
		opts: opts
		path: db_path = Path.join \db, opts.name

		get: (encantador, incantation, version, opts) ->
			console.log "PublicDB.get", &
			if typeof version is \object
				opts = version
				version = opts.version
			if not version
				version = \latest

			throw new Error " don't use this for now ... use PoetryBook.get"
			if ~(i = incantation.indexOf '@')
				version = incantation.substr i+1
				incantation = incantation.substr 0, i

			long_incantation = encantador+':'+incantation+'@'+version
			if typeof (bp = Blueprint._[long_incantation]) is \undefined
				console.log "new Blueprint"
				bp = new Blueprint refs, {encantador, incantation, version}

			console.log "PublicDB.get  <\- ", bp
			return bp

			# process = (data) ->
			# 	unless data
			# 		attempt_disk!
			# 	else
			# 		#console.log "bp data:", typeof data, data
			# 		#console.log "your bp(#name) is:",	ToolShed.objectify data
			# 		poem = new Poem name, refs, ToolShed.objectify data
			# 		poem.once "state:ready" ->
			# 			console.log "dep:Poem ready:: ", name
			# 			UniVerse.emit "dep:Poem:#name:ready"

			# attempt_disk = ->
			# 	path = Path.join \lib \Poems name+'.poem'
			# 	ToolShed.readFile path, (err, data) ->
			# 		self.storage.set "Blueprint:#name", data
			# 		process data
			# dfd = self.storage.get "Blueprint:#name"
			# dfd.done process
			# dfd.fail attempt_disk

			task = @task 'initialize bp or whatever'
			task.push (done) ->
				bp.once_initialized done
			task.end (err, res) ->
				console.log "we have the bp (and supposedly the instance)", res
				#obj = bp.express res

		patch: (obj) ->
			console.error "TODO: object patching"

		initialize: ->
			console.log "initializing #{opts.name}"
			@blueprints = {}
			task = @task "initialize PublicDB(#{opts.name})"
			task.push (done) ~>
				@storage = new LocalDB {name}
				@storage.once_initialized ~>
					console.log "storage ready", &
					done!

			task.end (err, res) ~>
				# debugger
				if err
					@emit \error err
					@transitionSoon \error
				else
					@transitionSoon \ready
			/*
			if opts.name
				ToolShed.mkdir db_path, (err, dir) ~>
					if err
						@emit \error, err
						@transition \error
					else @transition \connect
			*/

		states:
			uninitialized:
				onenter: ->
					@debug "entered uninitialized... do nothing, for now"

			loading:
				onenter: ->
					walker = Walk db_path, max_depth: 1
					walker.on \file (path, st) ~>
						file = Path.basename path
						if ~(idx = file.indexOf ".blueprint.json") and c = file.substr 0, idx
							if c is \undefined
								throw new Error "STOP!! you've got some heavy shit going on somewhere..."
					walker.on \end (err) ~>
						if err
							@emit \error err
							@transition \error
						else @transition \ready

			ready:
				onenter: ->
					@emit \ready

				# get: (prefix, name, inst, cb) ->
				# 	if typeof inst is \function
				# 		cb = inst
				# 	process = (data) ->
				# 		unless data
				# 			attempt_disk!
				# 		else
				# 			#console.log "bp data:", typeof data, data
				# 			#console.log "your bp(#name) is:",	ToolShed.objectify data
				# 			poem = new Poem name, refs, ToolShed.objectify data, {name}
				# 			poem.once_initialized ->
				# 				console.log "dep:poem ready:: ", name
				# 				debugger
				# 				UniVerse.emit "dep:Poem:#name:ready"

					# attempt_disk = ->
					# 	path = Path.join \lib \Poems name+'.poem'
					# 	ToolShed.readFile path, (err, data) ->
					# 		self.storage.set "Blueprint:#name", data
					# 		#ToolShed.objectify data
					# 		process data
					# dfd = self.storage.get "Blueprint:#name"
					# dfd.done process
					# dfd.fail attempt_disk

				fetch: (fqvn, cb) ->
					console.log "hello! we want to get", fqvn
					if typeof fqvn is \string
						fqvn = parse_fqvn fqvn
					else if typeof fqvn isnt \object
						throw new Error "dude, you're fetching alll wrong..."

					unless encantador = fqvn.encantador
						throw new Error "you neeed to define the encantador"

					unless incantation = fqvn.incantation
						throw new Error "you need to define the incantation"



					#TODO: first localDB
					req = Http.get "/db/_bp/#encantador/#incantation", (err, res) ->
						cb err, res
					req.end!

				# this should be a derivative
				dump: ->
					console.log "TODO: use the mongo functions to list out the collections", Mongoose.blueprints
					# XXX: this should actually use a main task with branches
					#  it's possible that this code isn't even fully working right... lol
					debugger
					_.each Mongoose.blueprints, (blueprint, k) ~>
						collection_path = Path.join db_path, blueprint.collection.name
						ToolShed.mkdir collection_path, (err, dir) ~>
							if err
								@emit \dump_failed, err
							else
								task = @task "dumping collection #{blueprint.collection.name}"
								stream = blueprint.find!lean!stream!
								stream.on \data (doc) ~>
									task.push (done) ~>
										ToolShed.writeFile Path.join(collection_path, doc._id+'.json'), ToolShed.stringify(doc, void, "\t"), done
								stream.on \error (err) ~>
									@emit \dump_failed, err
								stream.on \close ~>
									@emit \dump_complete

	}

	if typeof db_ready is \function
		debugger
		@until \ready, db_ready

	return self

PublicDB.dbs = {}
#export db = PublicDB {}
