# TODO: delete the default_proto when it's ready
# TODO: if the resuting object exists in the imported, put it right in
name: \npm
version: \0.11.13
type: \Fixed
local:
	ToolShed: \npm://MachineShop.ToolShed
machina:
	states:
		uninitialized:
			onenter: ->
				@transition \ready

		ready:
			resolve: (module, cb) ->
				@debug.todo "check to see if node exists and is compiled"
				try
					if ~(i = module.indexOf '@')
						version = module.substr i+1
						module = module.substr 0, i
					if module.0 is '.'
						throw new Error "local references are not allowes"
					else if ~(i = module.indexOf '.')
						path = module.substr i+1
						mod = module.substr 0, i
						mod = require mod
						mod = @ToolShed.get_obj_path path, mod
					else
						mod = require module
					cb null, mod
				catch e
					cb e

