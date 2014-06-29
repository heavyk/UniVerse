
Http = require \http
assert = require \assert

{ Fsm, ToolShed, _ } = require 'MachineShop'
UniVerse = require './UniVerse' .UniVerse
Blueprint = require './Blueprint' .Blueprint
StoryBook = require './StoryBook' .StoryBook


export class Library extends Fsm
	(@refs, opts) ->
		if typeof refs isnt \object
			throw new Error "you need some references for your library"
		else if typeof refs.archive isnt \object
			throw new Error "you need a reference to your PublicDB blueprints [storage]"

		@blueprints = {}
		@__loading = {}
		@memory = {}
		@archive = refs.archive
		super "Library"

	states:
		uninitialized:
			onenter: ->
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
						@_loading = null
						if res.statusCode is 200
							xp = ToolShed.objectify data, {}, {name: @id}
							@debug "yay, we have the experience... store it"
							@memory[incantation].set xp

						else
							@emit \error, {code: \ENOENT}
							@transition res.statusCode
				@_loading = id
				if typeof cb is \function
					cb null, {yay: true}

			fetch: (fqvn, book, cb) ->
				if typeof book is \function
					cb = book

				@debug "fetching blueprint.."
				@debug.warn "TODO: save the blueprint into poetry and return the blueprint"
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
					console.log "perhaps one of these is the book:", @refs.book, fqvn.book
					console.log "not sure what happened here... TODO: make this a part of debug"
					debugger

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
					if typeof cb is \function
						cb null, bp
				else
					refs = @refs
					if book instanceof StoryBook and book isnt refs.book
						if refs.book
							refs = {} <<< @refs
						refs.book = book
						@debug "instantiating this in another poetry book"

					@blueprints[long_incantation] = bp = new Blueprint refs, {encantador, incantation, version}
					timeout = setTimeout ->
						if typeof cb is \function
							cb {code: \TIMEOUT}, bp
					, 4000
					bp.once_initialized ->
						clearTimeout timeout
						bp.imbue book
						bp.debug "BLUEPRINT IMBUED"
						if typeof cb is \function
							cb null, bp
