/*

grid windows:
 - https://github.com/ubervu/grid

content composer:
 - http://substance.io/

music source:
 - http://music.163.com/#/artist?id=38115
  - https://www.npmjs.org/package/music163-cli
*/

encantador: \Poem
incantation: \NewFriends # this is like the branch
type: \Fixed
version: \0.1.0 # this is like a tag
embodies:
	* \Poem
poetry:
	Word:
		'Mun': \0.1.0
		'ThisIsNewFriends': \1.1.1
machina:
	brand: "New Friends"
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
				E \div c: \container,
					E \div c: 'col-sm-9',
						E \h1 null, "welcome to new friends"
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
									poetry.session.login user, secret, (err, res) ->
										if err
											window.alert "sorry, try again!"
									e.preventDefault!
									return false
							, 'login'
							E \div null,
								E \a href: '/register', "Don't have an accounnnnnt?"
		'/register':
			render: (E) ->
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
									poetry.session.register data, (err, res) ->
										if err
											window.alert "sorry, try again!"
									e.preventDefault!
									return false
							, 'register'
					E \div c: 'col-sm-2',
						E \h4 null, "sidebar right"
	# ...