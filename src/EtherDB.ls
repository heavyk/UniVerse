
Path = require \path
Fs = require \fs
Url = require \url
Http = require \http
Process = require './Process' .Process
LocalDB = require './LocalDB' .LocalDB

{ Fsm, ToolShed, _ } = require 'MachineShop'
{ Debug } = ToolShed

debug = Debug \EtherDB

class EtherDB extends Fsm
	(@refs, opts) ->
		if typeof opts is \string
			opts = {name: opts}
		else if typeof opts isnt \object
			opts = {}

		unless @name = opts.name
			console.error "you need a name for your database!"
			throw new Error "you need a 'name' for your database"

		# this needs to be retreived from the architect :)

		super "EtherDB(#{opts.name})"

		if refs.architect
			refs.architect.exec \EtherDB:register, @, opts, (opts) ~>
				@exec \connect, opts
		else
			@exec \connect, opts

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

	initialize: ->
		@ether = {}
		task = @task "initialize EtherDB(#{@opts.name})"
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

	states:
		uninitialized:
			onenter: ->
				@debug "entered uninitialized... do nothing, for now"

		loading:
			onenter: ->
				walker = Walk db_path, max_depth: 1
				walker.on \file (path, st) ~>
					file = Path.basename path
					if ~(idx = file.indexOf ".ether.json") and c = file.substr 0, idx
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
				console.log "TODO: use the mongo functions to list out the collections", Mongoose.ether
				# XXX: this should actually use a main task with branches
				#  it's possible that this code isn't even fully working right... lol
				debugger
				_.each Mongoose.ether, (ether, k) ~>
					collection_path = Path.join db_path, ether.collection.name
					ToolShed.mkdir collection_path, (err, dir) ~>
						if err
							@emit \dump_failed, err
						else
							task = @task "dumping collection #{ether.collection.name}"
							stream = ether.find!lean!stream!
							stream.on \data (doc) ~>
								task.push (done) ~>
									ToolShed.writeFile Path.join(collection_path, doc._id+'.json'), ToolShed.stringify(doc, void, "\t"), done
							stream.on \error (err) ~>
								@emit \dump_failed, err
							stream.on \close ~>
								@emit \dump_complete


export EtherDB