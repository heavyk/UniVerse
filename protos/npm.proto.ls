# the most basic module ... EVER
name: \npm
version: \0.11.13
type: \Fixed
machina:
	states:
		unitialized:
			onenter: ->
				@debug.todo "check to see if node exists and is compiled"
				@transition \ready
		ready:
			onenter: ->
				console.log "npm ready"

			resolve: (module, cb) ->
				try
					cb null, require module
				catch e
					cb e

