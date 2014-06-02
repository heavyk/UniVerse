inception: \UniVerse
motivation: \Implementation
incantation: \Sencillo
type: \Fixed
version: \0.1.0
description: "fácilmente chaval!!"
motd:
	* "This poem was the last piece of service I did for my master, King Charles. --Dryden."
embodies:
	* \Empathy # Fabuloso (on by default)
	* \Creativity # this will be the owner and stuff
possesses:
	* \Origin # where to find this and the original author of the code
	* \Agreement # how this can be interacted with, registers the service, etc.
poetry:
	Path:					\node://path
	Fs:						\node://fs
	Http:					\node://http
	Crypto: 			\node://crypto
	Browserify:		\npm://browserify
	Express:			\npm://express
	GridFS:				\npm://GridFS.GridFS
	# GridStream:		\npm://GridFS.GridStream
	ImageMagick:	\npm://imagemagick-native
	Backoff:			\npm://backoff
	Dnode:				\npm://dnode
	Shoe:					\npm://shoe
	Base58:				\npm://base58-native
	HttpProxy:		\npm://http-proxy
	Thunkify:			\npm://thunkify
	Mime:					\npm://mime
	Multipart:		\npm://co-multipart
	Co:						\npm://co

	Http:					\Service://Http@latest
	ArangoDB:			\Service://ArangoDB@latest
	MongoDB:			\Service://MongoDB@latest
	Laboratory:		\Service://Laboratory@latest
machina:
	initialize: (refs, opts) ->
		@_gridfs = {}
		@_proxies = {}
		@_app = {}

		@port = opts.port || 1155
		@apps =
		if typeof (app = opts.app) is \undefined
			app =
				'80':
					'dev.affinaty.es':
						poem: \Affinaty@latest
						title: "Affinaty@latest"
					'affinaty.es':
						poem: \Affinaty@0.1.0
						title: "affinaty"
				'1155':
					'laboratory.poem':
					# '.poem':
			@


		_.each @apps, (app, name) ~>
			switch typeof title = app.title
			| \undefined =>
				app.title = (txt, opts) ->
					if typeof txt is \string
						"#{name} - #{txt}"
					else
						name
			| \string =>
				app.title = (txt, opts) ->
					if typeof txt is \string
						"#{title} - #{txt}"
					else
						title
			| \function => fallthrough

			@_apps[name] = app
			if Array.isArray also = app.also
				for d in also
					@_apps[d] = app
			else if typeof also is \object
				_.each also, (o, d) ->
					@_apps[d] = ToolShed.extend app, o


		if Array.isArray gfs = opts.gridfs || <[fs img]>
			_.each gfs, (o, g) ~>
				@_gridfs[g] = {}
		else if typeof gfs is \object
			_.each gfs, (o, g) ~>
				@_gridfs[g] = o
		else
			@emit \warning, "unknown type for 'gridfs' (should be an object with options for GridFS"

		# this is temporary. look into the way other high power node proxy modules have their configurations
		proxies = opts.proxies || {
			'http':
				target: 'http://127.0.0.1:1111'
			'ws':
				target: 'ws://127.0.0.1:1133'
				ws: true
		}
		_.each proxies, (o, p) ->
			opts = {}
			if target = o.target
				url = Url.parse target
				if url.protocol is \ws:
					opts.ws = true
				opts.target = url.href
			@_proxies[p] = HttpProxy.createProxyServer opts
			if opts.ws


		super "Http(#{@port})", opts

	gridfs: (namespace) ->
		for g in @gridfs
			unless @_gridfs[g]
				@_gridfs[g] = new GridFS g
		if not (db = @_gridfs[namespace]) instanceof GridFS
			db = @_gridfs[namespace] = GridFS namespace, @_gridfs[namespace] || null
		@emit 'GridFS:new' namespace
		db

	states:
		uninitialized:
			onenter: ->
				@http_proxy = HttpProxy.createProxyServer target: 'http://127.0.0.1:1111'
				@ws_proxy = HttpProxy.createProxyServer target: 'ws://127.0.0.1:1133' ws: true

		starting:
			onenter: ->
				for g in @gridfs
					if not (db = @_gridfs[namespace]) instanceof GridFS
						@_gridfs[g] = new GridFS g

		stopped:
			onenter: ->
				console.log "stopped!!"
				# stop listening

		started:
			onenter: ->
				console.log "ready!!"

	cmds:
		'proxy.add': (opts, task, cmd_done) ->
		'proxy.remove': (opts, task, cmd_done) ->
		start: (opts, task, cmd_done) ->
			console.log ""