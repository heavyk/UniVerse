name: \concept
version: \0.1.0
type: \Fixed
local:
	# Reality:					\npm://./Reality
	# Implementation:		\npm://./Implementation
	'{Reality}':
		\src://Reality
	'{Ether}':
		\src://Ether
	'{Implementation}':
		\src://Implementation
	'{DaFunk}':
		\npm://MachineShop
machina:
	order:
		* \idea
		* \version
		* \type
		* \description
		* \embodies
		* \local
		* \concept
		* \poetry
		* \ether
		* \ambiente
		* \architect
		* \machina
	states:
		uninitialized:
			onenter: ->
				@_cache = {}
				@__cache = {}
				@transition \ready

		ready:
			resolve: (name, cb) ->
				try
					if constructor = @__cache[module]
						return cb null, constructor
					else if not impl = @_cache[module]
						@_cache[module] = impl = new @Implementation path: "origin/#{module}.concept.ls" outfile: "library/#{module}.concept.js"

					impl.on \ready ~>
						console.log "embue with ether:", @Ether
						@__cache[module] = constructor = impl.imbue @Ether
						# throw new Error "imbued with ether!"
						cb null, constructor
				catch e
					throw e
					cb e

			compile: ->

			stringify: ->

