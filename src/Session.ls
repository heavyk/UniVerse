
Library = require './Library' .Library

{ Fsm, ToolShed, _ } = require 'MachineShop'

# TODO: I would really like to abstract the url and stuff
# TODO: I would really lke to make this more complete... like make a blueprint, then a poem, and shit

class Session extends Fsm
	(@refs, key) ->
		# debugger
		# refs.library = @library = new Library refs, name: \sencillo # host: ...
		@current = {}

		# console.log "TODO: first connect to PublicDB/UniVerse and get the session bp?"
		# @currency = new Currency
		# @library = new Library
		super "Session(key)"
		@debug "hello, we are a session. id: %s", key

	key: ~-> @current.key
	persona: ~-> @current.persona
	ident: ~-> @current.ident
	mun: ~-> if @current.now => @current.now.mun
	poem: ~-> if @current.now => @current.now.poem
	id: ~-> if @current.now and p = @current.now.poem => @current.now[p]
	now: ~-> @current.now || @current.now = {}

	states:
		uninitialized:
			onenter: ->
				@debug "do nothing... wait to see whoami"
				@exec 'persona.whoami' (err, session) ~>
					@debug "executed whoami..."
					# debugger
					if err
						name = @default
						@debug "using default poem: %s", name
						# UniVerse.book.exec \open name
					else
						name = @current.poem
						@debug "using session poem: %s", name

			'persona.whoami': (cb) ->
				# debugger
				$.ajax {
					url: "/db/whoami"
					contentType: "application/json"
					success: (result) ~>
						# @current = result
						@current = {key: result.key}
						# later, this should be the value of Session[key]
						# I also need to redo this so it's a valid address, and give the person back the private key:
						# client generates a pub/priv key
						# client requests the session with the public key
						# server sends back the session encrypted to the public key with the pub/priv keys for that session
						# this will remove almost all fraud, accept for compromised random number generators
						# to get around bad random number generators, I will create entropy by using hashes of data downloaded combined with the machine random number generator

						if result.persona
							@current.persona = result.persona
							# @current.mun = result.mun
							# @current.poem = result.poem
							@current.now = result.now
							@current.ident = result.ident
						if typeof cb is \function => cb.call @, void, @current
						@transition if result.persona => \authenticated else \not_authenticated
						# @refs.UniVerse.emit \auth, void, result

					error: (res) ~>
						result = JSON.parse res.responseText
						if typeof cb is \function => cb.call @, result
						@transition \not_authenticated
						# @refs.UniVerse.emit \noauth, result
				}

		authenticated:
			onenter: ->
				@debug "we're authenticated"
				# if key = @key
				# 	@emit \key key
				# else @emit \!key
				# if persona = @persona
				# 	@emit \persona persona
				# else @emit \!persona
				# if mun = @mun
				# 	@emit \mun mun
				# else @emit \!mun

			'mun.set': (id, cb) ->
				console.error "TODO"
				$.ajax {
					url: "/db/whoami"
					type: \post
					dataType: \json
					data: JSON.stringify mun: id, poem: @refs.book.poem.key
					contentType: "application/json"
					success: (result) ~>
						@current.now = result
						if typeof cb is \function => cb.call @, void, result.mun
						if mun = @mun
							@emit \mun mun
						else @emit \!mun

					error: (result) ~>
						if typeof cb is \function => cb.call @, result
						# @refs.UniVerse.emit \error, err, "ERROR: unable to switch mun"
				}

			'mun.create': ->
				@debug.todo "add a function to create a new mun"
				debugger
				# @emit \mun id

			'persona.logout': (cb) ->
				$.ajax {
					url: "/db/logout"
					type: \post
					dataType: \json
					contentType: "application/json"
					success: (result) ~>
						@current = {}
						@transition \not_authenticated
						@emit \noauth
						if typeof cb is \function
							cb!
					error: (err) ~>
						if typeof cb is \function
							cb err
				}

		not_authenticated:
			onenter: ->
				@debug "session is ready now"
				# @emit \!key
				# @emit \!persona
				# @emit \!mun

			'persona.register': (opts, cb) ->
				$.ajax {
					url: "/db/register"
					type: \post
					dataType: \json
					data: JSON.stringify opts
					contentType: "application/json"
					success: (result) ~>
						@debug "Welcome %s" result.ident
						if result.persona
							@current.persona = result.persona
							@current.ident = result.ident
							@current.now = result.now
						if typeof cb is \function => cb.call this, void, @current
						if key = @key
							@emit \key key
						else @emit \!key
						if persona = @persona
							@emit \persona persona
						else @emit \!persona
					error: (result) ~>
						@current = void
						if typeof cb is \function => cb.call this, result
				}

			'persona.login': (opts, cb) ->
				$.ajax {
					url: "/db/login"
					type: \post
					dataType: \json
					data: JSON.stringify username: opts.user, password: opts.password
					contentType: "application/json"
					success: (result) ~>
						# debugger
						@debug "Welcome %s" result.ident
						if result.persona
							@current.persona = result.persona
							@current.ident = result.ident
							@current.now = result.now
						if key = @key
							@emit \key key
						else @emit \!key
						if persona = @persona
							@emit \persona persona
						else @emit \!persona
						if mun = @mun
							@emit \mun mun
						else @emit \!mun
						if typeof cb is \function => cb.call this, void, @currrent
						@refs.book.emit \auth @current
						@transition \authenticated
					error: (result) ~>
						@current = void
						if typeof cb is \function => cb.call this, result
						@refs.book.emit \noauth result
						@transition @initialState
				}


export Session

# TODO: implement mozilla's Persona
