
# PublicDB should "dump" it's database into a git repo...

# git-cascade
# https://github.com/cool-RR/git-cascade

# git-crypt
# http://www.twinbit.it/en/blog/storing-sensitive-data-git-repository-using-git-crypt
# https://github.com/AGWA/git-crypt

# A high-throughput distributed messaging system.
# https://kafka.apache.org/

# use ssh CA certs:
# https://news.ycombinator.com/item?id=7347735
# http://neocri.me/documentation/using-ssh-certificate-authentication/
# ssh and gpg:
# http://web.monkeysphere.info/getting-started-ssh/

# do code reviews like this:
# http://blog.codacy.com/top-10-faster-code-reviews/

# !!!!!!!!!!!!!
# js dependencies in the browser
# https://github.com/amark/coalesce

# html5 animation software
# http://animatron.com/

# ----

# this is soooo badass!!! - ascii text fonts
# http://patorjk.com/software/taag/#p=testall&f=Merlin1&t=headers

Path = require \path
Fs = require \fs
Url = require \url
Http = require \http

# puede ser que esto sea mejor para el Schema
# https://www.npmjs.org/package/mongo-json-schema

#Schema = require 'mongoose/lib/blueprint'
#Model = require 'mongoose/lib/blueprint'

{ Fsm, ToolShed, _ } = require 'MachineShop'
{ Debug } = ToolShed

# UniVerse = require '../UniVerse'

# { Poem, Verse, Voice, Tone, Rhythm, Stanza } = require Path.join __dirname, \sandra, \Poem
# { Poem, Verse, Voice, Tone, Rhythm, Stanza } = require './Poem'

# var Arango
# if typeof window is \object and window.arango
# 	Arango = window.arango
# else
# 	Arango = require \arango

debug = Debug \PublicDB

/**
PubliCDB

TODO: go ahead and add redis
TODO: add redis scripts: https://www.npmjs.org/package/libris

Basically it goes like this...

 - PublicDB is a replicatable, persistent, distributed database
 - Blueprint is sorta like the Schema
 - Word is sorta like the model
	- I think I need to change to Syllable
*/

###############################
###############################
########### db.ls #############
###############################
###############################

#TODO: import a bunch of the stuff from Mongoose.Schema here
/*
export Blueprint = (opts, refs) ->
	debug = Debug "Blueprint"
	opts = {} unless typeof opts is \object
	refs = {} unless typeof refs is \object

	unless opts.name or opts.name is \undefined
		throw new Error "you gatta have a collection name"

	unless db = refs.db
		db = PublicDB {}

	collection_name = opts.collection or opts.name # Mongoose.utils.toCollectionName opts.name

	if bp = db._blueprints[opts.name]
		return bp

	unless blueprint = bp._blueprint || opts.blueprint
		throw new Error "blueprint not defined"

	bp = new Fsm "Blueprint(#{opts.name})" {
		name: opts.name
		opts: opts
		refs: refs
		path: collection_path = Path.join db.path, collection_name
		blueprint_path: blueprint_path = Path.join db.path, opts.name+'.blueprint.json'
		queries: []
		__blueprint: {}

		blueprint: (blueprint, options) ->
			if @state is \config
				@config.blueprint = blueprint
				@transition \blueprint
			else @until \ready, ~>
				# XXX: do some cleaning on the input... only get the required stuff
				#  make sure to set the options as well.
				#  actually, I probably should merge the two objects, then new Schema [merged]
				#  then, after mongoose has done the work for me, update the local variables in @blueprint

				# XXX: after all of the blueprints are loaded, then if they still don't match
				#  that perhaps means that something needs to be deleted...
				#  figure out how to do that

				# XXX: optimize me a bit here :)
				unless @config.blueprint
					@config.blueprint = {}
				_.merge @__blueprint, blueprint
				json1 = ToolShed.stringify(@config.blueprint)
				json2 = ToolShed.stringify(@__blueprint)
				if json1 isnt json2
				# this doesn't work because of the super way the config works...
				# I probably need to improve it
				#unless _.isEqual @config.blueprint, @__blueprint
					_.merge @config.blueprint, @__blueprint
					@config.once \save (obj, path) ->
						console.log "saved", path #, json1 is json2

		find: (conditions, fields, options, callback) ->
			# XXX: this will break if you provide a callback
			# XXX: this should be abstracted for all operations!
			if @state isnt \ready
				console.log "no good!!!"
				return
				q = new Mongoose.Query conditions, options
				p = new Mongoose.Promise
				exec = q.exec
				q.exec = (cb) ->
					p.addBack cb
				@once \ready, ~>
					q.bind @_blueprint, 'find'
					q.select fields if fields
					pp = exec.call q
					pp.addBack p.resolve.bind p
					q.exec = exec
				return q
			else bp._blueprint.find.apply bp._blueprint, &

		count: (conditions, callback) ->
			if typeof conditions is \function
				callback = conditions
				conditions = {}

			if @state isnt \ready
				# XXX: this isn't actually tested, because I always do a count after I do a find.
				#   this means, that the blueprint is always ready. so this case is never entered
				q = new Mongoose.Query conditions

				@once \ready, ~>
					q.bind bp._blueprint, 'count'
					q.count.call q, callback
				return q
			else
				bp._blueprint.count.apply bp._blueprint, &

		states:
			uninitialized:
				onenter: ->
					ToolShed.mkdir collection_path, (err, dir) ->
						if err
							bp.emit \error, err
							bp.transition \error
						else bp.transition \config

			config:
				onenter: ->
					bp.config = ToolShed.Config blueprint_path
					bp.config.on \ready (err, p) ->
						#unless err
						bp.transition \blueprint

			blueprint:
				onenter: ->
					arango = db
					if opts.blueprint
						# it'll probably never get here, because I'm instantiating from db.blueprints[...] instead of calling the function
						console.log "blueprint update??", opts.blueprint

					console.log "config.blueprint", bp.config.blueprint
					bp._blueprint = Schema bp.config.blueprint
					# IMPROVEMENT: make the plugins dynamic!
					# eg. for plugin in bp.layout.plugins => bp._blueprint.plugin require plugin
					# IMPROVEMENT: save the index into the blueprint as well
					bp._blueprint.plugin require 'mongoose-text-search'
					bp._blueprint.plugin require 'mongoose-lifecycle'
					unless bp.config.blueprint?created
						bp._blueprint.plugin require 'mongoose-troop/lib/timestamp'
					if bp.config.blueprint?tags
						bp._blueprint.index tags: \text
					console.log "blueprint", collection_name, bp._blueprint
					bp._blueprint = Model collection_name, bp._blueprint
					bp._blueprint.on \afterSave (doc) ->
						setTimeout ->
							console.log "saved a blueprint", doc
							for q in bp.queries
								# OPTIMIZE: analyze to see if it's possible that we actually need to re-run the query here
								# for now thouh, we're gonna burn those cpu cycles. me la suda
								q.emit \run
						, 200ms
					bp._blueprint.on \afterRemove (doc) ~>
						process.nextTick ->
							for q in bp.queries
								rm = false
								for d, i in q._docs
									if d._id.toHexString! is doc._id.toHexString!
										q.emit \removedAt d, i
										rm = i
										break
								if rm isnt false
									# XXX if the count was the limit, rerun the query
									if q._docs.length is q.q.options.limit
										q.emitSoon \run
									q._docs.splice rm, 1
					#bp._blueprint.on \afterUpdate (doc) ->
					console.log "waiting for db to become ready", opts.name
					db.until \ready ->
						console.log
						bp.transition \populate

			populate:
				onenter: ->
					insert_doc = (id, path, done) ->
						bp._blueprint.findById id, (err, doc) ->
							if doc => done null
							else Fs.readFile path, 'utf-8', (err, data) ->
								try
									if err => done err
									else
										bp._blueprint.create JSON.parse(data), done
								catch e
									done e
					Fs.stat collection_path, (err, dir_st) ->
						if err
							bp.emit \error, err
							bp.transition \uninitialized
						else
							task = bp.task "populate Blueprint(#{collection_name})"
							debug "walking: %s", collection_path
							walker = Walk collection_path, max_depth: 1
							walker.on \file (path, st) ->
								if (st - dir_st) > 0 or opts.populate or true
									# HERE: I think the above comparison is wrong!
									# I need to check to see if it's greater than the bp.layout.mtime
									# then, I need to check to see if the id exists in the database (in update mode)
									file = Path.basename path
									file.replace /^[0-9a-f]{24}/, (id) ->
										if id => task.push (done) -> insert_doc id, path, done
							walker.on \error (err) ->
								console.log "walker encountered an error", err
								bp.emit \error err
								bp.transition \error
							walker.on \end ->
								if task.fns.length
									task.end (err, res) ->
										if err
											bp.emit \error err
											bp.transition \error
										else bp.transition \ready
								else bp.transition \ready
							if opts.watch
								console.log "not yet implemented, sorry"
								#Fs.watch

			ready:
				onenter: ->
					bp.emit \ready

				dump: ->
					task = bp.task "dumping collection #{collection_name}"
					stream = bp._blueprint.find!lean!stream!
					task.push (done) ->
						stream.on \error done
						stream.on \close done
					stream.on \data (doc) ->
						task.push (done) ->
							ToolShed.writeFile Path.join(collection_path, doc._id+'.json'), ToolShed.stringify(doc, null, "\t"), done
					task.end (err, res) ->
						if err
							bp.emit \dump_failed, err
						else bp.emit \dump_complete

	}
*/

get_path = (obj, str) ->
	str = str.split '.'
	i = 0
	while i < str.length
		obj = obj[str[i++]]
	obj
# I think the one above is the fastest.
# I also think that the above function can be optimized by using indexOf and substr -- another time I suppose :)
#OPTIMIZE! - jsperf anyone? (this is an almost useless optimization and should be added to Current too. Current shlould be fastest general lib - like lodash)
#get_path2 = (obj, str) -> (str.split '.').reduce ((o, x) -> o[x]), obj
set_path = (obj, str, val) ->
	str = str.split '.'
	while str.length > 1
		obj = obj[str.shift!]
	obj[str.shift!] = val



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
			url: "/db/_bp/#encantador/#incantation"
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
				lala = ToolShed.da_funk lala, {lala:1234}, name: machina.fqvn
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
							deps = ToolShed.embody {}, res.elements #, @elements
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
export class LocalDB extends Fsm
	(options) ->
		# debugger
		super "LocalDB"

	states:
		uninitialized:
			onenter: ->
				#task = @task 'initialize...'
				if typeof options is \function
					cb = options
					options = void
				#task.push (done) ~>
				@storage = new _.LargeLocalStorage options
				@storage.initialized.fail (err) ~>
					console.log "local storage error:", err
					@transition \error
				@storage.initialized.done ~>
					if typeof cb is \function then cb ...
					@transition \ready

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
