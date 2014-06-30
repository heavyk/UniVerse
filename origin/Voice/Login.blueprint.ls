encantador: \Voice
incantation: \Login
type: \Cardinal # later, type will be changed to significance
significance: \Cardinal
presence: \Abstract
version: \0.1.0
motd:
	* "horray for feelings!"
poetry:
	Word:
		Mun: \latest
# experience:
# 	# startsWith: ???
# 	have: (db, req, res) ->
# 		persona: if req.user then req.user._key else null
layout:
	ident:
		label: "email"
		type: \string
		render: \email
		required: true
		onempty: "email: kenny@affinaty.es"
		# quick note, verify will see true as a correct value, oherwise it will check to be sure the returned type is typeof 'string'
		validate: (v) ->
			return /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/.test v
			# if /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/.test v
			# 	true
			# else false
		oninvalid: "email must be a valid format eg. 'kenny@affinaty.es'"
		get: ->
			@book.session.ident
		# oninfo: "the persona which owns this mun [hidden]"
	password:
		label: "Password"
		type: \string
		render: \password
		required: true
		onempty: "type your password here."
		oninfo: (E) ->
			# debugger
			return
				* "forgot your password? "
				* E \a href: '/forgot', "click here"
		validate: (v) ->
			typeof v is \string and v.length > 5
	password_again:
		label: "Confirm Password"
		type: \string
		render: \password
		required: true
		onempty: "type your password again."
		onchange: (v) ->
			console.log "change!!", v, @get \password
			if v is @get \password
				console.log "EQUAL!!!!"
	# submit:
	# 	label: "log in"
	# 	type: \button
	# 	# dimensions: \x32
	# 	default: 'holder.js/32x32' #\lala.jpg
	# 	onempty: "please upload a foto for your Mun"
	# 	oninfo: "the image everyone will see associated with your Mun"

machina:
	initialState: '/login'
	eventListeners:
		created: (xp) ->
			@exec \make_new
			@emit \transition {fromState: @state, toState: @state}

		submit: (e) ->
			debugger
			console.log "we got a submit!"


	states:
		uninitialized:
			onenter: ->
				console.log "yay!"

		'login.success': ->
			var msg
			onenter: (opts) ->
				msg := opts

			render: (E) ->
				E \div null, msg

		'login.error': ->
			var msg

			onenter: (opts) ->
				msg := opts
				console.log "login.error", opts

			render: (E) ->
				E \div c: 'alert alert-danger',
					E \p null,
						E \strong null "unknown error"
					E \p, null,
						msg || "you betta check yo'self"
					E \p null,
						E \a href: '/login', "try again"


		'/persona.login':
			onenter: (opts) ->
				console.log "persona.login.onenter", opts
				console.log "ident:", user = (@get \ident) || \heavyk
				console.log "password:", password = (@get \password) || \lala
				@book.session.exec \persona.login {user, password}, (err, res) ~>
					if err
						@transition \login.error, "invalid login credentials..."
					else
						@transition \login.success, "horray for boobies"
			render: (E) ->
				E \div c: 'alert alert-info', "TRYING TO LOG YOU IN>>>"

		'/login':
			parts:
				buttons: (E) -> E \div c: \row
			order:
				* \ident
				* \password
				* \buttons
			eventListeners:
				submit: (e) ->
					debugger
					# I'm not really sure why this doesn't work...
					console.log "we got a submit!"
			# onenter: ->

			buttons: (E) ->
				return [
					E \div c: 'col-sm-6', ~>
						@on \all-good ->
							E.$ btn .removeClass \disabled .addClass \btn-default .addClass \btn-primary
						# btn = E \input type: \submit value: "login" c: 'btn btn-default disabled'
						# btn = E \input type: \submit value: "login" c: 'btn btn-default'
						btn = E \a href: \persona.login c: 'btn btn-default', "login"
					E \div c: 'col-sm-6',
						E \a c: 'btn btn-link' href: '/register', "register :)"
				]

		'/forgot':
			parts:
				# header: (E) -> E \div c: 'alert alert-warning fade in'
				header: (E) -> E \div c: 'alert alert-warning'
			order:
				* \header
				* \ident
				# * \password
				# * \password_again
				* \buttons

			header: (E) ->
				el = E \p null, "if you forgot your email, please wait for an email from us to reset your password"
				# E.$ el .fadeIn 100
				return el

			buttons: (E) ->
				return [
					E \div c: 'col-sm-6', ~>
						@on \all-good ->
							E.$ btn .removeClass \disabled .addClass \btn-default .addClass \btn-primary
						# btn = E \input type: \submit value: "login" c: 'btn btn-default disabled'
						return [
							btn = E \input type: \submit value: "login" c: 'btn btn-default'
							login_btn = E \button,
								type: \submit
								c: 'btn btn-primary'
								onclick: (e) ~>
									console.info "TODO: get the form items"
									user = e.target.form.0.value || \heavyk
									password = e.target.form.1.value || \lala
									password = \lala
									console.info "TODO: send the login request", user, password
									@book.session.exec \persona.login {user, password}, (err, res) ->
										if err
											window.alert "sorry, try again!"
									e.preventDefault!
									return false
							, 'login'
						]
					E \div c: 'col-sm-6',
						E \a c: 'btn btn-link' href: '/login', "nevermind.."
				]

		'/register':
			order:
				* \ident
				* \password
				* \password_again
				* \buttons

			onenter: ->

			buttons: (E) ->
				el = @_parts.password_again
				# lolz this is so poorly done, it's to visually remind me to make it better... hahahaha
				el.style.border = 'solid 0.5em #c00'
				el.style.padding = '5px'
				setTimeout ->
					el.style.border = 'solid 0.25em #c00'
				, 1000
				setTimeout ->
					el.style.border = 'solid 0.15em #c00'
				, 2000
				setTimeout ->
					el.style.border = 'solid 0.1em #c00'
				, 3000
				setTimeout ->
					el.style.border = ''
					el.style.padding = ''
				, 3000
				el.style.padding = '5px'
				E \div c: 'col-3 col-offset-9',
					E \a c: 'btn btn-primary' href: '/register', "register!!!"

