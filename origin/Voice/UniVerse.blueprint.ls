
# for editing text content (and posts)
# http://epiceditor.com/

# email buttons
# http://www.industrydive.com/blog/how-to-make-html-email-buttons-that-rock/#outlook
# http://zurb.com/ink/docs.php
# https://news.ycombinator.com/item?id=7362589
# http://www.emailonacid.com/

encantador: \Poem
incantation: \UniVerse # this and the following are the path
type: \Fixed
version: \0.1.0 # this is like a tag
embodies:
	* \Poem
	# * \Creation #this should search (if not found) for type: \Fixed
	# * \Timely
poetry:
	Verse:
		CommentList: \latest
		# CommentList:
		# 	version: \latest
		# 	another_feature: true
		MunList: \latest
	Word:
		Mun: \latest
machina:
	brand: "UniVerse" # (E) -> @name "Affinaty"
	# (E) -> @name
	# (E) -> [ @name, E \span c: \version, 'v'+@version ]
	create_mun: (name) ->
		$.ajax {
			url: "/db/mun"
			type: \put
			dataType: \json
			data:
				name: name
				uid: poetry.session.current.uid
			contentType: "application/json"
			success: (result) ->
				console.log "res:" result
			error: (result) ->
				console.log "Error:" result
		}
	list_muns: (cb) ->
		$.ajax {
			url: "/db/mun/_"
			#type: \head
			dataType: \json
			data:
				name: poem.name
				uid: poetry.session.current.uid
			contentType: "application/json"
			success: (result) ->
				console.log "res:" result
				if typeof cb is \function
					cb null, result
			error: (result) ->
				console.log "Error:" result
				if typeof cb is \function
					cb result
		}
	states:
		login:
			render: (E) ->
				poem = @
				E \div c: \container,
					E \div c: 'col-sm-9',
						E \div c: \splash, ->
							# splash = poem.poetry.Word.Affinaty.inst poem.poetry.session.poem
							# splash = poem.poetry.Word.Affinaty.inst \affinaty # \affinaty_beta
							console.log "splishy splasy"
					E \div c: 'col-sm-3',
						form = E \form role: \form,
							E \div c: \form-group,
								E \label for: \login_email, "Email address"
								E \input type: \email c: \form-control id: \login_email placeholder: "Enter email"
							E \div c: \form-group,
								E \label for: \login_password, "Password"
								E \input type: \password c: \form-control id: \login_password placeholder: "Password"
							E \button,
								type: \submit
								c: 'btn btn-default'
								onclick: (e) ->
									console.info "TODO: get the form items"
									user = e.target.form.0.value || \heavyk
									secret = e.target.form.1.value || \lala
									console.info "TODO: send the login request", user, secret
									poem.poetry.session.login user, secret, (err, res) ->
										if err
											window.alert "sorry, try again!"
									e.preventDefault!
									return false
							, 'login'
							E \div null,
								E \a href: '/register', "Don't have an accounnnnnt?"
		'/home':
			render: (E) ->
				E \div null, ~>
					[
						"the home page"
					]
		# '/profile':
		# 	render: (E) -> "TODO: the profile"
		# 		#...
		# 	footer: (E) ->
		# 		E \div c: 'container', "this is text"
		'/':
			onenter: ->
				unless @book.session.current
					@transition \login
			render: (E) ->
				# E \div null, "una mierda"
				E \div c: \container,
					E \div c: 'col-sm-2',
						E \h4 null, "sidebar left"
					E \div c: 'col-sm-8',
						E \h1 null, "Welcome to your home page"

		'/register':
			render: (E) ->
				poem = @
				E \div c: \container,
					E \div c: 'col-sm-2',
						E \h4 null, "sidebar left"
					E \div c: 'col-sm-8',
						E \h1 null, "Welcome to Affinaty"
						E \hr, null
						E \p, null, "registering with us is like having Jesus piss on your face"
						E \form role: \form,
							E \div c: \form-group,
								E \label for: \login_email, "Email address"
								E \input type: \email c: \form-control id: \login_email placeholder: "Enter email"
							E \div c: \form-group,
								E \label for: \login_password, "Password"
								E \input type: \password c: \form-control id: \login_password placeholder: "Password"
							E \button,
								type: \submit
								c: 'btn btn-default'
								onclick: (e) ->
									console.info "TODO: get the form items"
									data =
										username: e.target.form.0.value
										password: e.target.form.1.value || \lala

									poem.poetry.session.register data, (err, res) ->
										if err
											console.error "regisger err", err
											switch err.status
											| 400 =>
												window.alert "user already exists!"
											| otherwise =>
												window.alert "unknown error #{err.status}"

									e.preventDefault!
									return false
							, 'register'
					E \div c: 'col-sm-2',
						E \h4 null, "sidebar right"
	# ...