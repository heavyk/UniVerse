idea: \Timing
type: \Mutable
description: "used by mutable elements to go questing (for keys)"
combines:
	Quest: \latest
improves:
	# the extension process needs to be done correctly
	# right now if I extend eventListeners, it'll fail because some event listeners are arrays.
	# they should use the same structure as the extension process to ensure correct extension
	'extend.initialize': ->
		console.log "WE ARE TIMING!!", @namespace
		console.log "welcome to an extension of Time"
		@_sentence = []
		# @_keys = []
		if @quests
			ToolShed.extend @quests, @_bp._blueprint.quests
		else
			@quests = @_bp._blueprint.quests

	# gonna write that bitch a sonnet. bitches love sonnets -shakespeare
	# length:~
	# 	->
	# 		# debugger
	# 		@quest.keys.length || 0
	# 	(v) ->
	# 		@quest.size_top = 4
	cmds:
		eventListeners:
			'*': (evt) ->
				if evt.indexof('add:') is 0
					if example = @find @poetry, what = evt.substr(4)
						@_sentence.push word = example.apply this, &.slice 1
						@emit "added:#what"
					else
						throw new Error "tried to add '#what' to the sentence, but I'm not sure what it is. add it to the concepts"
				else if evt.indexof('addAt:') is 0
					if example = @find @poetry, what = evt.substr(4)
						@_sentence.splice word = example.apply this, &.slice 1
						@emit "added:#what"
					else
						throw new Error "tried to add '#what' to the sentence, but I'm not sure what it is. add it to the concepts"

		more_quest: ->
			if not @quest
				@debug.error "not questing anything!"
				return
			if not @quest._id
				@debug.error "nothing more to quest!"
				return
			@quest.exec \more_quest


		quest: (key, opts) ->
			# debugger
			if @quest
				debugger
				console.log "this is probably an error because the event listeners need to be removed from the old quest and we neeed to garbage collect ot correctly"
			console.log "should do this above..."
			@quest = q = new Quest @_bp, key, opts
			verse = @
			q.on \* !->
				verse.emit ...
			# q.on \*, _.bind @emit, @
			@transition key
