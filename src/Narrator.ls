
Url = require \url
assert = require \assert

{ Fsm, ToolShed, Fabuloso, _ } = require 'MachineShop'

# this does almost everything this guy wants:
# http://mvalente.eu/category/programming/

# for later, when objects change their values and we need to pay the XP for the change
# class Experience extends Scope

# for later, when we can save xp into the universe for changes to the Experience
# class ExperienceDB extends Fsm

# for later, when we can have a market
# class Currency extends Fsm

# for later, when we get blueprints out of the ether
# class EtherDB extends Fsm

class Narrator extends Fsm
	(refs, id) ->
		self = @
		if typeof refs isnt \object
			throw new Error "you need to pass a 'refs' object to the Narrator"
		else
			@refs = _.clone refs

		@library = refs.library
		@refs.narrator = refs.narrator = @

		@poetry = {}
		@memory = {}
		@poems = []
		@poem = null
		@poem_fqvns = []
		@words = {}
		@_ = {}

		ToolShed.extend @, Fabuloso
		super "Narrator"
		if typeof id is \string
			@debug.todo "load up a narrator from the database of a defined id (figurehead)"

	initialize: ->
		console.log "narrator initialize!!!!!!"
		# debugger

	eventListeners:
		invalidstate: (e) ->
			@debug.error "oh shit we're invalid (#{e.state} -> #{e.attemptedState})"


	states:
		uninitialized:
			onenter: ->
				@debug "Narrator waiting for something to do..."
				# debugger
				# @transition \ready

	cmds:
		open: (name, version, path, cb) ->
			console.log "if the poem is not downloaded, download it", &
			console.log "once the poem is downloaded and loaded, switch to it"
			if typeof name isnt \string
				throw new Error "we can't figure out the name of the poetry you're trying to load"
			if typeof fqvn isnt \string
				fqvn = name

			# if typeof version is \function
			# 	cb = version
			# 	path = version = void
			# if typeof path is \function
			# if not path
			# 	path = '/'

			# @states[name] = new Book refs, fqvn
			# eth = uV.archive.get \Poem, name
			# debugger
			# uV.archive.exec \fetch "Poem/#name", (err, bp) ->

			uV.machina.exec \fetch {
				inception: "StoryBook"
				implementation: name
				version: version
				narrator: @
			}, (err, eth) ~>
				# eth.refs <<< @refs
				# debugger
				eth.once_initialized ~>
					@debug "POEM INITIALIZED.... going to imbue the poem now..."
					noem = name+'@'+version
					@debug.todo "replace_path here with the poem loaded ... later replace again"
					@debug "loading poem '#noem' with sess_id: #sess_id"
					@poem = poem = @poetry.Poem[name] sess_id
					poem.on \transition (evt) ~>
						console.log "transition evt", evt.toState
						if evt.toState.indexOf('/') is 0
							console.log "set the path!!", evt.toState
							@push_path {poem: poem.fqvn, path: evt.toState}, poem.title
					fqvn = name+'@'+version
					@states[fqvn] = {}
					@states[fqvn].render = poem
					@poems.push poem
					@poem_fqvns.push fqvn
					# transition the storynarrator to the poem in use
					@transition name+'@'+version
					# debugger
					poem.transition @path
					@debug.todo "load up the path into the poem"
					# debugger
					# done!

export Narrator