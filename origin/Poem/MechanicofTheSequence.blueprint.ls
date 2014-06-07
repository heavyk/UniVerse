

# https://github.com/holman/spark/wiki/Wicked-Cool-Usage

file_contents = (path) ->
	Fs = require \fs
	# this should change to Blueprint.fs.contents (and the watching done automatically)
	# Fs.watchFile path, ->
	# 	console.log " changed...", arguments
	# 	Fs.appendFile path, '', ->
	# 		console.log "updated..."
	return ''+Fs.readFileSync path

# for editing text content (and posts)
# http://epiceditor.com/

# email buttons
# http://www.industrydive.com/blog/how-to-make-html-email-buttons-that-rock/#outlook
# http://zurb.com/ink/docs.php
# https://news.ycombinator.com/item?id=7362589
# http://www.emailonacid.com/

encantador: \Poem
incantation: \MechanicOfTheSequence # this and the following are the path
type: \Fixed
version: \0.1.0 # this is like a tag
embodies:
	* \Poem
	# * \Creation #this should search (if not found) for type: \Fixed
	# * \Timely
poetry:
	# Verse:
	# 	CommentList: \latest
	# 	# CommentList:
	# 	# 	version: \latest
	# 	# 	another_feature: true
	# 	MunList: \latest
	Word:
		Mun: \latest
style: file_contents '../../less/mechanicofthesequence.less'
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
						E \div c: \hero-unit,
							E \h1 null, "Welcome to MechanicOfTheSequence"
							E \p null, "here are some tests below..."
						E \div null,
							E \p null,
								E \a href: '/matrix_4x4', "Basic 4x4 Matrix"

		'/matrix_4x4':
			'derivitave.node-webkit': !->
				alert "YYYYYYYY"

			'derivitave.browser': !->
				alert "browser"

			render: (E) ->
				how_many = 8
				els = []
				# usb = require \node-usb
				# console.log "usb", usb
				buckets = for i til (how_many*2) => [Math.random!]

				update = ->
					# buckets := for i til (how_many*2) => Math.random!
					for i til how_many*2
						buckets[i].push Math.random!
						if buckets[i].length > 10
							# console.log "shifting..."
							buckets[i].shift!
					rC la, print_one 8
					setTimeout update, 500

				print_one = (max, level = 0) ->
					_el = els[level]
					el = E \div c: 'quarter-container level-'+level, ->
						selected = Math.floor Math.random! * 4
						ll = level+1
						b = buckets.slice (level*2), ll*2
						bb = new Array b.length
						for a, i in b
							bb[i] = (a.reduceRight (pv, v) -> v + pv) / a.length
						selected = 0
						# TODO: do this in a loop....
						if bb.0 > 0.5
							selected += 1
						if bb.1 > 0.5
							selected += 2
						# console.log "selected", level, selected, b
						for j til 4
							E \span c: 'quarter '+(if selected is j => 'selected' else 'unselected'), onclick: if selected is j => (e) -> (console.log "you selected element: #j - level #level"; e.preventDefault!) else null ,
								if selected is j and ll < max
									print_one max, ll
					els.splice level, 1, el
					return el
				# setTimeout ->
				# 	update!
				# , 2000
				el = E \div c: \matrix-4-4,
					E \div null, "one matrix"
					# for i til 8
					la = E \div c: \matrix-container,
						print_one 8
				return el

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