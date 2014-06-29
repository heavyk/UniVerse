
{ Debug, EventEmitter, _, ToolShed, Fsm, DaFunk } = require \MachineShop

LiveScript = require \LiveScript

Fs = require \fs
Path = require \path
DeepDiff = require \deep-diff


# when Implementation detects a change, it tells Process

# Verse becomes manager of these processes
class Process extends Fsm # Reality
	# (origin, opts) ->
	(@ambiente, @implementation, @ether) ->
		unless ambiente or implementation or ether
			throw new Error "needs: params: (Ambiente, Implementation, Manifest)"
		@cluster = require \cluster


		# TODO: call Reality (to get any necessary things)
		super "Process(@implementation.idea)"

	states:
		uninitialized:
			onenter: ->
				console.log "so, I'm uninitialized now.. we've got to wait for the instance to become ready"

				if @cluster.isMaster
					@role = \master
					console.log "TODO: launch the verse"
					# 1. the verse receives the commands and executes them off to the children
					# 2.

					@verse = new Verse @ether
					@verse.once \ready ~>
						@transition \ready
				else
					@role = \aprentice
					console.log "this is a child. start the implementation up here"
					src = @implementation.src
					#

				# @ambiente.exec \motivator, @ether.motivation, (motivator) ->
				# 	@ambiente.exec \verse, @ether.implementation, (verse) ->

				@once \add:instance ~>
					@transition \ready

		ready:
			onenter: ->
				console.log "yay, we're ready to function now..."

	cmds:
		spawn: ->
			console.log "spawning..."
			ambiente = @origin.0
			ambiente




class Implementation extends Fsm # Reality
	# idea: \Implementation
	# embodies:
	# 	\Growler
	(ambiente, path, out_path) ->
		if typeof ambiente is \string
			path = ambiente

		impl = {}
		if typeof path is \object
			impl = path
			path = \inline
		else if typeof path is \string
			opts = {path}
		else
			throw new Error "you must define a path for your Implementation"

		@origin = [ambiente]
		@_impl = impl
		@_instances = []
		@src = ''

		super "Implementation(#{path})", opts
		if typeof out_path is \string
			opath = Path.resolve out_path
			@on \compile:success ->
				@debug "saving into: #{opath}"
				@exec \save opath


	stringify: ->
		if lang = Implementation.langs[@lang]
			lang.stringify ...
		else
			throw new Error "not yet possible. TODO: add more langs"

	# TODO: this needs to be specific to Ether / Blueprint
	imbue: (essence) ->
		idea = (impl = @_impl).idea
		@debug.todo "save the imbued"
		self = this
		new_inst = (inst) ->
			self._instances.push inst
			inst.once \state:destroyed ->
				(ii = self._instances).splice (ii.indexOf inst), 1

		machina = @_impl.machina
		if ambiente = @origin.0
			console.log "TODO: spawn this in the ambiente"
			# ambiente.exec \connect self
			# ambiente.exec \create self

		unless idea_constructor = @_constructor
			eval """
			(function(){
				var #{idea} = idea_constructor = (function(superclass){
					var prototype = extend$((DaFunk.extend(#{idea}, superclass).displayName = '#{idea}', #{idea}), superclass).prototype, constructor = #{idea};
					function #{idea} (opts) {
						if(!(this instanceof #{idea})) return new #{idea}(refs, opts);
						this.origin = self.origin.concat(this);
						#{idea}.superclass.call(this, impl, opts);
						new_inst(this);
					}
					DaFunk.extend(prototype, machina);
					return #{idea};
				}(essence));
			}())
			"""
		return @_constructor = idea_constructor

	eventListeners:
		"set:src": -> @exec \compile
		"compile:success": (src) ->
			#TODO: update reality
			if @outfile and @src isnt src
				@exec \save outfile
			if src isnt @src
				# _.each @_instances, (impl) ->
				# for k in Object.keys @_instances
				for inst in @_instances
					lhs = impl._impl
					rhs = res.output
					d = DeepDiff.observableDiff lhs, rhs, (d) ~>
						switch d.kind
						| \E =>
							if typeof d.lhs is \function and typeof d.rhs is \function
								if d.lhs.toString! is d.rhs.toString!
									return
						console.log "change d:", d
						DeepDiff.applyChange lhs, rhs, d
						switch d.path.0
						| \local =>
							console.log "TODO: update any locals. changed:", d
						| \machina =>
							d.path.shift!
							# console.log "applying:", d
							DeepDiff.applyChange impl, rhs.machina, d
							@emit \diff d
				# _.each @_instances
				# 	DeepDiff.applyChange impl, rhs.machina, d
				if ambiente = @origin.0
					console.log "exec save", (Path.join ambiente.library.path, @name)
					@exec \save (Path.join ambiente.library.path, @name), src

	states:
		uninitialized:
			onenter: ->
				@once \executed:compile ->
					console.log "executed compile!!!!!!"
					@transition \ready
				@exec \read @path

		ready:
			onenter: ->
				@emit \ready @_impl, @src

			save: (path) ->
				if typeof opts isnt \object
					opts = {}
				unless path
					return
				console.log "saving: '#path' in #{process.cwd!}"
				obj = @_impl
				# this is wrong. it should probably stat the file and make the dir if ENOENT
				# also return new if it's first save
				Fs.writeFile path, @src, (err) ~>
					if err
						if err.code is \ENOENT
							dirname = Path.dirname path
							ToolShed.mkdir dirname, (err) ~>
								if err
									@transition \error, err
								else @transition \retry
						else
							@transition \error, err
					else
						@emit \saved obj, path, @src

			retry:
				onenter: ->
					# TODO: add backoff support
					setTimeout ~>
						@transition @previousState
					, 500

			error:
				onenter: (err) ->
					console.log "OH NO AN ERROR", err

			watch: (ms = 100) ->
				@debug "watch: #ms"
				console.log "watcher", &
				# throw new Error "watcher"
				# this really should be a cmd
				# start the watcher
				@_watch = ms
				@exec \read

	cmds:
		read: (path) ->
			@debug "read:", path
			if typeof path is \undefined
				path = @path
			if typeof path isnt \string
				return

			if path isnt @path
				@path = path
				@file = Path.basename path
				@watcher = null if @watcher
			if ms = @_watch and not @watcher
				@watcher = Fs.watchFile path, {interval: ms} (st1, st2) ~>
					@debug "disturbance @ '#path'"
					@exec \read path

			Fs.readFile path, 'utf-8', (err, data) ~>
				_new = false
				if err
					if err.code is \ENOENT
						@emit \new
						_new = true
					else
						@transition \error e
				else
					if @src isnt data
						@src = data
						@emit \set:src, data
				@_new = _new

			file = Path.basename path
			@parts = file.split '.'
			if @parts.length > 1
				@lang = @parts[*-1]
			if @parts.length > 2
				@proto = @parts[*-2]
			@name = @parts.slice 0, -1 .reverse!join '.'

		compile: ->
			if lang = Implementation.langs[@lang]
				lang.compile ...
			else throw new Error "I don't know how to compile this"

Implementation.langs =\
	ls:
		compile: (lang) ->
			console.log "compile!!", lang
			try
				@debug "gonna compile with lang: '#{@lang}'"
				@debug "gonna compile with proto: '#{@proto}'"
				if @lang isnt \ls
					return

				patch_ast = LiveScript.ast LiveScript.tokens "Mongoose = require 'Mongoose'"
				patch = patch_ast.toJSON!

				search_ast = LiveScript.ast LiveScript.tokens "Mongoose = require 'Mongooses'"
				search = search_ast.toJSON!
				j1 = JSON.stringify search.lines .replace /[,]*\"line\":[0-9]+/g, ''
				searchlen = search.lines.length

				options = {bare: true}
				res = {}
				res.tokens = LiveScript.tokens @src
				res.ast = LiveScript.ast res.tokens

				if @outfile is 'model.js'
					#console.log "ast", res.ast
					ast = JSON.parse JSON.stringify res.ast.toJSON!

					for i til width = ast.lines.length - searchlen
						# OPTIMIZE: this probably has to be the SLOWEST way to do do patching
						# IMPROVEMENT: I also want to improve patching, by maintaining variable names and the like
						# IMPROVEMENT: I want to search based on a certain pattern and replace based on that pattern
						l1 = ast.lines.slice i, i+searchlen
						j2 = JSON.stringify l1 .replace /[,]*\"line\":[0-9]+/g, ''
						if j1 is j2
							console.log "found target at line #", i
							ast.lines.splice.apply this, [i, searchlen] ++ patch.lines
							res.ast = LSAst.fromJSON ast
					#livescript.ast(livescript.tokens("\t\tif true then"))

				if res.result or true
					res.ast.makeReturn!

				res.output = res.ast.compileRoot options
				if res.result or true
					# TODO: putting lodash in the globals just to compile is super duper ugly... make sure to use vm.createContext
					global._ = require \lodash
					CWD = process.cwd!
					process.chdir Path.dirname res.path
					res.output = LiveScript.run res.output, options, true
					process.chdir CWD
			catch e
				@emit \compile:failure, e
				msg = e.message+''
				if ~msg.indexOf 'Parse error'
					@debug "parse Error in '%s' :: %s", @path, msg
					console.log "parse Error in '#{@path}' :: #msg"
				else
					@debug "parse Error in '%s' :: %s", @path, e.stack
					console.log @path, ':', e.stack
				return null

			# @_impl = res.output
			# @_impl = @stringify res.output

			try
				output = DaFunk.stringify res.output, @order || <[name description encantador incantation version embodies concepts machina states eventListeners layout]>
				@emit @lang, @outfile, output
				if output isnt @src
					@src = output

				@_impl = DaFunk.freedom JSON.parse output
				@emit \compile:success, @_impl
				return output
			catch e
				@emit \compile:failure, e
				return null


		stringify: (order) ->
			try
				output = DaFunk.stringify @_impl, order || <[name description encantador incantation version embodies concepts machina states eventListeners layout]>
			catch e
				if ~e.message.indexOf 'Parse error'
					console.log @path, ':', e.message
				else
					console.log @path, ':', e.stack
				@emit \stringify:failure, e

			return output

		wtf: ->
					Fs.writeFile @outfile, output, (err) ~>
						if err
							@emit \error, new Error "unable to write output to #{@outfile}"
							@transition \error
						else
							@debug "wrote %s", @outfile
							@emit \success message: "compiled: '#{@outfile}' successfully"
							@transition \ready


export Implementation