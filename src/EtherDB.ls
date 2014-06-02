
Path = require \path
Fs = require \fs
Url = require \url
Http = require \http
Process = require './Process' .Process

{ Fsm, Fabuloso, ToolShed, _ } = require 'MachineShop'
{ Debug } = ToolShed

debug = Debug \EtherDB

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


class LocalDB extends Fsm
	(options) ->
		# debugger
		ToolShed.extend @, Fabuloso
		super "LocalDB"

	states:
		uninitialized:
			onenter: ->
				@transition \ready
			'node:onenter': ->
			'browser:onenter': ->
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
			throw new Error "TODO: implement a k/v storage..."
			# look into doing this over webrtc
			# rip off something like this: https://foundationdb.com/operations

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

EtherDB = (opts, db_ready) ->
	debug = Debug "EtherDB"
	if typeof opts is \string
		opts = {name: opts}
	else if typeof opts isnt \object
		opts = {}

	unless name = opts.name
		console.error "you need a name for your database!"
		throw new Error "you need a 'name' for your database"

	if db = EtherDB.dbs[opts.name]
		return db

	unless opts.host
		opts.host = '127.0.0.1'

	unless opts.port
		opts.port = 8529


	# launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist
	self = EtherDB.dbs[opts.name] = new Fsm "EtherDB(#{opts.name})" {
		name: opts.name
		opts: opts
		path: db_path = Path.join \db, opts.name

		get: (encantador, incantation, version, opts) ->
			console.log "EtherDB.get", &
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
			if typeof (bp = Process._[long_incantation]) is \undefined
				console.log "new Process"
				bp = new Process refs, {encantador, incantation, version}

			console.log "EtherDB.get  <\- ", bp
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
			# 		self.storage.set "Process:#name", data
			# 		process data
			# dfd = self.storage.get "Process:#name"
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
			task = @task "initialize EtherDB(#{opts.name})"
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
					# 		self.storage.set "Process:#name", data
					# 		#ToolShed.objectify data
					# 		process data
					# dfd = self.storage.get "Process:#name"
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

# inception/motivation/implementation

EtherDB.dbs = {}

export EtherDB
export LocalDB