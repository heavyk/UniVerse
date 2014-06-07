idea: \Sentence
type: \Abstract
description: "used by mutable elements to as a list of words"
improves:
	# the extension process needs to be done correctly
	# right now if I extend eventListeners, it'll fail because some event listeners are arrays.
	# they should use the same structure as the extension process to ensure correct extension
	'extend.initialize': ->
		@_sentence = []

	# gonna write that bitch a sonnet. bitches love sonnets -shakespeare
	# length:~
	# 	->
	# 		# debugger
	# 		@quest.keys.length || 0
	# 	(v) ->
	# 		@quest.size_top = 4
	cmds:
		eventListeners:
			'*': (evt, arg1, arg2, arg3) ->
				if evt.indexof('add:') is 0
					if word = @find @poetry, another = evt.substr(4)
						@emit "added:#another", new word arg1, arg2
					else
						@debug.error "tried to add '#another' to the sentence, but I'm not sure what it is. add it to the concepts"
						@machina.send \blueprint:missing:concepts, another
				else if evt.indexof('addIn:') is 0
					if word = @find @poetry, another = evt.substr(4)
						@emit "addedIn:#another", arg1, new word arg2, arg3
					else
						@debug.error "tried to add '#another' to the sentence, but I'm not sure what it is. add it to the concepts"
						@machina.send \blueprint:missing:concepts, another
				else if evt.indexof('added:') is 0
					@_sentence.push arg1
				else if evt.indexof('addedIn:') is 0
					@_sentence.splice arg1, 1, arg2
				#TODO: remove (id)
				#TODO: update (id, diff)
