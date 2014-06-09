idea: \MultiVerse
version: \0.1.0
type: \Abstract
description: "the origin of the UniVerse"
concept:
	UniVerse:					\concept://UniVerse
local:
	ToolShed:					\npm://MachineShop.ToolShed
	Config:						\npm://MachineShop.Config
embodies:
	* \Idea
	* \Verse
	* \Interactivity

machina:
	initialize: ->
		@debug "Loading MultiVerse..."
		unless @config
			@config = 'multiverse.json'
		@debug "done initialize"

	# eventListeners: {}

	states:
		uninitialized:
			onenter: ->
				@ToolShed.searchDownwardFor @config, ((@config_path) || process.cwd!), (err, path) ~>
					if err
						@transition \setup
					else
						cfg = @Config path
						cfg.on \ready ~>
							@CONFIG = cfg
							@transition \ready

		ready:
			onenter: ->
				@debug "MultiVerse ready..."
				@emit \ready

			load: (id, cb) ->
				if not def = @CONFIG[id]
					throw new Error "universe '#id' doesn't exist"

				try
					cb null, uV = new @concept.UniVerse @refs, def
				catch e
					cb e

		setup:
			onenter: -> @debug.todo "set this shit up!!"

		close:
			onenter: -> @debug.todo "close shit down"

