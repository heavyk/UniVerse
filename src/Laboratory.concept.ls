idea: \Laboratory
version: \0.1.0
description: "Volcrum's Lare"
concepts:
	Technician:				\idea://Technician
	Project:					\idea://Project
	Library:					\idea://Library
local:
	Fs:								\node://fs
	Path:							\node://path
	# Walk:							\npm://walkdir # soon, this is fixed... first compile the library
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

# (refs, opts) ->
# 	console.log "lab:::::::::::", typeof refs
# 	if typeof refs isnt \object
# 		refs = {}
# 	if typeof opts isnt \object
# 		opts = {}

# 		# throw new Error "Laboratory 'opts' must be an object"

# 	@prjs = []
# 	@refs = refs
# 	@config = opts.config || 'laboratory.json'
# 	@opts = opts
# 	super 'Laboratory', opts
# 	if opts.technician
# 		@exec \set:technician opts.technician
machina:
	initialize: ->
		@debug "Loading Vulcrum's Lare..."

	# eventListeners: {}

	states:
		uninitialized:
			onenter: ->
				console.log "NO WAY!!!", @Fs
				ToolShed.searchDownwardFor @config, (@opts.config_path || process.cwd!), (err, path) ~>
					# assert this instanceof Laboratory
					if err
						@transition \setup
					else
						cfg = Config path
						# return
						cfg.on \ready ~>
							# assert 	@ instanceof Laboratory
							@LAB = cfg
							if path = cfg.path
								@exec \set:path path
							else
								@exec \prompt:path


		ready:
			onenter: ->
				@emit \ready

			'set:technician': (who) ->
				if not technician = @LAB.technicians[who]
					throw new Error "the technician '#who' doesn't exist"

				@each (word, idx) ->
					if word instanceof Project
						# word.transition \close
						@exec \remove word
				_.each technician.projects, (path) ~>
					opts = {path}
					if cfg = technician.'projects.config'
						DaFunk.extend opts, cfg[path]
					@emit \add:Project opts
				# _.each @prjs (prj) ->
				# 	prj.transition \close
				# 	watcher.close!

			# task = @task 'loading...'
			# task.push "loading technician", (done) ->
			# 	assert this instanceof Laboratory
			# 	ask_technician = @prompt "technician:", technician, (res) ~>
			# 		assert this instanceof Laboratory
			# 		if typeof res is \string
			# 			if typeof (u = @LAB.technicians[res]) is \object
			# 				# @CONFIG.technician = res
			# 				@TECHNICIAN = u
			# 				@emit \notify, "loading technician #{u.github.technician}"
			# 				done!
			# 			else ask_technician "technician doesn't exist"
			# 		else if typeof res is \object
			# 			#TODO: these should use mongoose/PublicDB model verification
			# 			# mun = new Mun res
			# 			if typeof res.name is \string and typeof res.git is \object
			# 				# we're just gonna assume everything is all verified for now
			# 				@CONFIG.technicians[res.name] = res
			# 				done!
			# 			else "unknown object format or data"
			# 		else ask_technician "unknown input"
			# 	#echo "XXX: prompt for the technician. grab the zigzags. grab the glock. a mac.\nsome niggaz be cranked out. some be dranked out. I be danked out.\nthis is hamsta mutha fuckin nipples .. wit some heat 4 yo azz"
			# 	#setTimeout ~>
			# 	#	echo("tickedy tacky tack toe, that's some LOLz fo yo motha fuckin ho")
			# 	#, 5000
			# 	ask_technician "please type your technician"

			add_project: (name, path) ->
				# console.log "add project #name - #path"
				@prjs.push prj = new Project {name, path}, {lab: @}
				# prj.once_initialized ~>
				prj.until \ready ~>
					# console.log "------------------------prj.once_initialized", prj.namespace
					# console.log "lab.eventListeners",
					# console.log "prj.once_initialized", prj.namespace
					@emit \Project:added, prj

			remove_project: (name) ->
				console.error "TODO: "

		setup:
			onenter: -> echo "XXX: TODO ... set this shit up!!"

		close:
			onenter: ->
				@watcher.close!
				_.each @prjs, !(prj, i) ~>
					prj.transition \close
					@prjs[offset].transition \close
					@prjs.splice i, 0

	cmds:
		'set:path': (path) ->
			console.log "trying to set path:", path
			# path = @LAB.path
			ToolShed.stat path, (err, st) ~>
				if err
					throw err
				else if st.isDirectory!
					console.log "using path %s", path
					@debug "using path %s", path
					@path = path
					@transition \ready
			#process.chdir path

			# @watcher := Fs.watch path, (evt, filename) ~>
			# 	console.log "lab disturbance", &
			# 	if evt is \change
			# 		console.log "change event", &
			# 	else if evt is \rename
			# 		#@prjs.push new Project {path: path}
			# 		new_prj_path = Path.join path, filename
			# 		offset = false
			# 		_.each @prjs, !(prj, i) ~>
			# 			if prj.path is new_prj_path
			# 				offset := i
			# 				return false
			# 		ToolShed.stat new_prj_path, (err, st) ~>
			# 			if offset is false and not err and st.isDirectory!
			# 				@exec \add:Project name: filename, path: new_prj_path
			# 				# @prjs.push prj = new Project {path: new_prj_path, name: filename}, {lab: lab}
			# 				# prj.once_initialized ~>
			# 				# 	@emit \added, prj
			# 			else
			# 				@prjs[offset].transition \close
			# 				@prjs.splice offset, 0


			# walker_path = path
			# walker = Walk path, max_depth: 2
			# walker.on \directory (path, st) ~>
			# 	# this should create a Project which is really an extension of Repository
			# 	# which will in turn, create a src dir, an app.nw, etc.
			# 	prj_path = path.substr walker_path.length+1
			# 	console.log "prj_path:", prj_path
			# 	if path is \components
			# 		# component_walker = Walk path, max_depth: 1
			# 		# component_walker.on \directory (path, st) ->
			# 		prj = new Project {name, path}, {lab: @}
			# 		# this really should be a new Blueprint
			# 		prj.on \compile ->
			# 			console.log "something compiled", &
			# 	else
			# 		basename = Path.basename path
			# 		if ~(@TECHNICIAN.projects.indexOf basename)
			# 			@exec \add_project, basename, path

			# walker.on \end ~>
			# 	@transition \ready
		'prompt:path': ->
			dir = @opts.path || @LAB.path || Path.join ToolShed.HOME_DIR, 'Projects'
			ask_path = @prompt "Laboratory Projects path:", dir, (res) ~>
				if typeof res is \string
					ToolShed.stat res, (err, st) ~>
						if err
							if err.code is \ENOENT
								console.log "TODO: ask the technician if they want to create the path?"
								#@transition \setup
						else if st.isDirectory!
							console.log "set path:", res
							@exec \set:path, res
						else ask_path "path exists already but isn't a directory"
				else ask_path "unknown input"
			#TODO: do a quick check to see if HOME_DIR/Projects exists
			ask_path "where is your Laboratory located?"
