
Http = require \http
assert = require \assert

{ Fsm, ToolShed, _ } = require 'MachineShop'
UniVerse = require './UniVerse' .UniVerse
Blueprint = require './Blueprint' .Blueprint
StoryBook = require './StoryBook' .StoryBook



	# window = refs.window
	# $ = window.$

	# if typeof UniVerse._[encantador] isnt \object
	# 	UniVerse._[encantador] = {}

	# if typeof UniVerse._[encantador][version] isnt \object
	# 	UniVerse._[encantador][version] = {}


	# Blueprint._[long_incantation] = machina = new Fsm "Blueprint(#{long_incantation})" {
	# 	refs: refs
	# 	renderers: <[header render footer]>
	# 	#verses: verses
	# 	incantation: incantation
	# 	fqvn: long_incantation
	# 	encantador: encantador
	# 	version: version

	# 	inst: (key) ->
	# 		console.log "instatantiate #{encantador}(#key)"
	# 		# else if typeof doc is \object
	# 		# 	if id = doc._id and not doc._rev
	# 		# 		is_new = true
	# 		# 	else if doc._key and id = @incantation+'/'+doc._key
	# 		# 		if not doc._rev
	# 		# 			is_new = true
	# 		# 	# todo check dirty!
	# 		# 	#dirty_vals <<< doc

	# 		if key and element = UniVerse._[machina.encantador][version][id = machina.incantation+'/'+key]
	# 			return element
	# 		else
	# 			console.error "inst:", machina.encantador, version, id, machina
	# 			eval """
	# 			(function(){
	# 				archive.blueprints['#{machina.encantador}'] = #{machina.encantador} = (function(superclass){
	# 					var prototype = extend$((import$(#{machina.encantador}, superclass).displayName = '#{machina.encantador}', #{machina.encantador}), superclass).prototype, constructor = #{machina.encantador};
	# 					ToolShed.extend(prototype, machina._blueprint.machina);
	# 					function #{machina.encantador}(_bp, key){
	# 						#{machina.encantador}.superclass.call(this, _bp, key);
	# 					}
	# 					return #{machina.encantador};
	# 				}(Meaning));
	# 				element = new #{machina.encantador}(machina, key);
	# 			}())
	# 			"""

	# 			console.log "going to extend element", element, "with", machina._blueprint.machina
	# 			debugger if machina.incantation is \Mun
	# 			# lala = ToolShed.extend element::, machina._blueprint.machina

	# 			console.log "before funkify:", lala
	# 			debugger if machina.incantation is \Mun
	# 			lala = ToolShed.da_funk lala, {lala:1234}, name: machina.fqvn
	# 			console.log "after funkify:", lala
	# 			debugger if machina.incantation is \Mun
	# 			# debugger

	# 			return UniVerse._[machina.encantador][version][id] = lala

	# 	states:
	# 		uninitialized:
	# 			onenter: ->
	# 				# machina = @
	# 				get_bp encantador, incantation, version, (err, res) ->
	# 					if err
	# 						machina.emit \error, err
	# 						machina.transition \error
	# 					else
	# 						machina._blueprint = _bp = {} <<< res
	# 						# if bp._blueprint?machina?states?ready?['onenter.js']
	# 						# 	debugger
	# 						console.error "objectify res:", res, _bp
	# 						machina.layout = res.layout || {}
	# 						deps = DaFunk.embody {}, res.elements #, @elements
	# 						task = machina.task "get deps for #long_incantation"
	# 						console.warn long_incantation, "DEPS: ", deps
	# 						_.each deps, (deps, encantador) ->
	# 							_.each deps, (version, incantation) ->
	# 								# task.push (done) ->

	# 								task.push (done) ->
	# 									if typeof UniVerse.poetry[encantador] is \undefined
	# 										UniVerse.poetry[encantador] = {}
	# 									console.log "poetry", UniVerse.poetry
	# 									# debugger
	# 									unless bp = UniVerse.poetry[encantador][incantation]
	# 										UniVerse.poetry[encantador][incantation] = bp = UniVerse.storage.get encantador, incantation, version
	# 									if bp.state is void
	# 										bp.once_initialized ->
	# 											# console.info "dep!:", encantador, incantation, version, "machina.state", machina.state
	# 											console.warn long_incantation, "READY:dep:", encantador, incantation, version, machina.state
	# 											done!
	# 									else done!
	# 									# remove me because it should just go into new bp mode... (things should never fail)
	# 									# machina.once_initialized done
	# 							# 	task.push (done) ->
	# 							# 		UniVerse.UniVerse.emit "dep:#type", name
	# 							# 		UniVerse.UniVerse.once "dep:#type:#name:ready" ->
	# 							# 			console.log "we got dep:#type:#name:ready"
	# 							# 			done!
	# 							# 		UniVerse.UniVerse.on "update:#type:#name" (bp) ->
	# 							# 			console.log "we got an update on #type:#name", machina.version
	# 							# 			#TODO: do the version as "latest" and make sure te updates are semver compliant
	# 							# 			console.log "TODO: replace the current blueprint (done inside blueprint)"
	# 							# 			console.log "TODO: blueprint has a node derivitave and a browser derivitave. one searches the localdb then does web updates, and the other gets from node"
	# 							# 			console.log "TODO: add this functioality to blueprint"

	# 						task.end (err, res) ->
	# 							console.log "DEPS done: #long_incantation"
	# 							console.info "initialized blueprint", machina.fqvn
	# 							@transitionSoon \ready


	# 		ready:
	# 			onenter: ->
	# 				console.log "blueprint ready", incantation, machina
	# 				@emit \ready

	# 			verify: (path, val) ->
	# 				#TODO: add path splitting by '.'
	# 				#unless s = blueprint[path]
	# 		error:
	# 			onenter: ->
	# 				console.error "you have tried to load a blueprint which wasn't able to be fetched", incantation

	# }
	# return machina


# library gets the blueprint from the storage then saves it into the poetry book
# the library can have multiple public db

export class Library extends Fsm
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
