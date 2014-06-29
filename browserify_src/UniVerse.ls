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

{ Fsm, ToolShed, _ } = require 'MachineShop'
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

class UniVerse extends Fsm
	->
		refs = {UniVerse: @}
		_universe := this
		@persona = false
		# this is the universe. more on the MultiVerse later :)
		refs.archive = @archive = new PublicDB name: \UniVerse
		refs.library = @library = new Library refs, name: \sencillo

		ToolShed.extend @, Fsm.Empathy
		super "UniVerse"

	eventListeners:
		auth: (persona) ->
			@debug "WE HAVE AUTH"
			@persona = persona

		noauth: ->
			@persona = false

		transition: !(e) ->
			@debug "#{@namespace} transition (%s -> %s)", e.priorState, e.toState
			execs = Object.keys @states[e.toState]
			_.each @_derivitaves, (v, derivitave) ~>
				d_name = "derivitave.#derivitave"
				for exec in execs
					if exec is d_name then @exec exec

	states:
		uninitialized:
			onenter: ->
				# this is a pretty weak task. there is only one operation
				task = @task 'initializing the UniVerse...'
				task.push (done) ~>
					@debug "loading PublicDB"
					@archive.once_initialized ~>
						@debug "db is ready!"
						done!

				task.end (err, res) ~>
					@debug "all init tasks done!"
					@transitionSoon \ready



		ready:
			onenter: ->

			auth: (err, session) ->
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
