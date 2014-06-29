
# this will evolve into a generic blueprint with which you will have an interface
# to create new words (same for Poem/Poem)

encantador: \Word
incantation: \Word
type: \Fixed
version: \0.1.0
layout:
	uid:
		type: \string
		ref: \Mun._key
		abstract: \Mun
		description: \Mün
		required: true
	type:
		type: \string
		ref: \Blueprint.type
		required: true
	name:
		type: \string
		ref: \Blueprint.name
		required: true
	version:
		type: \string
		abstract: \Semver
		required: true
	machina:
		type: \object
		# required: true
	api:
		type: \object
		# required: true

phrases:
	txt_link: (E, d) ->
		E \a title: @get(\name), href: '/profile/'+@get(\_id),
			@get \name

machina:
	states:
		uninitialized:
			onenter: ->

			render: (E) ->
				# E \h2 null "Word::uninitialized::loading..."

		'/':
			onenter: ->
				unless @book.session.key
					@transition \login

			render: (E) ->
				draw_feed_entry = (who) ->
					E \div c: \media,
						E \a c: \pull-left href: '/profile/augusto',
							E \img c: <[img-rounded img-mun]> data: src: 'holder.js/64x64'
						E \div c: \media-body,
							E \h4 c: \media-heading,
								E \a href: '/profile/'+who, who
								E \small null "opina sobre..."
							E \h5 null, "los hombres son mejores que las mujeres"
							"some sort of response here..."

				E \div, c: \row,
					E \div, c: <[col-sm-4 home-sidebar]>,
						E \div c: <[panel panel-default]>,
							E \div c: \panel-heading, "Sidebar"
							E \div c: \panel-body,
								E \p null,
									E \a href: '/preferences', "preferences"
								#Poem.poetry.session.list_muns
								for id in [11, 1155, 1234, 1111]
									E \p null,
										E \a href: "/profile/#id", "link '#id'"
					E \div, c: <[col-sm-8 home-feed]>,
						#E \h1, null, "Home page"
						E \div c: <[panel panel-default]>,
							E \div c: \panel-heading, "the feed..."

							E \div c: \panel-body, ->
								return "TODO: user.view \\feed"

								for i in [\lala \jaja \jose \oooo]
									draw_feed_entry "alguien \#"+i

								E \div c: \media,
									E \a c: \pull-left href: '/profile/jenny',
										E \img c: <[img-rounded img-mun]> data: src: 'holder.js/64x64'
									E \div c: \media-body,
										E \h4 c: \media-heading,
											E \a href: '/profile/jenny', "Jenny"
											E \small null "opina sobre..."
										E \h5 null, "se conoce a su misma"
										"some sort of response here..."

								E \div c: \media,
									E \a c: <[pull-left mun-link]> href: '/profile/jenny',
										E \img c: <[img-thumbnail img-mun]> data: src: 'holder.js/64x64'
										#E \div c: \prox-box,
										# E \span c: \prox s: 'background-color:\#722;width:40%'
									E \div c: \media-body,
										E \h4 c: \media-heading,
											E \a href: '/profile/jenny', "Jenny"
											E \small null "opina sobre..."
										E \h5 null, "se conoce a su misma"
										"some sort of response here..."

								E \div c: \media,
									E \a c: <[pull-left mun-link]> href: '/profile/jenny',
										E \img c: <[img-thumbnail img-mun]> data: src: 'holder.js/64x64'
										#E \div c: \prox-box,
										# E \span c: \prox s: 'background-color:rgb(110,223,38);width:90%'
									E \div c: \media-body,
										E \h4 c: \media-heading,
											E \a href: '/profile/jenny', "Jenny"
											E \small null "opina sobre..."
										"eres tan wapo!"


		ready:
			render: (E) ->
				# debugger
				@debug.error "remove it from loading this state"
				E \div null "Word::ready::yay!"

		'/about_us':
			onenter: ->

			render: (E) ->
				E \div c: \container,
					E \h2 null, "About Us"
					E \p null, "some about us text goes here..."


		'/home':
			onenter: ->
				# if necessary, so some init

			render: (E) ->

		'/profile/:id':
			onenter: (url) ->
			render: (E, url) ->
				E \div null, "someone else's profile, id: ", url.params.id

		'/profile':
			render: (E, url) ->
				if session = @book.session.current
					console.log "gonna try inst:", @poetry.Word.Mun
					user = @poetry.Word.Mun.inst @book.session.current.mun
					console.warn "Word", @poetry.Word.Mun.inst
					console.log "Verse", @poetry.Verse
					user.render \profile
				else
					@transition \login

		'/new':
			render: (E) ->
				"TODO: #{path.slice 1 .join ' '}"

		'/preferences':
			render: (E) ->
				poem = @
				E \div c: \preferences,
					E \h3 null, "Preferences"
					E \div null, "... nothing here yet ..."
					E \h3 null, "Different entities"
					E \div c: \muns,
						E \div c: \list-group, (parent_el) ->
							el = E \li c: \list-group-item, "loading..."
							poem.list_muns (err, res) ->
								console.log "list_muns", err, res
								replace =
									if err
										E \div c: \error, "something went wrong..."
									else for m in res.muns
										console.log "mun==sess", m._key, poem.poetry.mun
										E \a c: "list-group-item#{if m._key is poem.poetry.session.current.mun => ' active' else ''}" href: '/profile/'+m._key,
											E \div c: \media,
												E \img c: <[pull-left img-rounded img-mun]> data: src: 'holder.js/32x32'
												E \div c: \media-body,
													E \h4 c: \media-heading,
														E \a href: '/profile/'+m._key, m.name
								$ el .remove!
								aC parent_el, replace
							el
					E \h3 null, "Profile Photo"
					E \div c: \dropzone, id: 'my-dropzone',
					# this is the fallback form....
					# E \form c: \dropzone action: '/file-upload',
					#   E \div c: \fallback,
					#     E \input name: "file" type:"file" multiple:true
						!(el) ->
							process.nextTick ->
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
									Cropper = window.component.require 'yields-crop'
									aC null, img = E \div c: \crop,
										E \img src: "i/#id"
									cropper = Cropper img
									cropper.build!
									console.log "cropper", cropper
									cropper.on \crop (dim) ->
										console.log "cropper dims:", dim
								dz.on \complete ->
									console.log "complete" &

		'/message':
			render: (E) ->
				E \div c: \messages,
					E \h3 null "new MunMessage refs"
					E \div null "should display the message box here (also integrate autocomplete)"
		'/logout':
			onenter: ->
				@debug.error "this is a huge error... I need to figure out why this is being merged into a POEM"
				poem = @
				# debugger
				@book.session.exec \persona.logout ->
					poem.transition \login
