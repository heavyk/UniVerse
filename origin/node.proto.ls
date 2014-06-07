# the most basic module ... EVER
part: \poetry
name: \node
type \Fixed
this: ->
	# if we want to restrict more, do it here
	return
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
returns: (module) ->
	if ~@allowed.indexOf module
		require module
	else
		throw new Error "requiring of module '#module' has been rejected for some reason"


