
# charting / graph library
# http://dc-js.github.io/dc.js/

# credit card form
# http://jessepollak.github.io/card/

# split the ssl into a subsystem
# https://github.com/gozdal/accessl/


idea: \MultiVerse
version: \0.1.0
type: \Abstract
description: "choose your origin"
concept:
	UniVerse:					\concept://UniVerse
local:
	# Fs:								\node://fs
	# Path:							\node://path
	# Walk:							\npm://walkdir
	ToolShed:					\npm://MachineShop.ToolShed
	Config:						\npm://MachineShop.Config
# poetry:
# 	Word:
# 		Technician:			\latest
# 		Project:				\latest
embodies:
	* \Idea
	# * \Form
	# * \Creativity
	* \Verse
	* \Interactivity

machina:
	initialize: ->
		@debug.notify "Loading MultiVerse..."
		unless @config
			@config = 'multiverse.json'
		@debug "done initialize"

	# eventListeners: {}

	states:
		uninitialized:
			onenter: ->
				@ToolShed.searchDownwardFor @config, ((@config_path) || process.cwd!), (err, path) ~>
					# assert this instanceof Laboratory
					if err
						@transition \setup
					else
						cfg = @Config path
						# return
						cfg.on \ready ~>
							# assert 	@ instanceof Laboratory
							@CONFIG = cfg
							@transition \ready
							# if path = cfg.path
							# 	@exec \set:path path
							# else
							# 	@exec \prompt:path

		ready:
			onenter: ->
				@debug.notify "MultiVerse ready..."
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

