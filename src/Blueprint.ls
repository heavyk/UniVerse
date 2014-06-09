
# require! \Livescript
# require! \MachineShop

# { ToolShed, Fsm, Empathy, Machina } = MachineShop

assert = require \assert
Http = require \http
Url = require \url
Path = require \path
Walk = require \walkdir
path-to-regexp = require \path-to-regexp

require! \MachineShop

{ ToolShed, Fsm, Machina, DaFunk, Empathy } = MachineShop

# { StoryBook } = require './StoryBook'
# { ExperienceDB, Perspective, Quest } = require './ExperienceDB'

# Meaning = require './origin/Meaning' # for Blueprints
# Motivator = require './origin/Motivatation' # for Processes
# Tone = require './origin/Concept/Tone'
# Timing = require './origin/Concept/Timing'

# ConceptDB -> Concept -> Idea
# EstablishDB -> Infrastructure (for npm modules - LevelDB backed)

# a Mutable element (Verse) has both a Word (fixed) and Voice (cardinal) - and they're all imbued with meaning :)
# if the voice doesn't have meaning yet, it's empty
# if the word doesn't have meaning yet, it's empty
# if the verse doesn't have meaning yet, it's empty
#  (and rhythm is the IArray of words)

# Cardinal element (Voice)
# this class used to be called 'Vagina' but that name wasn't exactly "final"
#  ... it does receive 'input'
#  ... it does need lubricator/latex in case of hostile environments
#  ... a comment box is sorta like a single input experience
#  ... they should catch everything you're doing wrong
#  ... they should also help you to input it correctly
# 1. smart vaginas look over inconsequential errors
# 2. smart vaginas will guide you through the process instead of bitch at you with unintelligible errors
# 3. you'd think input would be a pleasurable experience!
#  ... the goal of this class would be to make input more satisifying
# (((forgive the vugarity - aquella noche, it made perfect sense)))

# I do find it interesting that I'm repeatedly combining two types into one:
# encantador is the script
# incantation is the experience
# experiences are stored in the incantation
# encantador is what gives the experience form

# class Vacancy/ Voice extends Fsm

# a series of opinions can be a path to righteousness / destruction


# using experience, we can convert "I believe" into "I know" - this is where exerience bonus points can come from

# TranscendentalPersona
# it's a Persona pero Transcendental
# la persona takes on a new identity and someone else comes in her place
# sorta like passing the master's baton to the disciple
# therefore, she, being a persona transcendental, eventually passes on the baton for a new

# so, a persona is only the starting point ->
	# a TranscendentalPersona becomes a Mun
	# a mun does not necessarily mean a single identity

Symbolic = {}

# OPTIMIZE: use quicksort to rearrange the elements (or even, make it customizable!)
# OPTIMIZE: pass the rendering over to the UniVerse machina to ensure optimized rendering (requestAnimationFrame, etc.)
# IMPROVEMENT: allow the rearrangment of elements to be configurable (quicksort, etc.)
# IMPROVEMENT: allow for transitions for the elements when they're rearranged
# this is code converted to ls from:
# https://gist.github.com/paullewis/1981455
# the idea is to take this and make it part of the sorting mechanism for the
# part renderers.
# the idea is that I use quicksort to rearrange the elements in the order list
#
# Quicksort = (->
# 	swap = (array, indexA, indexB) ->
# 		temp = array[indexA]
# 		array[indexA] = array[indexB]
# 		array[indexB] = temp
# 	partition = (array, pivot, left, right) ->
# 		storeIndex = left
# 		pivotValue = array[pivot]
# 		swap array, pivot, right
# 		v = left
# 		while v < right
# 			if array[v] < pivotValue
# 				swap array, v, storeIndex
# 				storeIndex++
# 			v++
# 		swap array, right, storeIndex
# 		storeIndex
# 	sort = (array, left, right) ->
# 		pivot = null
# 		left = 0 if typeof left isnt 'number'
# 		if typeof right isnt 'number' then right = array.length - 1
# 		if left < right
# 			pivot = left + Math.ceil (right - left) * 0.5
# 			newPivot = partition array, pivot, left, right
# 			sort array, left, newPivot - 1
# 			sort array, newPivot + 1, right
# 	{sort: sort})!

# perhaps a Voice (Cardinal element) should extend Vagina, lol
# what if we were to make this a Vacancy??
# wait, maybe a Vacancy should be the abstract element to Knowledge
# right, so knowledge should define the space between things with some sort of experience
# Knowlege is a Heart element


# this is a really retarded hack to make sure that 'slice$' is defined in the window
# pero me parece, que ahora no lo necesito...
# though, this reminds me that I need to sort out the deps and optimize well :)
# lala = (lala, ...lolz) ->

# this class gives "meaning" to the 'Word' (data) by spawning it with the encantador
# hehe, it's a Word Document ... get it?
# Meaning is a Fixed sign (think astrology)

# a Voice (Cardinal) extends Meaning implements Tone
# a Verse (Mutable) extends Meaning implements Timing
# a Word or Poem (Fixed) extends Meaning implements Definition

get_path = (obj, str, split = '.') ->
	str = str.split split
	i = 0
	while i < str.length
		obj = obj[str[i++]]
	obj
# I think the one above is the fastest.
# I also think that the above function can be optimized by using indexOf and substr -- another time I suppose :)
#OPTIMIZE! - jsperf anyone? (this is an almost useless optimization and should be added to Current too. Current shlould be fastest general lib - like lodash)
#get_path2 = (obj, str) -> (str.split '.').reduce ((o, x) -> o[x]), obj
set_path = (obj, str, val, split = '.') ->
	str = str.split split
	while str.length > 1
		obj = obj[str.shift!]
	obj[str.shift!] = val


#NOTE: the name, NodeJSBlueprint isn't good. it will be changed.
class NodeJSBlueprint extends Fsm
	(refs, opts) ->
		if typeof opts is \undefined
			opts = refs

		if typeof opts is \object
			if opts.encantador
				@encantador = opts.encantador
			if opts.incantation
				@incantation = opts.incantation
			if opts.version
				@version = opts.version
		else if typeof opts is \string
			throw new Error "TODO: uri parsing"
		else
			throw new Error "we don't know whot to do with your blueprint, sorry"

		if typeof refs isnt \object
			@debug.error "you need to pass a 'refs' object to the StoryBook"
		else if not refs.book
			throw new Error "you have to reference a PoetryBook for a blueprint because we save the imbuement into the poetry book, obviously"

		@_blueprint = opts

		unless @incantation
			console.error "you need a incantation for your blueprint!"
			throw new Error "you need a incantation for your blueprint!"

		unless @encantador
			console.error "you need a encantador for your blueprint!"
			throw new Error "you need a encantador for your blueprint!"

		# if typeof (XpDB = book.library[@incantation]) is \undefined
		# 	XpDB = book.library[@incantation] = new ExperienceDB @incantation

		# @XpDB = XpDB

		# if typeof @version is \object
		# 	_version = @version
		# 	version = @version.version
		# 	debugger
		# 	console.log "ALL WRONG"
		if not @version or @version is \*
			@version = \latest

		super "Blueprint(#{@uri = @encantador+':'+@incantation+'@'+@version})"
		# if bp = Blueprint._[long_incantation] and typeof DEBUG isnt \undefined
		# 	return bp

	imbue: (book) ->
		assert book instanceof StoryBook
		# debugger
		if @state is \ready
		# else if not (blueprint_inst = library.blueprints[@encantador])
			console.log "we're gonna make a new imbuement here..."
			var blueprint_inst
			library = @refs.library #.poetry
			_bp = @
			_deps = @_deps
			_blueprint = @_blueprint
			# if typeof book.library.memory[@incantation] is \undefined
			# 	book.library.memory[@incantation] = new ExperienceDB @incantation
			# I'm not terribly happy with this... I really want to sort out the library and the databases...
			# for now though, this is good enough
			if typeof book.memory[@incantation] is \undefined
				book.memory[@incantation] = new ExperienceDB @incantation
			#OPTIMIZE: this could be potentially costly to call ToolShed.extend ... I dunno...
			#OPTIMIZE: perhaps instead of eval, we should use new Function
			if typeof book.poetry[@encantador] is \undefined
				eval """
				(function(){
					var #{@encantador} = blueprint_inst = (function(superclass){
						var prototype = extend$((import$(#{@encantador}, superclass).displayName = '#{@encantador}', #{@encantador}), superclass).prototype, constructor = #{@encantador};
						function #{@encantador} (book, _bp, key, opts) {
							if(!(this instanceof #{@encantador})) return new #{@encantador}(key, opts);
							//#{if @type is \Cardinal then 'ToolShed.extend(this, DefineTone);' else ''}
							//#{if @type is \Mutable then 'ToolShed.extend(this, DefineTiming);' else ''}
							//#{if @type is \Fixed then 'ToolShed.extend(this, DefineSymbolic);' else ''}
							#{@encantador}.superclass.call(this, book, _bp, key, opts);
						}
						ToolShed.extend(prototype, _blueprint.machina);
						return #{@encantador};
					}(Meaning));
					ToolShed.extend(#{@encantador}, Magnetism);
					book.poetry['#{@encantador}'] = #{@encantador};
				}())
				"""

			if @encantador isnt @incantation
				eval """
				(function(){
					var #{@incantation} = blueprint_inst = (function(superclass){
						var embodies = _deps.embodies, prototype = extend$((import$(#{@encantador}, superclass).displayName = '#{@encantador}', #{@encantador}), superclass).prototype, constructor = #{@encantador};
						function #{@encantador} (key, opts) {
							if(!(this instanceof #{@encantador})) return new #{@encantador}(key, opts);
							#{if @type is \Cardinal then 'ToolShed.extend(this, Tone);' else ''}
							#{if @type is \Mutable then 'ToolShed.extend(this, Timing);' else ''}
							#{if @type is \Fixed then 'ToolShed.extend(this, Symbolic);' else ''}
							#{@encantador}.superclass.call(this, book, _bp, key, opts);
						}
						/*
						if(embodies) {
							for(var i in _deps.embodies) {
								ToolShed.extend(prototype, book.poetry['#{@encantador}'].prototype);
							}
						}
						*/
						ToolShed.extend(prototype, _blueprint.machina);
						return #{@encantador};
					}(book.poetry['#{@encantador}']));
					book.poetry['#{@encantador}']['#{@incantation}'] = #{@incantation};
					book.poetry['#{@encantador}']['#{@incantation}@#{@version}'] = #{@incantation};
				}())
				"""

			return blueprint_inst
		else
			@debug.error "you can't imbue a blueprint that's not yet ready!: #{@uri}"
			# throw new Error "you can't imbue a blueprint that's not yet ready!"
			# perrhaps in the future, we should use a yield and get rid of a bunch of these errors...
		# return @refs.library.blueprints[@encantador][@version][id] = lala
		# return UniVerse._[@encantador][version][id] = lala

	states:
		uninitialized:
			onenter: ->
				req = Http.get {
					path: "/db/_bp/#{@encantador}/#{@incantation}#{if @version and @version isnt \latest => '&version=' + @version else ''}"
				}, (res) !~>
					console.log "we are requesting...."
					data = ''
					res.on \error (err) ->
						console.error "we've got an error!!", err

					res.on \data (buf) ->
						# console.log "got data", data
						data += buf

					res.on \end ~>
						# console.log "done with the request:", res
						if res.statusCode is 200
							# console.log "gonna create a blueprint...", data
							@_blueprint = ToolShed.objectify data, {require: @refs.book.refs.require}, {name: @namespace}
							if @version is \latest
								@version = @_blueprint.version
								@uri = @encantador+':'+@incantation+'@'+@version
								@refs.library.blueprints[@uri] = @
							# debugger
							if typeof @refs.book._[@encantador] isnt \object
								@refs.book._[@encantador] = {}
							if typeof @refs.book._[@encantador][@version] isnt \object
								@refs.book._[@encantador][@version] = {}
							@exec \process @_blueprint
						else
							@transition \error

				# machina = @
				# get_bp encantador, incantation, version, (err, res) ->
					# if err
					# 	@emit \error, err
					# 	@transition \error
					# else
						# @_blueprint = _bp = {} <<< res
						# if bp._blueprint?machina?states?ready?['onenter.js']
						# 	debugger

		ready:
			onenter: ->
				console.log "blueprint ready", @incantation
				@emit \ready

			verify: (path, val) ->
				#TODO: add path splitting by '.'
				#unless s = blueprint[path]
		error:
			onenter: ->
				console.error "you have tried to load a blueprint which wasn't able to be fetched", @incantation
	cmds:
		fetch: (uri) ->
			Blueprint.uri.parse
		process: (res, bp) ->
			@type = if res.type then res.type else
				switch res.encantador
				| \Poem \Word => \Fixed
				| \Verse => \Mutable
				| \Voice => \Cardinal

			@layout = res.layout || {}
			@_deps = {}
			deps = ToolShed.embody {}, res.poetry
			long_incantation = @uri
			embodies = res.embodies
			if typeof embodies is \string
				embodies = [embodies]
			@_deps.embodies = embodies
			UniVerse = @refs.UniVerse
			unless book = @refs.book
				debugger
			task = @task "get deps for #{@uri}"

			# console.warn @uri, "DEPS: ", deps, @refs.library.blueprints
			if @encantador isnt @incantation
				task.push "getting encantador: #{@encantador}" (done) ->
					encantador = incantation = @encantador
					version = \latest
					if ~(idx = incantation.indexOf '@')
						version = incantation.substr idx+1
						encantador = incantation = incantation.substr 0, idx
					# debugger
					UniVerse.library.exec \fetch {encantador, incantation, version}, @refs.book, (err, res) ~>
						@debug "fetched... %s:%s", encantador, incantation
						# debugger
						@_deps.encantador = res
						res.once_initialized ~> done!

			# @debug.todo "add the ability for embodies to be abstract in some way"
			if embodies
				_.each embodies, (incantation, ii) ->
					console.log "embodies", embodies, incantation
					task.push "getting embodied: #{incantation}" (done) ->
						unless incantation
							debugger
						encantador = @encantador
						version = \latest
						# console.log "embodies", embodies, typeof embodies
						if ~(idx = incantation.indexOf '@')
							version = incantation.substr idx+1
							incantation := incantation.substr 0, idx
						UniVerse.library.exec \fetch {encantador, incantation, version}, @refs.book, (err, res) ~>
							@_deps.embodies[ii] = res
							res.once_initialized ~> done!

			_.each deps, (deps, encantador) ~>
				_.each deps, (version, incantation) ~>
					task.push "getting element: #{encantador}:#{incantation}@#{version}" (done) ->
						# if typeof book.poetry[encantador] is \undefined
						# 	book.poetry[encantador] = {}
						# debugger
						# if res = book.poetry[encantador][incantation]
						# 	done!
						# else
						UniVerse.library.exec \fetch {encantador, incantation, version}, @refs.book, (err, res) ~>
							@_deps[res.uri] = res
							# res.once_initialized ~> done!
							done!
						# remove me because it should just go into new res mode... (things should never fail)
						# @once_initialized done
				# 	task.push (done) ->
				# 		UniVerse.UniVerse.emit "dep:#type", name
				# 		UniVerse.UniVerse.once "dep:#type:#name:ready" ->
				# 			console.log "we got dep:#type:#name:ready"
				# 			done!
				# 		UniVerse.UniVerse.on "update:#type:#name" (bp) ->
				# 			console.log "we got an update on #type:#name", @version
				# 			#TODO: do the version as "latest" and make sure te updates are semver compliant
				# 			console.log "TODO: replace the current blueprint (done inside blueprint)"
				# 			console.log "TODO: blueprint has a node derivitave and a browser derivitave. one searches the localdb then does web updates, and the other gets from node"
				# 			console.log "TODO: add this functioality to blueprint"

			# console.log "task:", task.fns, task.done, task
			task.end (err, res) ->
				console.log "done: #long_incantation"
				console.info "initialized blueprint", @uri
				# debugger
				@transitionSoon \ready

class Uri
	(uri) ->
		if typeof uri is \string
			@ <<< _uri = Uri.parse uri
			console.log "uri:", uri, _uri
		unless @version
			@version = \latest

	stringify: ->
		"#{@proto}://#{@origin}/#{@path}"

Uri.parse = (uri) ->
	ref = proto: \blueprint, version: \latest

	if typeof uri is \string
		if ~(i = uri.indexOf '://')
			ref.proto = uri.substr 0, i
			uri = uri.substr i+3
		if ~(i = uri.indexOf ':')
			ref.origin = uri.substr 0, i
			ref.path = uri.substr i+1
			if ~(i = uri.indexOf '@')
				ref.version = uri.substr i+1
				ref.path = uri.substr 0, i
	else if typeof uri is \object
		ref = uri
		# @debug.warn "TODO: uri objects"
	return ref

# I really need to take some ideas from the old Verse implementation here.
# then, take the rest of the ideas for Machina/Process
class Blueprint extends Fsm
	encantador: \Blueprint
	incantation: \Idea
	version: \latest

	(uri) ->
		opts = {}
		if typeof uri is \string
			# url.parse "blueprint://Poem:NewFriends@0.1.0"
			# { protocol: 'blueprint:',
			#   slashes: true,
			#   auth: 'Poem:NewFriends',
			#   host: '0.1.0',
			#   port: null,
			#   hostname: '0.1.0',
			#   hash: null,
			#   search: null,
			#   query: null,
			#   pathname: null,
			#   path: null,
			#   href: 'blueprint://Poem:NewFriends@0.1.0' }
			if ~(i = uri.indexOf ':')
				@encantador = uri.substr 0, i
				@incantation = uri.substr i+1
				if ~(i = uri.indexOf '@')
					version = uri.substr i+1
					incantation = uri.substr 0, i
		else if typeof uri is \object
			data = uri
			if data.encantador
				@encantador = data.encantador
			if data.incantation
				@incantation = data.incantation
			if data.version
				@version = data.version
		else
			throw new Error "we don't know whot to do with your blueprint, sorry"


		unless @incantation
			console.error "you need a incantation for your blueprint!"
			throw new Error "you need a incantation for your blueprint!"

		unless @encantador
			console.error "you need a encantador for your blueprint!"
			throw new Error "you need a encantador for your blueprint!"

		if not @version or @version is \*
			@version = \latest

		DaFunk.extend this, Empathy
		# BasicFunk.formula this, \embodies, \Empathy

		super "Blueprint(#{@uri = @encantador+':'+@incantation+'@'+@version})"
		@_blueprint = DaFunk.objectify data, {require: require}, {name: @namespace}
		if @version is \latest
			@version = @_blueprint.version
			@uri = @encantador+':'+@incantation+'@'+@version
			@refs.library.blueprints[@uri] = @
		# debugger
		if typeof LocalLibrary._[@encantador] isnt \object
			LocalLibrary._[@encantador] = {}
		if typeof LocalLibrary._[@encantador][@version] isnt \object
			LocalLibrary._[@encantador][@version] = {}
		@exec \process @_blueprint


	eventListeners:
		update: (data) ->
		ready: ->
			@debug.info "ready!"

	states:
		uninitialized:
			onenter: ->
				if @_blueprint
					@exec \process @_blueprint, @

				@bikeshed {
					verb: \rename
					uri: 'npm://MachineShop.Fsm'
					txt: "rename 'exec' to 'task' -- but leave 'exec' for backward compatibility."
				}

			start: ->
				task = @process \fetch {@encantador, @incantation, @version}
				task.on \failure (err) !~>
					@debug err
					@transition \error
				task.on \success (data) !~>
					console.log "success", data
					@emit \update bp

		custom:
			onenter: ->
				console.log "a customized bp"

	processes:
		fetch: (task) ->
			console.log "fetch task !!!!!!!!!!!!!!!!!!"
			# TODO: LocalDB here
			task.success "yay, all fetched"

	bikeshed: (uri, verb, explanation) ->
		# something seems wrong here. I'm sure there's something bad.
		# the irony is, the Blueprint has now been bikeshedded with this function... LOLz
		# throw new Error "if you're gonna bikeshed something, at least do it right, dude"
		if typeof uri is \object
			explanation = uri
		else if typeof explanation is \undefined
			explanation = {uri: @uri, verb: verb || \maybe, txt: uri, priority: 0}
		else if typeof explanation is \string
			explanation = {uri: @uri, verb: verb || \maybe, txt: uri, priority: 0}
		else if typeof verb is \object
			explanation = verb

		unless explanation.uri
			explanation.uri = @uri
		unless explanation.verb
			explanation.verb = \maybe
		if typeof @_bikeshed is \undefined
			@_bikeshed = [explanation]
		else
			@_bikeshed.push explanation

# converts uri to a proper object

# class Uri
# 	(uri) ->
# 		if typeof uri is \string
# 			@ <<< Uri.parse uri


# Uri.parse = (uri) ->
# 	if ~(i = uri.indexOf ':')
# 		encantador = uri.substr 0, i
# 		incantation = uri.substr i+1
# 		if ~(i = uri.indexOf '@')
# 			version = uri.substr i+1
# 			incantation = uri.substr 0, i

# 	return {encantador, incantation, version: if version => version else \latest}

# Blueprint.Uri = Uri

export Blueprint
export Uri
# export NodeJSBlueprint