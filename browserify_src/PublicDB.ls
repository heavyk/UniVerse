Path = require \path
Fs = require \fs
Url = require \url
Http = require \http

{ Fsm, ToolShed, Debug, DaFunk, _ } = require 'MachineShop'

debug = Debug \PublicDB

level-js = require \level-js
export class LocalDB extends Fsm
	(options) ->
		unless name = options.name
			throw new Error "you must provide a 'name' for your LocalDB"
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
		@debug.todo "query the LocalDB/PubliCDB"

export PublicDB = (opts, db_ready) ->
	debug = Debug "PublicDB"
	if typeof opts is \string
		opts = {name: opts}
	else if typeof opts isnt \object
		opts = {}

	unless name = opts.name
		@debug.error "you need a name for your database!"

	if db = PublicDB.dbs[opts.name]
		return db

	unless opts.host
		opts.host = '127.0.0.1'

	unless opts.port
		opts.port = 8529

	self = PublicDB.dbs[opts.name] = new Fsm "PublicDB(#{opts.name})" {
		name: opts.name
		opts: opts
		path: db_path = Path.join \db, opts.name

		get: (encantador, incantation, version, opts) ->
			@debug "PublicDB.get %j", &
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
				@debug "new Blueprint"
				bp = new Blueprint refs, {encantador, incantation, version}

			@debug "PublicDB.get  <\- %s", long_incantation
			return bp

			task = @task 'initialize bp or whatever'
			task.push (done) ->
				bp.once_initialized done
			task.end (err, res) ->
				@debug "we have the bp (and supposedly the instance) now, YAY!"


		patch: (obj) ->
			@debug.todo "object patching"

		initialize: ->
			@debug "initializing #{opts.name}"
			@blueprints = {}
			task = @task "initialize PublicDB(#{opts.name})"
			task.push (done) ~>
				@storage = new LocalDB {name}
				@storage.once_initialized ~>
					@debug "storage ready"
					done!

			task.end (err, res) ~>
				if err
					@emit \error err
					@transitionSoon \error
				else
					@transitionSoon \ready

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

				fetch: (fqvn, cb) ->
					@debug "hello! we want to get: %s", fqvn
					if typeof fqvn is \string
						fqvn = parse_fqvn fqvn
					else if typeof fqvn isnt \object
						throw new Error "dude, you're fetching alll wrong..."

					unless encantador = fqvn.encantador
						throw new Error "you neeed to define the encantador"

					unless incantation = fqvn.incantation
						throw new Error "you need to define the incantation"

					req = Http.get "/db/_bp/#encantador/#incantation", (err, res) ->
						cb err, res
					req.end!

				# XXX: this should be a node derivative
				dump: ->
					# XXX: this should actually use a main task with branches
					#  it's possible that this code isn't even fully working right... lol
					throw new Error "redo this with DaFunk.stringify"
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
