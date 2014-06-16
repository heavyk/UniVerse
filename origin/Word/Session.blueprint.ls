encantador: \Word
incantation: \Session
type: \Fixed
presence: \Abstract
version: \0.1.0

poetry:
	Verse:
		Mun: \latest

layout:
	key:
		label: "public key for this session"
		type: \string
		required: true
	persona:
		label: "You"
		type: \string #\ObjectID
		ref: \Persona
		required: true
	mun:
		label: "Currently active Mun"
		type: \string #\ObjectID
		ref: \Mun
	data:
		label: "Extra Data"
		type: \object

machina:
	states:
		uninitialized:
			onenter: ->
				# TODO: merge this with the normal session.
				# I think it makes a lot more sense, and shows how to have different types of logins..
				# later, I think it'd be fun to make a frontend to facebook using their api.
				# hehehe, tha'd be aaaawwwweeesome :)
				@book.session.once_initialized ~>
					if @book.session.mun
						@transition \/logout
					else if @book.session.persona
						@transition \/select_mun
					else
						@transition \/login

		logout_error:
			onenter: ->
				@debug.todo "retry logout on error"
			render: (E) ->
				E \div c: \error "error logging you out.. retryig in [TODO] seconds"

		navbar:
			render: (E) ->
				session = @book.session
				var txt_email
				E \li,
					c: \dropdown
					onclick: ->
						setTimeout ->
							if txt_email
								txt_email.focus!
						, 50
					E \a href: '?top-menu-toggle', c: \dropdown-toggle data: toggle: \dropdown,
						E \img c: <[img-rounded img-mun]> data: src: 'holder.js/32x32'
						E \span c: \mun-name, (el) !->
							session.on \state:authenticated !->
								if not session.ident
									debugger
								E.rC el, session.ident
							session.on \state:not_authenticated !->
								E.rC el, "log in!"
						E \b c: \caret
					E \ul c: \dropdown-menu, (el) !->
						session.on \state:not_authenticated !->
							# debugger
							E.rC el, form = E \form c: \login role: \form,
								E \div c: \form-group,
									E \label for: \login_email, "Email address"
									txt_email := E \input type: \email c: \form-control id: \login_email placeholder: "Enter email"
								E \div c: \form-group,
									E \label for: \login_password, "Password"
									E \input type: \password c: \form-control id: \login_password placeholder: "Password"
								E \div c: \form-group,
									E \button,
										type: \submit
										c: 'btn btn-default'
										onclick: (e) ->
											user = form.0.value || \heavyk
											password = form.1.value || \lala
											session.exec \persona.login {user, password}, (err, res) ->
												if err
													window.alert "sorry, try again!"
											e.preventDefault!
											return false
									, 'login'
								E \div null,
									E \a href: '/register', "Don't have an accounnnnnt?"
						session.on \state:authenticated !->
							E.rC el, [
								E \li null,
									E \a href: '/preferences', "Preferences"
								E \li null, (el) ->
									session.on \state:authenticated !->
										E.$ el .empty!
										# E.aC el
									E \a href: '/preferences', "another thing"
								E \li c: \divider
								E \li null,
									E \a href: '/logout', "logout"
							]

		'/navbar':
			onenter: ->
				console.log "... navbar session"

			onexit: ->
				console.log "this shouldn't happen... I want to catch it if it does"
				debugger
				console.log "onexit"

			'/logout': ->
				@book.session.exec \persona.logout

		'/select_mun':
			onenter: ->
				console.log "yay you wanna change your mun now..."

			render: (E) ->
				# I'd really like to move the goto over to the init param, instead of defining it in the quest
				# window.MyMuns = @poetry.Verse.Mun "where my dawgs at?", goto: \session_list
				window.MyMuns = @poetry.Verse.Mun "where my dawgs at?" {persona: @book.session.persona}
				return
					* E \h3 null "My Muns"
					* E \div null "select a mun that you own:"
					* MyMuns

		'/logout':
			onenter: ->
				@book.session.exec \persona.logout (err, res) ~>
					if err => @transition \logout_error
					else @transition \uninitialized

			render: (E) -> "logging you out now..."

		'/register':
			render: (E) ->
				# TODO: threse could be voices:
				poem = @
				E \form role: \form,
					E \div c: \form-group,
						E \label for: \login_email, "Email address"
						E \input type: \email c: \form-control id: \login_email placeholder: "Enter email"
					E \div c: \form-group,
						E \label for: \login_password, "Password"
						E \input type: \password c: \form-control id: \login_password placeholder: "Password"
					E \div c: \form-group,
						E \label for: \login_email, "Something else..."
						E \input type: \text c: \form-control id: \login_email placeholder: "user@domain.com"
					E \div c: \form-group, "TODO: birthday and provincia"
					E \button,
						type: \submit
						c: 'btn btn-default'
						onclick: (e) ->
							@debug.todo "TODO: get the form items"
							data =
								username: e.target.form.0.value
								password: e.target.form.1.value || \lala

							poem.book.session.exec \persona.register data, (err, res) ->
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

		'/login':
			render: (E) ->
				mode = \login
				poem = @
				form = E \form role: \form,
					E \div c: \form-group,
						E \label for: \login_email, "Email address"
						E \input type: \email c: \form-control id: \login_email placeholder: "Enter email"
					E \div c: \form-group,
						E \label for: \login_password, "Password"
						E \input type: \password c: \form-control id: \login_password placeholder: "Password"
					confirm = E \div c: \form-group s: 'display:none',
						E \label for: \register_password, "Confirm Password"
						E \input type: \password c: \form-control id: \register_password placeholder: "Type your password again to be sure we got it right..."
					login_btn = E \button,
						type: \submit
						c: 'btn btn-primary'
						onclick: (e) ->
							console.info "TODO: get the form items instead from word"
							user = e.target.form.0.value || \heavyk
							password = e.target.form.1.value || \lala
							poem.book.session.exec \persona.login {user, password}, (err, res) ->
								if err
									window.alert "sorry, try again!"
							e.preventDefault!
							return false
					, 'login'
					register_btn = E \button,
						type: \button
						c: 'btn btn-link'
						onclick: (e) ->
							# debugger
							if mode is \login
								mode := \register
								jq_confirm = E.$ confirm
								jq_confirm.show 100, ->
									confirm.style.border = 'solid 2px #c00'
									confirm.style.padding = '5px'
									E.$ login_btn .hide!
									E.$ register_btn .removeClass \btn-link .addClass \btn-primary
									confirm.lastChild.focus!
							else if mode is \register
								data =
									username: e.target.form.0.value
									password: e.target.form.1.value || \lala

								poem.book.session.exec \persona.register data, (err, res) ->
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
