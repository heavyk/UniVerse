{ ToolShed, Fsm, Machina, DaFunk, Empathy } = require \MachineShop

Path = require \path
Walk = require \walkdir

{ Implementation } = require './Implementation'
{ Reality } = require './Reality'

default_protos = {
	node: (module, cb) ->
		try
			cb null, require module
		catch e
			cb e
	npm: (module, cb) ->
		try
			# TODO: new Module ...
			# this will allow for the module to be downloaded if it doesn't already exist
			# TODO: each proto has its own path parser... add version support
			# TODO: this will break for './Reality'
			if module.substr(0, 2) isnt './' and ~(i = module.indexOf '.')
				path = module.substr i+1
				mod = module.substr 0, i
				mod = require mod
				mod = ToolShed.get_obj_path path, mod
			else
				mod = require module
			cb null, mod
		catch e
			cb e
}


class LocalLibrary extends Fsm
	(@origin, opts) ->
		console.log "origin", origin
		if typeof opts isnt \object
			throw new Error "you need to define an options object"

		unless path = opts.path
			throw new Error "you need to define 'path' for it to work"

		@index = {}
		cwd = process.cwd!
		@path = Path.relative(cwd, @abs_path = Path.resolve path)
		if opts.protos
			@protos = {}
			@rel_protos = Path.relative(cwd, @abs_protos = Path.resolve opts.protos)


		super "LocalLibrary(#{@path})"

	states:
		uninitialized:
			onenter: ->
				library = this
				proto_list = []
				walker = Walk @abs_protos, depth: 1
				walker.on \file (path) ~>
					parts = Path.basename path .split '.'
					if parts.length is 3
						proto = parts.0
						proto_list.push proto
						# console.log "shiiit", @origin
						impl = new Implementation @origin.0, path
						impl.on \ready ~>
							Proto = impl.imbue Reality
							@protos[proto] = p = new Proto { library }
							p.once \state:ready ~>
								@debug "proto '#proto' ready..."
							proto_list.splice proto_list.indexOf(proto), 1
							if proto_list.length is 0
								@transition \ready

				walker.on \end ~>
					@debug "found #{proto_list.length} protos"

		ready:
			onenter: ->
				@debug "LocalLibrary ready with #{Object.keys(@protos).length} protos"

			get: (uri, cb) ->
				if ~(i = uri.indexOf '://')
					proto = uri.substr 0, i
					path = uri.substr i+3
				# if proto is \concept
				# 	console.log "concept", @protos[proto].state, default_protos[proto]
				if typeof (handler = @protos[proto]) is \object and (handler.state or not default_protos[proto])
					unless handler.state
						@debug "FIXME"
					# console.log "get:proto #proto", handler.state
					@debug "resolve:#proto -> %s (%s)", path, handler.namespace
					handler.exec.call handler, \resolve, path, cb
				else if handler = default_protos[proto]
					handler path, cb
				else
					err = new Error "cound not find '#uri'"
					err.code = \ENOTFOUND
					throw err
					cb err

	cmds:
		'update': ->
			console.log "walk src:", @path
			walker = Walk @abs_path, depth: 1
			# walker.on \directory (dir) ~>
			# 	console.log "dir", dir
			# 	if ~available_protos.indexOf dir
			# 		path = Path.join(@path, dir)
			# 		unless p = @protos[dir]
			# 			@protos[dir] = new Proto dir, path: path
			# 		unless @_protos[dir]
			# 			@_protos[dir] = path
			# 		unless p.path
			# 			p.exec \path path
			walker.on \file (path) ->
				file = Path.basename path
				#OPTIMIZE: this is horribly inefficient. we should use a do-while loop
				parts = file.split '.'
				if parts.length > 2
					compiler = parts.pop!
					proto = parts.pop!

				if parts.length is 3
					implementation = parts.pop!
					if proto is \proto
						throw new Error "totally wrong "
						# impl = new Implementation path: "#{@src}/Laboratory.concept.ls" outfile: "library/Laboratory.concept.js"
						# impl.on \ready ->
						# 	Proto = impl.imbue Reality
						# 	@protos[proto] = new Proto { library }

		'lib:update': ->
			walker = Walk @lib, depth: 1
			walker.on \directory (dir) ~>
				id = Path.basename dir
				if ~available_protos.indexOf id
					unless p = @protos[id]
						@protos[dir] = new Proto id, path: dir
					unless @_protos[id]
						@_protos[dir] = dir
					unless p.path
						p.exec \path path
			walker.on \file (file) ->
				console.log "we have a file!", file

		add: (uri, data) ->
			unless uri = Uri.parse uri
				if protos = @index[uri.proto]
					console.log 'PROTO found:', uri.proto
				else
					console.log "proto not found", uri.proto


	processes:
		fetch: (task, uri) ->
			ref = Proto.parse uri

			# path =
			# Fs.readFile


export LocalLibrary
