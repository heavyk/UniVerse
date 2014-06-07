# need dropzone functionality
# need icropper functionality

# maybe add lab support:
# https://github.com/antimatter15/rgb-lab

encantador: \Voice
incantation: \Affinaty
type: \Cardinal
version: \0.1.0
motd:
	* "oh yeah, you like nuts too?! I mix mine with dried cranberries for extra essence. you?"
poetry:
	Word:
		Mun: \latest
experience:
	# startsWith: ???
	have: (db, req, res) ->
		require \console .log "Voice.Affinaty", JSON.stringify req.currentSession
		mun: req.currentSession.get(\mun)
		persona: req.user._key
layout: # searches for {}
	persona:
		type: \key
		ref: \Persona
		index: true
		required: true
	mun:
		type: \key
		ref: \Mun
		index: true
		required: true
	nue_progress:
		type: \number # \reward
		default: 0
	nue:
		type: \object
		default: {}
		hidden: true
		layout:
			profile_foto:
				type: \key
				hidden: true
				reward:
					nue_progress: 30
			first_comment:
				type: \key
				hidden: true
				reward:
					nue_progress: 10
			create_group:
				type: \key
				hidden: true
				reward:
					nue_progress: 20

machina:
	# order:
	# 	* \jumbotron
	parts:
		step: (E) -> E \div c: 'jumbotron step'

	eventListeners:
		# I think that this can be improved on quite a bit here...
		# I'd like to see a state progression like this [/state] -> saving -> saved -> [/state]
		created: (xp) ->
			@exec \make_new
			@emit \transition {fromState: @state, toState: @state}

	# parts:
	# 	step: (E) ->
	# 		E \div c: 'jumbotron step'

	# 	crop: (E) ->
	# 		@_blockNodes = {}
	# 		@_archors = {}
	# 		for k in <[l t r b]>
	# 			E.aC @_el, @_blockNodes[k] = E \div c: "block block-#k"
	# 		E \div c: "cropnode no-select", (el) !~>
	# 			for k in <[lt t rt r rb b lb l]>
	# 				@_archors[k] = E \div c: "archor archor-#k"

	# 	img: (E) ->
	# 		voice = @
	# 		E \img src: 'i/' + @get \hash,
	# 			title: @get \caption
	# 			onload: ->
	# 				voice.exec \set_size, @offsetWidth, @offsetHeight
	states:
		uninitialized:
			onenter: ->
				console.log "yay!"
				debugger

			render: (E) ->
				E \div null "uninitialized..."

		crop_foto:
			order:
				* \img
				* \crop

			onenter: ->
				console.log "welcome to photo crop!!"

		profile_foto:

			order:
				# * \persona
				* \img
				* \step
				* \caption
				* \title
				* \next
			onenter: ->
				# debugger

			step: (E) ->
				E \div c: 'jumbotron step-1',
					E \h3 null, "upload a foto"
					E \div c: \dropzone, id: 'my-dropzone',
					# this is the fallback form....
					# E \form c: \dropzone action: '/file-upload',
					#   E \div c: \fallback,
					#     E \input name: "file" type:"file" multiple:true
						!(el) ->
							setTimeout ->
								console.log "dropzone", el
								Dropzone = window.component.require 'enyo-dropzone'
								dz = new Dropzone el,
									url: '/file-upload'
									dictDefaultMessage: "drag a photo here, or <a href=\"javascript:void(0)\">click</a> to browse for a photo"
								dz.on \addedFile ->
									console.log "addedFile", &
								dz.on \thumbnail (file, data_url) ->
									console.log "thumbnail", &
								dz.on \uploadprogress (file, percent, bytes) ->
									console.log "progress", percent, bytes
								dz.on \sending (file) ->
									console.log "sending file ...", &
								dz.on \error (file, error) ->
									console.log "error", &
								dz.on \success (file, id, evt) ->
									console.log "successfully uploaded file with id #id" &
									var cropper
									aC el, E \div c: \cropper-container,
										E \div c: \cropper, (el) !->
											cropper := new ICropper el, {
												ratio: 1
												image: "i/#id"
												# preview: <[cropper-preview]>
											}
										E \div null "preview1"
										E \div c: \preview1, (el) ->
											cropper.bindPreview el
										E \div null "preview2"
										E \div c: \preview2, (el) ->
											cropper.bindPreview el

								dz.on \complete ->
									console.log "complete" &
							, 10

			next: (E) ->
				E \div c: \row,
					E \div c: 'col-3 col-offset-9',
						E \p c: \text-right,
							E \a c: 'btn btn-primary' onclick: ~> (@transition \nue2), "go to step 2"

		nue2:
			order:
				* \step
				* \img

			step: (E) ->
				E \div c: 'jumbotron step-2',
					E \h3 null, "step 2"
					E \button onclick: ~> (@transition \nue2), "done!"

		add_another:
			# this should be for all! - add this to Meaning?
			# also we neeed to add E.render! - E.render \section
			order:
				* \render
				* \name

			onenter: ->
				console.log "add_another"
				# debugger

			render: (E) ->
				E \div null "add another..."
