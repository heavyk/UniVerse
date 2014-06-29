# UniVerse 0.1.0 - 1.0.1 (UniVerse 2.0 will be different)

# I want to make this VERY CLEAR: as clear as possible, one might say.
# EVERYTHING inside of this UniVerse is 100% free and you are more than
# welcome to participate in its creation. for this reason, I am, make it
# absolutely crystal clear that the UniVerse is licensed under the AGPL
# license. you must return its favour. and so, just like this universe
# works: the basic building blocks are free. 'do as thou wilt' go!
# take dominion of your UniVerse.
#
# UniVerse: AGPL - please be a co-creator with us in this UniVerse
# Blueprints: FREE - as in freedom. do as thou wilt.
#
# sidenote: I do not endorse crowley. I never have, and I never will.
#   as a creative human, being, I believe it shows through much more in
#   his writing than his deeds. he should be ashamed of himself though.
#   however, true to his motto, I think he did indeed explore the
#   utmost limits of ye' motto. I hope he learned what he taught others,
#   and not just the limits of what he was able to get away with.
#
# sure, you can do as thou wilt. please do. the UniVerse is your sandbox!
# play, as if you were only a few years old.
#
# - MechanicOfTheSequence

Path = require \path
Url = require \url

{ Fsm, Fabuloso, ToolShed, _ } = require 'MachineShop'
{ Debug } = ToolShed
# { PublicDB, LocalDB, Blueprint } = require './PublicDB'
{ PublicDB, LocalDB } = require './PublicDB'

Library = require './Library' .Library
# Session = require './Session' .Session
# Book = require './Book' .Book
StoryBook = require './StoryBook' .StoryBook

# because UniVerse is a singleton, I use this
var _universe

# clean me!!
url = Url.parse window.location.href
cur_proto = url.protocol
cur_host = url.host
var cur_watcher, cur_file

# future services:
# email:
# http://www.nodemailer.com/

# cdn:
# https://hacks.mozilla.org/2014/03/jsdelivr-the-advanced-open-source-public-cdn/

# spdy
# https://github.com/indutny/node-spdy

# poems:
# cool note taking app:
# https://laverna.cc/index.html

###########################
###########################
###########################


###########################
###########################
###########################


###########################
###########################
###########################

class UniVerse extends Fsm # implements Fabuloso
	# if typeof _universe is \object
	# 	return _universe
	->
		refs = {UniVerse: @}
		_universe := this
		@persona = false
		# for now, the session is with the universe.
		# I think this is the most logical

		# refs.book = @book = new StoryBook
		# @library = new Library
		# @archive = new PublicDB name: \MultiVerse # more on the MultiVerse later :)
		refs.archive = @archive = new PublicDB name: \UniVerse
		# @archive.once_initialized ~>
		# 	@transition \ready
		refs.library = @library = new Library refs, name: \sencillo # host: ...
		# refs.XpDB = @XpDB = new ExperienceDB

		ToolShed.extend @, Fabuloso
		super "UniVerse"

	# default: host_poem
	# poem: host_poem #\Affinaty

	eventListeners:
		'*': (evt, opts) ->
			if evt.indexOf('dep:') is 0
				# dep:Poem:Affinaty
				[dep, name, version, ready] = evt.split ':'
				console.log "we got a dep request!!", evt, opts, name, ready
				# #refs.db.get collection, name
				# unless ready
				# 	bp = UniVerse.db.get name
				# 	bp.once \state:ready, ~>
				# 		opts = ToolShed.objectify bp._blueprint
				# 		opts.path = url.path if url.path
				# 		poem = new Poem name, refs, ToolShed.objectify bp._blueprint
			else switch evt
			| \auth =>
				# session = &.0
				# UniVerse.poem = session.poem
				# UniVerse.mun = session.mun
				# console.log "set poetry to poem #{UniVerse.poem} - mun #{UniVerse.mun}"
				fallthrough
			| \noauth \disconnected \connected =>
				console.error "event.*", evt, &
				re-emit = true
			# if re-emit
			# 	for name, p of UniVerse._
			# 		console.log "re-emit.*" name, p.state
			# 		# if p.state.0 isnt '/'
			# 		# 	p.once_initialized evt, opts
			# 		# else
			# 		if p.active or true
			# 			console.info "re-emitting in", name, evt, opts
			# 			p.emit evt, opts

		auth: (persona) ->
			@debug "WE HAVE AUTH"
			@persona = persona

		noauth: ->
			@persona = false

		transition: !(e) ->
			console.log "#{@namespace} transition (%s -> %s)", e.priorState, e.toState
			execs = Object.keys @states[e.toState]
			_.each @_derivitaves, (v, derivitave) ~>
				d_name = "derivitave.#derivitave"
				for exec in execs
					if exec is d_name then @exec exec

		# 'dep:Poem': (name, id) ~>
		# 	if @derivitave \node-webkit
		# 		console.log "init the node-webkit way (require)"
		# 	else if @derivitave \browser
		# 		console.log "init the poem the browser way"

		# 	console.log "going to init poem:", name
		# 	console.error "TODO: move tis poem over to its own file", name
		# 	process = (data) ~>
		# 		unless data
		# 			attempt_disk!
		# 		else
		# 			#console.log "bp data:", typeof data, data
		# 			#console.log "your bp(#name) is:",	ToolShed.objectify data
		# 			poem = new Poem name, refs, ToolShed.objectify data
		# 			poem.once "state:ready" ~>
		# 				console.log "dep:Poem ready:: ", name
		# 				UniVerse.emit "dep:Poem:#name:ready"

		# 	attempt_disk = ~>
		# 		path = Path.join \lib \Poems name+'.poem'
		# 		ToolShed.readFile path, (err, data) ~>
		# 			UniVerse.archive.set "Blueprint:#name", data
		# 			#ToolShed.objectify data
		# 			process data
		# 	dfd = UniVerse.archive.get "Blueprint:#name"
		# 	dfd.done process
		# 	dfd.fail attempt_disk
		# 	# poem = new Poem name, refs, {

		# 	# }
		# 	# debug " made poem... goeing to route now..."
		# 	# poem.once \state:ready ~>
		# 	# 	UniVerse.emit "dep:Poem:#{poem.name}:ready", poem
		# 	# 	console.log "poem ready", poem

		# 'dep:Blueprint': (name, opts) ~>
		# 	console.error "TODO: 'dep:Blueprint'", &
		# 	console.error "dep", Path.join \Blueprints, name+'.blueprint'
		# 	process = (data) ~>
		# 		unless data
		# 			attempt_disk!
		# 		else
		# 			#console.log "bp data:", typeof data, data
		# 			#console.log "your bp(#name) is:",	ToolShed.objectify data
		# 			bp = new Blueprint refs, ToolShed.objectify data
		# 			bp.once "state:ready" ~>
		# 				console.log "dep:blueprint ready:: ", name
		# 				UniVerse.emit "dep:Blueprint:#name:ready"

		# 	attempt_disk = ~>
		# 		path = Path.join \lib \Blueprints name+'.blueprint'
		# 		ToolShed.readFile path, (err, data) ~>
		# 			UniVerse.archive.set "Blueprint:#name", data
		# 			#ToolShed.objectify data
		# 			process data
		# 	dfd = UniVerse.archive.get "Blueprint:#name"
		# 	dfd.done process
		# 	dfd.fail attempt_disk

	states:
		uninitialized:
			onenter: ->
				#TODO: show loading spinner updates
				task = @task 'initializing...'
				# task.push (done) ~>
				# 	console.log "loading StoryBook"
				# 	@book.once_initialized ~>
				# 		console.log "StoryBook is ready!"
				# 		done!
				# task.push (done) ~>
				# 	console.log "loading Library"
				# 	# refs.db = @db = db = PublicDB refs, name: 'localhost'
				# 	# refs.bp = {}
				# 	@library.once_initialized ~>
				# 		console.log "db is ready!"
				# 		done!
				task.push (done) ~>
					console.log "loading PublicDB"
					# refs.db = @db = db = PublicDB refs, name: 'localhost'
					# refs.bp = {}
					@archive.once_initialized ~>
						console.log "db is ready!"
						done!

				# task.push (done) ~>
				# 	console.log "going to check session"
				# 	@session.once_initialized ->
				# 		console.log "session is initialized"
				# 		done!

				task.end (err, res) ~>
					console.log "all init tasks done!"
					@transitionSoon \ready



		ready:
			onenter: ->

			auth: (err, session) ->
				# console.log "ready.auth:", err, session
				if err
					@emitSoon \noauth, err
				else
					@emitSoon \auth, session

			#TODO: make this only for the browser derivative... to allow for headless universes opening storybooks
			'new:StoryBook':  ->

			# persona: (cb) !->
			# 	if typeof cb is \function
			# 		ToolShed.debug_fn cb

			# 	# got to get the persona
			# 	if typeof cb is \function
			# 		if @persona
			# 			cb persona
			# 		else
			# 			@session.exec \persona, cb
			# 	else
			# 		throw new Error "dude, you need to pass a callback to UniVerse.exec \\persona"
			# 	# debugger


		# mun:~
		# 	~> @_mun
		# 	(m) ~>
		# 		# change out the mun
		# 		# back button
		# 		# route ... path, etc
		# 		#@emit \changing_mun, m
		# 		@_mun = m


	begin: (refs, el, id) ->
		# refs <<< @refs
		refs.library = @library
		new StoryBook refs, el, id


Object.defineProperty exports, "UniVerse", {
	get: ->
		_universe || _universe := new UniVerse
		# debugger
		return _universe
}

# _universe.on \new_task (task) ->
# 	console.info "TODO: show loading screen"

# _universe.on \disconnected (backoff) ->
# 	console.info "TODO: show disconnected screen"

# _universe.on \connected (what) ->
# 	console.info "TODO: remove disconnected screen"