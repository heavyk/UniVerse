
Http = require \http
assert = require \assert

{ Fsm, ToolShed, _ } = require 'MachineShop'
# UniVerse = require './UniVerse' .UniVerse
Blueprint = require './Blueprint' .Blueprint
StoryBook = require './StoryBook' .StoryBook


# library gets the blueprint from the storage then saves it into the poetry book
# the library can have multiple public db

class Library extends Fsm
	(@refs, opts) ->
		if typeof refs isnt \object
			throw new Error "you need some references for your library"
		# else if typeof refs.book isnt \object
		# 	throw new Error "you need a reference to a PoetryBook [poetry]"
		else if typeof refs.archive isnt \object
			throw new Error "you need a reference to your PublicDB blueprints [storage]"

		@blueprints = {}
		# @books = {}
		@__loading = {}
		@memory = {}
		# @session = new Session

		@archive = refs.archive


		super "Library"

	states:
		uninitialized:
			onenter: ->
				console.log "we're uninitialized..."
				@transition \ready

		ready:
			onenter: ->

			'get:exp': (incantation, key, cb) ->
				# I believe this will probably do a series of things when looking for an experience
				# LocalDB / PublicDB / EtherDB

				@__loading = req = Http.get {path: "/db/#{incantation}/#{key}"}, (res) !~>
					@__loading = null
					data = ''
					res.on \error (err) ->
						console.error "we've got an error!!", err

					res.on \data (buf) ->
						# console.log "got data", data
						data += buf

					res.on \end ~>
						console.log "done with the request:", res
						@_loading = null
						if res.statusCode is 200
							xp = ToolShed.objectify data, {}, {name: @id} #ToolShed.da_funk res, {}, {name: @id}
							@debug "yay, we have the experience... store it"
							@memory[incantation].set xp
							# console.error "YAYAYAYA", @_el, @state

						else
							# @transition \error
							@emit \error, {code: \ENOENT}
							@transition res.statusCode
					# debugger
				# req.setHeader 'Content-Type', "application/json"
				@_loading = id
				if typeof cb is \function
					cb null, {yay: true}

			fetch: (fqvn, book, cb) ->
				if typeof book is \function
					cb = book

				@debug "fetching blueprint.."
				@debug.warn "TODO: save the blueprint into poetry and return the blueprint"
				# the blueprint can then do "Blueprint.imbue"
				if typeof fqvn is \string
					incantation = fqvn
					if ~(i = incantation.indexOf ':')
						encantador = incantation.substr 0, i
						incantation = incantation.substr i+1
						if ~(i = incantation.indexOf '@')
							version = incantation.substr i+1
							incantation = incantation.substr 0, i
					fqvn = {encantador, incantation, version}
				else if typeof fqvn is \object
					encantador = fqvn.encantador
					incantation = fqvn.incantation
					version = fqvn.version

				if fqvn.book and fqvn.book isnt book
					book = fqvn.book
					delete fqvn.book

				if not book instanceof StoryBook
					debugger
					console.log "perhaps one of these is the book:", @refs.book, fqvn.book

				unless incantation
					console.error "you need a incantation for your blueprint!"
					throw new Error "you need a incantation for your blueprint!"

				unless encantador
					console.error "you need a encantador for your blueprint!"
					throw new Error "you need a encantador for your blueprint!"

				unless version
					version = \latest

				long_incantation = encantador+':'+incantation+'@'+version
				if bp = @blueprints[long_incantation]
					# debugger if ~long_incantation.indexOf 'Word:Mun'
					# if bp.refs.book isnt book
					# book.poetry[encantador][incantation] = bp.imbue book
					# bp.on \state:ready ->
						# bp.imbue book

					if typeof cb is \function
						cb null, bp
				else
					# assert refs.book instanceof StoryBook
					# debugger
					refs = @refs
					if book instanceof StoryBook and book isnt refs.book
						# console.log "gonna clone...", @refs
						# refs = _.clone @refs
						if refs.book
							refs = {} <<< @refs
						# console.log "cloned..."
						refs.book = book
						@debug "instantiating this in another poetry book"

					@blueprints[long_incantation] = bp = new Blueprint refs, {encantador, incantation, version}
					timeout = setTimeout ->
						# debuggerz
						if typeof cb is \function
							cb {code: \TIMEOUT}, bp
					, 4000
					bp.once_initialized ->
						# console.log "BLUEPRINT INITIALIZED"
						clearTimeout timeout
						bp.imbue book
						bp.debug "BLUEPRINT IMBUED"
						if typeof cb is \function
							cb null, bp




	# get: (encantador, incantation, version) ->
	# 	# fqvn is eg. Affinaty/{session_id}@latest
	# 	if typeof inst is \function
	# 		cb = inst
	# 		inst = _universe.session.mid
	# 	else if typeof version is \function
	# 		cb = version
	# 		inst = _universe.session.mid
	# 		version = \latest

	# 	if typeof @poems[poem] isnt \object
	# 		@poems[poem] = {}
	# 	else if bp = @poems[poem][version]
	# 		cb bp
	# 	else

	# 	@poems[poem][version] = bp = Blueprint \Poem, poem, version
	# 	bp.once_initialized cb


	# 	console.log "load up a poem here"
	# 	task = @task "load #{fqvn}"
	# 	task.push (done) ~>
	# 		#@refs.
	# 		PublicDB.get \Poem

export Library