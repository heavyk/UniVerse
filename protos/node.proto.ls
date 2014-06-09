# the most basic module ... EVER
name: \node
version: \0.11.13
type: \Fixed
machina:
	allowed:
		* \buffer
		* \crypto
		* \dgram
		* \dns
		* \domain
		* \events
		* \freelist
		* \fs
		* \http
		* \https
		* \net
		* \os
		* \path
		* \punycode
		* \querystring
		* \stream
		* \string_decoder
		* \timers
		* \tls
		* \url
		* \util
		* \vm
		* \zlib
	states:
		unitialized:
			onenter: ->
				@debug.todo "check to see if node exists and is compiled"
				@transition \ready
		ready:
			onenter: ->
				console.log "node ready"

			resolve: (module, cb) ->
				try
					if ~@allowed.indexOf module
						cb null, require module
					else
						throw new Error "requiring of module '#module' has been rejected for some reason"
				catch e
					cb e


