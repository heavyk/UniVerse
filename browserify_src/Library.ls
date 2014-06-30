
Http = require \http
assert = require \assert
DeepDiff = require \deep-diff

{ Fsm, ToolShed, DaFunk, _ } = require 'MachineShop'
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
		DaFunk.extend this, Fsm.Empathy
		super "Library"

	states:
		uninitialized:
			onenter: ->
				console.log "Library.onenter"
				@transition \ready

			'browser:onenter': ->
				Dnode = require \dnode
				Shoe = require \shoe

				stream = Shoe '/dnode'
				# stream_lab = Shoe '/dnode-lab'
				# d = Dnode!# (remote) ->
				d = Dnode {
					Blueprint: (cmd, path, dd) ~>
						switch cmd
						| \diff =>
							console.log "diff: #path", dd
							if bp = @blueprints[dd._key]
								diff = dd.diff
								console.log "library blueprints", bp
								console.log "lhs:", diff.lhs
								# console.log "current:", diff.path, ToolShed.get_obj_path diff.path, bp._blueprint
								ToolShed.set_obj_path diff.path, bp._blueprint, diff.rhs

							bp.emit \diff, diff
							# fqvn = @encantador+':'+@incantation+'@'+@version
							# @blueprints[@fqvn] = @

				}
				d.on \remote (remote) !->
					# debugger
					console.log "connected!"
				d.pipe stream .pipe d
				# dlab = Dnode! # (remote) ->
				# 	# debugger
				# 	# console.log "lala"
				# dlab.on \remote, (remote) ->
				# 	debugger
				# 	remote.test 'lala' (s) ->
				# 		console.log 'beep => ' + s
				# 		dlab.end!
				# dlab.pipe stream_lab .pipe dlab

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
				# TODO: fetch doesn't need to know about the book!
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
				# if typeof cb is \function and ~long_incantation.indexOf 'Affinaty'
				# 	debugger
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

					# TODO: do the Http here... not in the blueprint... the blueprint should only need to make itself happen
					@blueprints[long_incantation] = bp = new Blueprint refs, {encantador, incantation, version}
					bp.imbue book, (err, _constructor, bp) ~>
						if err
							@debug.todo "make the blueprint you referenced ... #{long_incantation}"
							# debugger
						else if typeof cb is \function
							@debug "BLUEPRINT IMBUED"

						cb err, bp
