
Library = require './Library' .Library

{ Fsm, ToolShed, _ } = require 'MachineShop'

class Session extends Fsm
	(@refs, key) ->
		@current = {}
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
					if err
						name = @default
						@debug "using default poem: %s", name
					else
						name = @current.poem
						@debug "using session poem: %s", name

			'persona.whoami': (cb) ->
				$.ajax {
					url: "/db/whoami"
					contentType: "application/json"
					success: (result) ~>
						@current = {key: result.key}
						# later, this should be the value of Session[key]
						# I also need to redo this so it's a valid address, and give the person back the private key:
						# client generates a pub/priv key
						# client requests the session with the public key
						# server sends back the session encrypted to the public key with the pub/priv keys for that session
						# this will remove almost all fraud, accept for compromised random number generators
						# to get around bad random number generators, I will create entropy by using hashes of data downloaded combined with the machine random number generator
						# ----
						# wow, I was really stoned when I wrote that, but I'll leave it for the moment... will delete soon... lol

						if result.persona
							@current.persona = result.persona
							@current.now = result.now
							@current.ident = result.ident
						if typeof cb is \function => cb.call @, void, @current
						@transition if result.persona => \authenticated else \not_authenticated

					error: (res) ~>
						result = JSON.parse res.responseText
						if typeof cb is \function => cb.call @, result
						@transition \not_authenticated
				}

		authenticated:
			# onenter: ->
			# 	@debug "we're authenticated"

			'mun.set': (id, cb) ->
				@debug.todo "TODO: mun.set working properly :)"
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
				}

			'mun.create': ->
				@debug.todo "add a function to create a new mun"

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
