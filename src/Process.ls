
{ ToolShed, Fsm } = require \MachineShop


class Process extends Fsm
	(@refs, opts) ->
		# unless refs.window
		# debugger
		# @processes[long_inception] = bp = new Process {inception, implementation, version}
					# get the process from the LocalDB / PublicDB / EtherDB
					# TODO: first get from localstorage, then from the DB...
					# TODO: if its version is latest then watch it for updates

					#first check local storage, then check disk (if latest)
					# then, check the db for an update (if it's a semver that's not definative)

			# inception = opts
			# if ~(i = inception.indexOf ':')
			# 	implementation = inception.substr 0, i
			# 	inception = inception.substr i+1
			# 	if ~(i = inception.indexOf '@')
			# 		version = inception.substr i+1
			# 		inception = inception.substr 0, i
			# opts = {implementation, inception, version}

		if typeof opts is \object
			if opts.implementation
				@implementation = opts.implementation
			if opts.inception
				@inception = opts.inception
			if opts.version
				@version = opts.version
		else if typeof opts is \string
			throw new Error "TODO: fqvn parsing"
		else
			throw new Error "we don't know whot to do with your process, sorry"

		if typeof refs isnt \object
			@debug.error "you need to pass a 'refs' object to the Narrator"
		else if not refs.process
			throw new Error "you have to reference a Narrator for a ether because we save the imbuement into his memory, obviously"

		@_process = opts

		unless @inception
			console.error "you need a inception for your process!"
			throw new Error "you need a inception for your process!"

		unless @implementation
			console.error "you need a implementation for your process!"
			throw new Error "you need a implementation for your process!"

		if not @version or @version is \*
			@version = \latest

		super "Process(#{@fqvn = @implementation+':'+@inception+'@'+@version})"

	imbue: (process) ->
		assert process instanceof Narrator
		# debugger
		if @state is \ready
			console.log "we're gonna make a new imbuement here..."
			var process_inst
			_deps = @_deps
			_process = @_process
			if typeof process.memory[@inception] is \undefined
				process.memory[@inception] = new ExperienceDB @inception
			#OPTIMIZE: this could be potentially costly to call ToolShed.extend ... I dunno...
			#OPTIMIZE: perhaps instead of eval, we should use new Function
			if typeof process.poetry[@implementation] is \undefined
				eval """
				(function(){
					var #{@implementation} = process_inst = (function(superclass){
						var prototype = extend$((import$(#{@implementation}, superclass).displayName = '#{@implementation}', #{@implementation}), superclass).prototype, constructor = #{@implementation};
						function #{@implementation} (process, _eth, key, opts) {
							if(!(this instanceof #{@implementation})) return new #{@implementation}(key, opts);
							//#{if @type is \Cardinal then 'ToolShed.extend(this, DefineTone);' else ''}
							//#{if @type is \Mutable then 'ToolShed.extend(this, DefineTiming);' else ''}
							//#{if @type is \Fixed then 'ToolShed.extend(this, DefineSymbolic);' else ''}
							#{@implementation}.superclass.call(this, process, _eth, key, opts);
						}
						ToolShed.extend(prototype, _process.machina);
						return #{@implementation};
					}(Motivator));
					ToolShed.extend(#{@implementation}, Magnetism);
					process.poetry['#{@implementation}'] = #{@implementation};
				}())
				"""

			if @implementation isnt @inception
				eval """
				(function(){
					var #{@inception} = process_inst = (function(superclass){
						var embodies = _deps.embodies, prototype = extend$((import$(#{@implementation}, superclass).displayName = '#{@implementation}', #{@implementation}), superclass).prototype, constructor = #{@implementation};
						function #{@implementation} (key, opts) {
							if(!(this instanceof #{@implementation})) return new #{@implementation}(key, opts);
							#{if @type is \Cardinal then 'ToolShed.extend(this, Tone);' else ''}
							#{if @type is \Mutable then 'ToolShed.extend(this, Timing);' else ''}
							#{if @type is \Fixed then 'ToolShed.extend(this, Symbolic);' else ''}
							#{@implementation}.superclass.call(this, process, _eth, key, opts);
						}
						/*
						if(embodies) {
							for(var i in _deps.embodies) {
								ToolShed.extend(prototype, process.poetry['#{@implementation}'].prototype);
							}
						}
						*/
						ToolShed.extend(prototype, _process.machina);
						return #{@implementation};
					}(process.poetry['#{@implementation}']));
					process.poetry['#{@implementation}']['#{@inception}'] = #{@inception};
					process.poetry['#{@implementation}']['#{@inception}@#{@version}'] = #{@inception};
				}())
				"""
			# else
				# debugger

			return process_inst
		else
			@debug.error "you can't imbue a process that's not yet ready!: #{@fqvn}"
			# throw new Error "you can't imbue a process that's not yet ready!"
			# perrhaps in the future, we should use a yield and get rid of a bunch of these errors...

	states:
		uninitialized:
			onenter: ->
				process_eth = ~>
					if not bp = @_process
						debugger
						console.log "wtf mate? the process doesnt exist"
						return
					@type = if bp.type then bp.type else
						switch bp.implementation
						| \Poem \Word => \Fixed
						| \Verse => \Mutable
						| \Voice => \Cardinal

					@layout = bp.layout || {}
					@_deps = {}
					deps = ToolShed.embody {}, bp.poetry
					long_inception = @fqvn
					embodies = bp.embodies
					if typeof embodies is \string
						embodies = [embodies]
					@_deps.embodies = embodies
					UniVerse = @refs.UniVerse
					unless process = @refs.process
						debugger
					task = @task "get deps for #{@fqvn}"
					if @inception isnt @implementation
						task.push "getting implementation: #{@implementation}" (done) ->
							implementation = inception = @implementation
							version = \latest
							if ~(idx = inception.indexOf '@')
								version = inception.substr idx+1
								implementation = inception = inception.substr 0, idx
							# debugger
								# debugger
								@_deps.implementation = bp
								bp.once_initialized ~> done!

					# @debug.todo "add the ability for embodies to be abstract in some way"
					if embodies
						_.each embodies, (inception, ii) ->
							console.log "embodies", embodies, inception
							task.push "getting embodied: #{inception}" (done) ->
								unless inception
									debugger
								implementation = @implementation
								version = \latest
								# console.log "embodies", embodies, typeof embodies
								if ~(idx = inception.indexOf '@')
									version = inception.substr idx+1
									inception := inception.substr 0, idx
									bp.once_initialized ~> done!

					_.each deps, (deps, implementation) ~>
						_.each deps, (version, inception) ~>
							task.push "getting element: #{implementation}:#{inception}@#{version}" (done) ->
								# if typeof process.poetry[implementation] is \undefined
								# 	process.poetry[implementation] = {}
								# debugger
								# if bp = process.poetry[implementation][inception]
								# 	done!
								# else
									# bp.once_initialized ~> done!
									done!
								# remove me because it should just go into new bp mode... (things should never fail)
								# @once_initialized done
						# 	task.push (done) ->
						# 		UniVerse.UniVerse.emit "dep:#type", name
						# 		UniVerse.UniVerse.once "dep:#type:#name:ready" ->
						# 			console.log "we got dep:#type:#name:ready"
						# 			done!
						# 		UniVerse.UniVerse.on "update:#type:#name" (bp) ->
						# 			console.log "we got an update on #type:#name", @version
						# 			#TODO: do the version as "latest" and make sure te updates are semver compliant
						# 			console.log "TODO: replace the current process (done inside process)"
						# 			console.log "TODO: process has a node derivitave and a browser derivitave. one searches the localdb then does web updates, and the other gets from node"
						# 			console.log "TODO: add this functioality to process"

					# console.log "task:", task.fns, task.done, task
					task.end (err, res) ->
						console.log "done: #long_inception"
						console.info "initialized process", @fqvn
						# debugger
						@transitionSoon \ready
				req = Http.get {
					path: "/db/_eth/#{@implementation}/#{@inception}#{if @version and @version isnt \latest => '&version=' + @version else ''}"
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
							# console.log "gonna create a process...", data
							@_process = ToolShed.objectify data, {require: @refs.process.refs.require}, {name: @namespace}
							if @version is \latest
								@version = @_process.version
								@fqvn = @implementation+':'+@inception+'@'+@version
								@refs.process._[@implementation] = {}
							if typeof @refs.process._[@implementation][@version] isnt \object
								@refs.process._[@implementation][@version] = {}
							process_eth!
						else
							@transition \error

				# machina = @
				# get_eth implementation, inception, version, (err, res) ->
					# if err
					# 	@emit \error, err
					# 	@transition \error
					# else
						# @_process = _eth = {} <<< res
						# if bp._process?machina?states?ready?['onenter.js']
						# 	debugger



		ready:
			onenter: ->
				console.log "process ready", @inception
				@emit \ready

			verify: (path, val) ->
				#TODO: add path splitting by '.'
				#unless s = process[path]
		error:
			onenter: ->
				console.error "you have tried to load a process which wasn't able to be fetched", @inception

# implementation: \Service
# inception: \Http
# possesses:
# 	* \Desire
# 	* \Origin
# 	* \Agreement
# Creativity -> Origin
# Inception
# Motivator
# Timing -> Progress
# export Desire
# Tone -> Agreement
# export Agreement
export Motivator
export Process