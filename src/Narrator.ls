
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
			# bp = uV.archive.get \Poem, name
			# debugger
			# uV.archive.exec \fetch "Poem/#name", (err, bp) ->

			uV.library.exec \fetch {encantador: "StoryBook" incantation: name, version, narrator: @}, (err, bp) ~>
				# bp.refs <<< @refs
				# debugger
				bp.once_initialized ~>
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

	# replace_path: (data, title) ->
	# 	window.history.replaceState data, title, data.path
	# push_path: (data, title) ->
	# 	window.history.pushState data, title+Math.random!toString(32).slice(2), data.path

	# route: (path, is_back) ->
	# 	window_href = window.location.href + ''
	# 	window_href_base = window_href.substr 0, window_href.lastIndexOf '/'
	# 	console.error "routing path", path, is_back, window_href
	# 	poem = @state
	# 	# if ~path.indexOf window_href_base
	# 	# 	path = path.substr window_href_base.length
	# 	# else
	# 	# 	if ~path.indexOf "://"
	# 	# 		proto = path.split '://'
	# 	# 		if proto.length > 1
	# 	# 			[proto, path] = proto
	# 	# 		else
	# 	# 			proto = \http
	# 	# 			path = proto.0
	# 	# 	#[host, path] = path.split '/'
	# 	# 	if (i = path.indexOf '/') > 0
	# 	# 		host = path.substr 0, i
	# 	# 		path = path.substr i
	# 	# 	else if i is 0
	# 	# 		host = cur_host
	# 	# 		path = path
	# 	# 	else
	# 	# 		host = path
	# 	# 		path = '/'
	# 	url = Url.parse path
	# 	if url.path
	# 		path = url.path
	# 	if url.protocol
	# 		proto = url.protocol

	# 	querystring = ''
	# 	if i = ~path.indexOf '?'
	# 		querystring = path.slice i + 1
	# 		path = path.slice 0, i

	# 	console.log "route:", path, "->", @path
	# 	if path isnt @path
	# 		console.error "before transition", path, {poem, path, mun}
	# 		poem = @states[@state].render
	# 		# debugger
	# 		poem.transition path, {poem, path}
	# 		console.log "after transition"


# console.log "before extend:", Narrator::initialize
# debugger
ToolShed.extend Narrator::, Fabuloso
export Narrator