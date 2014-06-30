name: \blueprint
version: \0.1.0
type: \Fixed
local:
	'{Reality}':
		\src://Reality
	'{Ether}':
		\src://Ether
	'{Blueprint}':
		\src://Blueprint
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
						@_cache[module] = impl = new @Blueprint path: "origin/#{module}.concept.ls" outfile: "library/#{module}.concept.js"

					impl.on \ready ~>
						@__cache[module] = constructor = impl.imbue @Ether
						cb null, constructor

					impl.on \compile:success ->

				catch e
					throw e
					cb e

			compile: ->

			stringify: ->

