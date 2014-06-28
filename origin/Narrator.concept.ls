# rename this to Narrator (and its implementation is Service-Http)
# then, make a service called Http, and register this service there
# lastly, merge this with the browserify source and only output the base + specific versions
motivation: \node@0.11.13
implementation: \Http # this needs to be a Process
inception: \Narrator # this is the Verse
type: \Cardinal
version: \0.1.0
description: "una red social basada en nuestra afinidad"
idea: \Http #until I fix the code, this is necessary
motd:
	* "omg! we're so much alike!"
embodies:
	* \Empathy # Fabuloso (on by default)
	* \Creativity # this will be the owner and stuff
possesses:
	* \Origin # where to find this and the original author of the code
	* \Agreement # how this can be interacted with, registers the service, etc.
local:
	Path:					\node://path
	Fs:						\node://fs
	Url:					\node://url
	Http:					\node://http
	Crypto: 			\node://crypto
	Browserify:		\npm://browserify
	Express:			\npm://express
	'{GridFS}':		\npm://GridFS@latest
	# GridStream:		\npm://GridFS.GridStream
	ImageMagick:	\npm://imagemagick-native
	Backoff:			\npm://backoff@2.3.0
	Dnode:				\npm://dnode@1.2.0
	Shoe:					\npm://shoe@0.0.15
	HttpProxy:		\npm://http-proxy
	Base58:				\npm://base58-native
	Thunkify:			\npm://thunkify
	Mime:					\npm://mime
	Multipart:		\npm://co-multipart
	Co:						\npm://co
	'{Implementation}':
		\src://Implementation
	# PublicDB:			\foxx://PublicDB

	# ArangoDB:			\concept://ArangoDB@latest
	# MongoDB:			\process://MongoDB@latest
	# Laboratory:		\process://Laboratory@latest
machina:
	initialize: (opts) ->
		# @db = new @ArangoDB \affinaty
		@port = port = opts.port || 80
		@pubdb_proxy = @HttpProxy.createProxyServer target: 'http://127.0.0.1:1111'
		@pubdb_proxy = @HttpProxy.createProxyServer target: 'http://127.0.0.1:1111'
		@static_dirs = <[theme node_modules build doc lib mode less third_party]>
		@_gridfs = {}
		@_proxies = {}
		@_blueprints = {}
		app = @Express!
		sock = @Shoe (stream) ~>
			d = @Dnode {
				require: (v, cb) ~>
					cb v.toUpperCase!
			}
			d.pipe stream .pipe d
		sock.install app, '/dnode'
		for i in @static_dirs
			dir = @Path.resolve @Path.join __dirname, i
			app.use '/'+i, @Express.static dir
		# main callback
		app.use (req, res, next) ~>
			url = req.url
			console.log "Http.req:", req.host, url
			@debug "req.url %s", url

			is_static = 0
			for i in @static_dirs
				# console.log "Http: ", i, (url.indexOf i)
				if (url.indexOf i) is 1
					is_static++
					break
			if url.substr(0, 7) is '/build/'
				# what time is it? k-breezy. k-breezy? kay-breeezy!
				suburl = url.substr 7
				# just doo'n what I do
				if suburl is 'blueshift.js'
					console.log "bundling..."
					b = @Browserify {
						require:
							http: \http-browserify
					}
					b.on \error (err) ->
						console.log "browserify error", err
					b.add './blueshift.js'
					bundle = b.bundle!
					bundle.on \error (err) ->
						console.log "bundle error:", err
						# res.status 500
						# res.end JSON.stringify {err}
						next err
					# bundle.pipe process.stdout
					bundle.pipe res
				else next!
			else if is_static
				console.error "Http:static:404", url
				res.status 404
				res.end "404!"
			else if url is \/file-upload
				#parts = yield* Multipart req#, (err, parts) ->
				(Co ->*
					parts = yield from Multipart req #, concurrency: 1
					converted = {}
					for file in parts.files
						buf = yield readFile file.path
						console.log "read file #{file.path}", buf, buf.length
						sha1 = @Crypto.createHash \sha1
						sha1.update jpg_buf = ImageMagick.convert {
							srcData: buf
							width: 256
							height: 256
							quality: 80
							format: \JPEG
							resizeStyle: \aspectfit
							debug: 1
						}
						sha1_hex = sha1.digest \hex
						sha1_b58 = @Base58.encode new Buffer sha1_hex, \hex
						console.log "writing #{sha1_b58} to gridfs"
						#yield Thunkify(img_DB.put).call img_DB, jpg_buf, sha1_b58, \w, (err, res) -> console.log "put", &

						converted[sha1_b58] = jpg_buf
						#res.end sha1_b58
						#return sha1_b58
					parts.dispose!
					return converted
				) (err, converted) ->
					if err then console.log err.stack
					#res.end converted.0
					#sha1_b58 = converted
					_.each converted, (jpg_buf, sha1_b58) ->
						console.log "putting", sha1_b58, jpg_buf.length
						img_DB.put jpg_buf, sha1_b58, \w, {content_type: 'image/jpeg'}, (err, meta) ->
							console.log "put", err, meta
							res.end sha1_b58

			else if url.substr(0, '/bp/'.length) is '/bp/'
				# TODO: this should pass off to the correct service
				if ~(i = url.indexOf '?')
					qs = url.substr i+1
					url = url.substr 0, i
				path = url.substr '/bp/'.length
				if ~(i = path.indexOf '@')
					version = path.substr i+1
					path = path.substr 0, i
					throw new Error "versioning not yet supported"
				parts = path.split '/'
				if parts.length isnt 2
					throw new Error "some sort of error here"

				console.log "check implementation origin/#path.blueprint.ls", typeof @Implementation
				impl = new @Implementation @origin.0, "origin/#path.blueprint.ls"
				console.log "origin__ origin/#path.blueprint.ls"
				impl.once \new ->
					console.log "IS NEW!!", path
					res.set 'Content-Type', 'application/json'
					res.status 204
					res.end '{}'
				impl.once \compile:success ->
					# Narrator = impl.imbue Reality
					# res.end "got Implementation(origin/#path.blueprint.ls)"
					res.set 'Content-Type', 'application/json'
					res.end impl.stringify!
				# @_blueprints =
			else if url.substr(0, '/db/'.length) is '/db/'
				suburl = url.substr 4
				# this is for dev...
				# req.url = "/dev/PublicDB-0.0.1/" + suburl
				req.url = "/PublicDB/" + suburl
				req.headers.host = 'localhost:1111'
				console.log "suburl: '#suburl'"
				if suburl.substr(0, 4) is '_bp/'
					console.log "we are request a bp:", suburl.substr 4
				@pubdb_proxy.web req, res, (err) ->
					console.log "error", err.stack
			else if url.substr(0, '/i/'.length) is '/i/'
				#rs = GridStream.createGridReadStream \img,
				console.log "looking for:", url.substr(3)
				img_DB.get url.substr(3), (err, data) ->
					console.log "data:", err, data
					console.log "data:", &
					res.set 'Content-Type', 'image/jpeg'
					res.end data
			# else if url.substr(0, 7) is '/dnode/'
			# 	console.log "we have a dnode...."
			# 	suburl = url.substr 7
			# 	# req.url = "/dev/PublicDB-0.0.1/" + suburl
			# 	req.headers.host = 'localhost:9999'
			# 	dnode_proxy.web req, res, (err) ->
			# 		console.log "dnode error", err.stack
			# 	# next!
			# else if url.substr(0, 4) is '/db/'
			# 	suburl = url.substr 4
			# 	# this is for dev...
			# 	# req.url = "/dev/PublicDB-0.0.1/" + suburl
			# 	req.url = "/PublicDB/" + suburl
			# 	req.headers.host = 'localhost:1111'
			# 	console.log "suburl: '#suburl'"
			# 	if suburl.substr(0, 4) is '_bp/'
			# 		console.log "we are request a bp:", suburl.substr 4
			# 	pubdb_proxy.web req, res, (err) ->
			# 		console.log "error", err.stack
			# 	/*
			# 	rereq_options = {
			# 		host: 'localhost'
			# 		port: 1111
			# 		method: req.method
			# 		path: pubdb_url
			# 	}
			# 	rereq = Http.request rereq_options, (err, rereq_res) ->
			# 		console.log "response", rereq_res
			# 		if err
			# 			throw err
			# 		res.pipe rereq_res
			# 	rereq.pipe req
			# 	*/
			else if url is '/' or true
				console.log "TODO: get the title correctly - I think this is defined somewhere in the poem"
				console.log "TODO: don't expose dirs like node_modules etc. as static."
				res.end """
				<!DOCTYPE html>
				<html lang="en">
					<head>
						<meta charset="utf-8"/>
						<title>UniVerse</title>
						<!-- link rel="stylesheet" href="/lib/codemirror.css" -->
						<meta name="viewport" content="width=device-width, initial-scale=1.0">
						<script src="/lib/loader.js"></script>
						<!-- script src="/lib/codemirror.js"></script -->
						<!-- script src="/lib/blueshift.js"></script -->
						<script src="/node_modules/lodash/dist/lodash.js"></script>
						<script src="/build/holder/holder.js"></script>
						<!-- script src="/mode/livescript/livescript.js"></script -->
						<script src="/build/component.js"></script>
						<script src="/node_modules/jquery/dist/jquery.js"></script>
						<script src="/build/bootstrap/dist/js/bootstrap.js"></script>
						<!--script src="https://login.persona.org/include.js"></script-->
						<!--script src="/third_party/tty.js/static/term.js"></script -->
						<script src="/third_party/term.js/src/term.js"></script>
						<!--script src="/third_party/tty.js/static/tty.js"></script -->
						<style>
						</style>
						<!-- link rel="stylesheet" href="/doc/docs.css" -->
						<link rel="stylesheet" href="/theme/solarized.css">
						<link rel="stylesheet" href="/build/component.css">
						<!-- link rel="stylesheet" type="text/css" href="/build/bootstrap/dist/css/bootstrap.css" -->
						<!-- link rel="stylesheet/less" type="text/css" href="/build/bootstrap/less/bootstrap.less"-->
						<!-- link rel="stylesheet/less" type="text/css" href="/less/screen.less" -->
						<script type="text/javascript">
						less = {
								env: "development", // or "production"
								async: false,       // load imports async
								fileAsync: false,   // load imports async when in a page under
																		// a file protocol
								poll: 1000,         // when in watch mode, time in ms between polls
								functions: {},      // user functions, keyed by name
								dumpLineNumbers: "all", // or "mediaQuery" or "all"
								relativeUrls: true,// whether to adjust url's to be relative
																		// if false, url's are already relative to the
																		// entry less file
								rootpath: "http://#{req.host}:1155/"// a path to add on to the start of every url
																		//resource
						};
						</script>
						<script src="/node_modules/less/dist/less-1.4.2.js"></script>
					</head>
					<body>
						<script src="/third_party/mousetrap/mousetrap.js"></script>
						<script src="/build/blueshift.js"></script>
						<script>
						</script>
					</body>
				</html>
				"""
		@debug "saving APP"
		@_app = app
		# console.log "initialize.opts", opts
		# _.each @apps, (app, name) ~>
		# 	switch typeof title = app.title
		# 	| \undefined =>
		# 		app.title = (txt, opts) ->
		# 			if typeof txt is \string
		# 				"#{name} - #{txt}"
		# 			else
		# 				name
		# 	| \string =>
		# 		app.title = (txt, opts) ->
		# 			if typeof txt is \string
		# 				"#{title} - #{txt}"
		# 			else
		# 				title
		# 	| \function => fallthrough
		# 	@_apps[name] = app
		# 	if Array.isArray also = app.also
		# 		for d in also
		# 			@_apps[d] = app
		# 	else if typeof also is \object
		# 		_.each also, (o, d) ->
		# 			@_apps[d] = ToolShed.extend app, o

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
		_.each proxies, (o, p) ~>
			opts = {}
			if target = o.target
				console.log "Url", @Url
				url = @Url.parse target
				if url.protocol is \ws:
					opts.ws = true
				opts.target = url.href
			@_proxies[p] = @HttpProxy.createProxyServer opts
			# if opts.ws

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
				@_server = @Http.createServer @_app
				@_server.on \connection (req, socket, head) !~>
					@debug "incoming connection"
				@_server.on \error (err) !~>
					@debug.error "http error -- %s %s", @listening, err.stack

					if err.code is \EADDRINUSE and not @listening
						# TODO: use Backoff here
						setTimeout ~>
							@exec \listen
						, 1000

				@_server.on \listening !~>
					@debug "listening on port #{@port}"
					@listening = true
					@transition \ready

					# TODO: interact with the child processes
					# if process.send
					# 	process.send {
					# 		type: \ready
					# 		port: port
					# 	}

				@transition \stopped
				@exec \listen

		destroyed:
			onenter: ->
				@debug "DESTROYED"
				@debug.todo "clean up memory and remove all event listeners"
				@emit \destroyed

		stopped:
			onenter: ->
				if @_server and @listening
					@_server.close!

			listen: ->
				@debug "going to try to listen on %s %s", @port, @listening

				unless @listening
					@_server.listen @port

		starting:
			onenter: ->

				# process.on \exit ->
				# 	server.close ->
				# 		debug "stopped accepting connections on #port"
				# 	debug "closing http down"



				# _.each @_app (app, port) ->
				# 	@_server[port] = server
				# for g in @gridfs
				# 	if not (db = @_gridfs[namespace]) instanceof GridFS
				# 		@_gridfs[g] = new GridFS g

		ready:
			onenter: ->
				console.log "ready oh yeah!!"

	cmds:
		'proxy.add': (opts, cmd_done) ->
		'proxy.remove': (opts, cmd_done) ->
		start: (opts, cmd_done) ->
			console.log ""

		stop: (cmd_done) ->
			@transition \stopped

		destroy: ->
			console.log "calling destroy -"
			@transition \stopped
			@once \state:stopped ~>
				@_server = null
				@transitionSoon \destroyed
				# cmd_done!
