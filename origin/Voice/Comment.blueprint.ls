
encantador: \Verse
incantation: \Comment
type: \Mutable
version: \0.1.0
poetry:
	Word:
		Comment: \latest
	Voice:
		Comment: \latest
# (re)quests:
quests:
	"tell me something good!":
		inquiry: """
			FOR m IN Comment
				FILTER m.receiver == @mun
				RETURN m._key
			"""
		have: (db, req, res) ->
			require \console .log "HAVE!!!!!!"
			mun: "11"
			# mun: if req.user then req.user.data.mun else null

	# 'get my comments':
	# 	have: (db, req, res) ->
	# 		return
	# 			author: req.user.data.mun
	# 	inquiry: """
	# 		FOR c IN #{@encantador}
	# 			FILTER c.author = @author
	# 			RETURN c._key
	# 		"""
	# "someone else received these comments":
	# 	want: (id) ->
	# 		if typeof id isnt \string
	# 			throw new Error "wrong type of id, dude"
	# 		recipient: id
	# 	inquiry: """
	# 		FOR c IN #{@encantador}
	# 			FILTER c.recipient == @recipient
	# 			RETURN c._key
	# 		"""
	# "someone else wrote these comments":
	# 	# have: # this is unnecessary
	# 	want: (id) ->
	# 		if typeof id isnt \string
	# 			throw new Error "wrong type of id, dude"
	# 		author: id
	# 	inquiry: """
	# 		FOR c IN #{@encantador}
	# 			FILTER c.author = @author
	# 			RETURN c._key
	# 		"""

machina:
	# I was thinking that verses could have various messages...
	# kinda, you know, boost the creativity...
	motd:
		* "TODO"
	order: <[before list after !voice]>
	# "extend.initialize": ->
	# 	# _.each Object.keys(@states), (state) ~>
	# 	# 	if typeof (s = @states[state].eventListeners) is \string
	# 	# 		@states[state].eventListeners = @_get_path.call @, s
	# 	if typeof @tone is \string and tone = @poetry.Word[@tone]
	# 		@tone = tone
	# 	else if typeof @tone is \object
	# 		_.each @tone, (t, i) ~>
	# 			if typeof t is \string and tone = @poetry.Word[t]
	# 				@tone[i] = tone
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


		'tell me something good!':
			# actually this isn't necessary because it's defined above
			order: <[before list after voice]>
			parts:
				before: (E) -> E \h3 null "nothin goin on here yet..."
				list: (E) -> E \div c: \listy-munz, "loading... :: where my dawgs at????"
				after: (E) -> E \div c: \vocal-input
				voice: (E) ->
					window.voice = @poetry.Voice.Comment {author: @book.session.mun} goto: \profile_comment

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
					E.aC @_parts.list, @poetry.Word.Comment key, {goto: \profile_list}

				addedAt: (E, key, idx) ->
					# debugger
					comment = @poetry.Word.Mun key, {goto: \profile_list}
					E.aC @_parts.list, comment, idx

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
