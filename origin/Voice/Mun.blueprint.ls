# for now I'll just check to see what type it is:
# - Voice -> Cardinal
# - Word -> Fixed
# - Verse -> Mutable


encantador: \Verse
incantation: \Mun
type: \Mutable
version: \0.1.0
poetry:
	Word:
		Mun: \latest
	Voice:
		Mun: \latest
# (re)quests:
quests:
	# this one is kinda tricky, because I should have to check permissions here...
	# TODO later :)
	# actually, now that I thrink about it, this should be done on a per-item basis, with the ability to fetch a batch of objects
	# this will be better for the open version, and it'll also be easier to optimize/cache
	# I also really wanna use pub/priv keys to make sure everything is super duper sweet

	# I can also pretty easily parse to be sure you're returning the key...
	# ¿did you get it? you're questing for keys... Bwaaaahahahahahahha :P
	# YOU ALWAYS RETURN THE KEY...
	# images of zelda are flittering through my head like a lost princess waiting for her prince with thre right key (to her chastity belt?)

	'where my dawgs at?':
		# FILTER (m.persona == @persona || m.uid == @persona)
		inquiry: """
			FOR m IN Mun
				FILTER m.persona == @persona
				RETURN m._key
			"""
		# neither of these are necessary, really
		# this one is server-side
		have: (db, req, res) ->
			persona: if req.user then req.user._key else null

		want: ->

	"who's got a RelationShip with this Mun?":
		# this one is client-side
		inquiry: """
			FOR r IN RelationShip
				FILTER r.mun1 == @who
				RETURN r.mun2
			"""
		have: (db, req, res) ->
			@check-visibility-with req.params(\who)
		want: (id) -> who: id


	# relations:
	# 	AQL: """
	# 		FOR r IN RelationShip
	# 			FILTER r.mun1 == @mun
	# 			RETURN r.mun2
	# 		"""

machina:
	# I was thinking that verses could have various messages...
	# kinda, you know, boost the creativity...
	motd:
		* "a farmer out standing in his field is more outstanding in his field than other farmers not out standing in their field"
		* "a good farmer is probably one that's out standing in his field of work"
		* "a bad farmer is probably one that's out standing *at* his field of work"
		* "a farmer out standing in his field is likely more outstanding in field of work"
	order: <[before list after !voice]>
	"extend.initialize": ->
		# _.each Object.keys(@states), (state) ~>
		# 	if typeof (s = @states[state].eventListeners) is \string
		# 		@states[state].eventListeners = @_get_path.call @, s
		if typeof @tone is \string and tone = @poetry.Word[@tone]
			@tone = tone
		else if typeof @tone is \object
			_.each @tone, (t, i) ~>
				if typeof t is \string and tone = @poetry.Word[t]
					@tone[i] = tone
	eventListeners:
		'*': (evt) ->
			state = @state
			args = [].slice.call &, 1

			if ~(idx = evt.indexOf '::')
				part = @_parts[p = evt.substr 0, idx]
				# evt = evt.substr idx+2
				# debugger

			if typeof (listeners = @states[@state].eventListeners) is \object and typeof (l = listeners[evt]) is \function # render = @states[@state][evt] # and part = @_parts[evt]
				# aC part, renderer.apply @, [cE] ++ args
				# debugger
				ret = l.apply @, [cE] ++ args
				if part
					$ part .empty!
					# debugger
					aC part, ret

		# I think it's wise to only allow a back button (or an undo) between
		# states that start with '/'
		# ... start with '\' (text ones) don't count.
		# so, it could be: '/home' -> 'loading' -> 'another_loading' -> '/profile'
		# then, the back button would just send you '/profile' -> '/home'
		#      /
		#      /profile
		# ready
		#      \uninitialized
		#      \ready


	states:
		#-notes:
		# the idea here is that it's based on time
		# the query should make a time-space continuum
		# that way, we can have automatic updates based on time.
		# obviously if the time has passed the quest is finished...
		# verses can only be on objects that embody Timely
		# TimelyVoice
		#-changes:
		# top -> before
		# after -> after
		# evt::after:more
		# evt::before:more
		# evt::before:space
		# evt::after:space
		# evt::nada
		# fix the process.nextTick deal and meke sure it's extending correctly


		'where my dawgs at?':
			# actually this isn't necessary because it's defined above
			order: <[before list after voice]>
			parts:
				before: (E) -> E \h3 null "nothin goin on here yet..."
				list: (E) -> E \div c: \listy-munz, "loading... :: where my dawgs at????"
				after: (E) -> E \div c: \vocal-input
				voice: (E) ->
					window.voice = @poetry.Voice.Mun {persona: @book.session.persona} goto: \add_another

			onenter: ->
				verse = @
				# debugger

			onexit: ->
				@quest.off \* @emit
				# empty: (E) ->
				# 	# for now, I just use empty, but the following while function will also work.
				# 	# E.$ @_parts.list .empty!
				# 	lala = @_parts.list
				# 	while el = lala.firstChild
				# 		lala.removeChild el

				# nada: (E) ->
				# 	# debugger
				# 	E.aC @_parts.list, window.voice = @poetry.Voice.Mun {persona: @book.session.persona} goto: \nue

				# added: (E, id) ->
				# 	debugger
				# 	E.aC @_parts.list, @poetry.Word.Mun id, {goto: \session_list}

				# more: (E) ->
				# 	E.aC @_parts.after,
				# 		if diff = @quest.total - @quest.keys.length
				# 			E \div c: \more onclick: (~> @exec \more_quest), "#{diff} more"
				# 		else ''
			eventListeners:
				created: (xp) ->
					debugger
					console.log "voice: yay we're saved"

				empty: (E) !->
					# for now, I just use empty, but the following while function will also work.
					#  rC is shorthand for replaceChildren. it is used like thsis:
					#  rC(el, [[child | child_els[]], idx])
					# 1. E.rC @_parts.list

					#  this is jQuery.. RTFM :)
					# 2. E.$ @_parts.list .empty!

					# this is standard DOM manipulation (fastest, but least understandable and doesn't take advantage of machina attach/detach/gc functions)
					# 3. lala = @_parts.list
					#    while el = lala.firstChild
					#      lala.removeChild el

					E.rC @_parts.list#, E \div null "nothing..."
					E.$ @_parts.voice .show!

				voice: (E) !->
					unless @_parts.voice.length
						E.aC @_parts.voice, @poetry.Voice.Mun {}, goto: '/nue'
					E.$ @_parts.voice .show!

				silence: !->
					E.$.hide @_parts.voice

				nada: (E) ->
					# debugger
					@emit \voice
					# E.aC @_parts.list, window.voice = @poetry.Voice.Mun {persona: @book.session.persona} goto: \nue

				added: (E, key) ->
					# debugger
					E.aC @_parts.list, @poetry.Word.Mun key, {goto: \session_list}

				addedAt: (E, key, idx) ->
					# debugger
					mun = @poetry.Word.Mun key, {goto: \session_list}
					mun.on \set_active ~>
						debugger
					E.aC @_parts.list, mun, idx

				removedAt: (E, key, idx) ->
					console.log "gonna remove", idx, c = @_parts.list.childNodes[idx]._machina.key
					# debugger
					@_parts.list.removeChild @_parts.list.childNodes[idx]

				more: (E) ->
					if diff = @quest.total - @quest.keys.length
						E.rC @_parts.after, E \div c: \more onclick: (~> @exec \more_quest), "#{diff} more"
					else
						E.rC @_parts.after

				# 'after::more': (E) ->
				# 	if diff = @quest.total - @quest.keys.length
				# 		E \div c: \more onclick: (~> @exec \more_quest), "#{diff} more"
				# 	else ''

		uninitialized:
			onenter: ->
				console.log "verse:mun... uninitialized"

			before: (E) ->
				E \div c: \more-before, "before!!"
			list: (E) ->
				E \div c: \uninitialized, "verse:mun... uninitialized"
			after: (E) ->
				E \div c: \more-after, "after!!"
			voice: (E) ->
				E \div c: \more-voice

		# mine:
		# 	onenter: ->
		# 		console.log "gonna do a query for my muns..."
		# 	query: """
		# 		FOR m IN Mun
		# 			FILTER m.pid == @persona
		# 			RETURN m
		# 		"""
		# 	tone-other-option: (E) ->
		# 		E \div c: \my-mun,
		# 			E \h2 c: \title, @get \name
		# 	tone: (E) -> @poetry.Word.Mun

		# 	list: (E) ->
		# 		E \div null "your muns...",
		# 			E \ul null, ->
		# 				verse = @poetry.Verse.Mun \small_list
		ready:
			onenter: ->
				console.log "Verse: we're ready"

			list: (E) ->
				# debugger
				E \div null "a ready element"
