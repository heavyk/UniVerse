# @need each object to have a refs to refs to mV, uV, etc. all the way down to the bottom
# @need origin to be an array of all of it's origins (prevents copies by impl.origin = this.origin ++ this)

name: \src
version: \0.11.13
type: \Fixed
local:
	ToolShed:
		\npm://MachineShop.ToolShed
machina:
	states:
		uninitialized:
			onenter: ->
				@transition \ready

		ready:
			resolve: (module, cb) ->
				@debug "src://#module"
				try
					if module.0 is '.' or module.0 is '/'
						throw new Error "local access outside of src is not allowed"
					if ~(i = module.indexOf '.')
						path = module.substr i+1
						mod = module.substr 0, i
						mod = require "./src/#mod"
						mod = @ToolShed.get_obj_path path, mod
					else
						mod = require "./src/#module"
					# m = mod[module]
					# if typeof m is \object or typeof m is \function
					# 	mod = m
					# if module is \Implementation
					# 	console.log "mod:", mod
					# 	console.log "m:", m
					cb null, mod
				catch e
					throw e
					cb e

