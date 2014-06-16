# @need each object to have a refs to refs to mV, uV, etc. all the way down to the bottom
# @need origin to be an array of all of it's origins (prevents copies by impl.origin = this.origin ++ this)

name: \origin
version: \0.11.13
type: \Fixed
local:
	ToolShed:
		\npm://MachineShop.ToolShed
	DaFunk:
		\npm://MachineShop.DaFunk
machina:
	states:
		uninitialized:
			onenter: ->
				@transition \ready

		ready:
			resolve: (module, cb) ->
				@debug "origin://#module"
				try
					if module.0 is '.' or module.0 is '/'

						throw new Error "local access outside of origin is not allowed"
					console.log process.cwd!
					# TODO: this will break for './Reality'
					if ~(i = module.indexOf '.')
						path = module.substr i+1
						mod = module.substr 0, i
						mod = require "./origin/#mod"
						mod = @ToolShed.get_obj_path path, mod
					else
						mod = require "./origin/#module"
					m = mod[module]
					console.log "module", module, "mod", mod, m
					mod = m if typeof m is \object or m is \function
					cb null, mod
				catch e
					throw e
					cb e

			compile: ->

			stringify: ->
