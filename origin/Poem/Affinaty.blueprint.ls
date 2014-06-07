
# for editing text content (and posts)
# http://epiceditor.com/

# email buttons
# http://www.industrydive.com/blog/how-to-make-html-email-buttons-that-rock/#outlook
# http://zurb.com/ink/docs.php
# https://news.ycombinator.com/item?id=7362589
# http://www.emailonacid.com/


# smokin those noobs like a chronic full of sack

encantador: \Poem
incantation: \Affinaty # this and the following are the path
type: \Fixed
version: \0.1.0 # this is like a tag
# embodies:
# 	* \Poem # technically, this isn't needed. It should already embody the poem, as it's the encantador
# 	# * \Creation #this should search (if not found) for type: \Fixed
# 	# * \Timely
# this is backwards right now...
# members:
	# session: \Session@latest
style: ''+require \fs .readFileSync '../../less/affinaty.less'
poetry:
	Verse:
		CommentList: \latest
		Mun: \latest
	Word:
		Mun: \latest
		Session: \latest
		NUE: \latest
	Voice:
		Affinaty: \latest
		Login: \latest
machina:
	brand: "affinaty" # (E) -> @name "affinaty"
	# (E) -> @name
	# (E) -> [ @name, E \span c: \version, 'v'+@version ]

	'extend.initialize': ->
		# these should be auto-initialized in 'poetry'
		# later, members are the elements of the page
		# @session =

	states:
		# all fixed items will redirect to the error code
		# this means that this is the first fime that the person has seen the page
		# (if there is a session, then we will reload once we have the preferences)
		uninitialized:
			onenter: ->
				@title = "affinaty is initializing..."
				console.log "affinaty... uninitialized"
				# @transition '/'

		new:
			onenter: ->
				debugger
				@title = "start your experience in affinaty now..."

				console.log "entered new state..."
				console.log "now, you have a persona, so we have to configure a mun"
				# I think this is bullshit. why is this here?
				# debugger
				# if @book.session.mun
				# 	@save!


			render: (E) ->
				# console.error "what trhe fuck is this shit??? kenny, get your shit together. this isn't a game this is for-fuckin-reAAAAall... ok? ignore all the spelling errors you had while typing... obviuosly it was the new workman keyboars layout and not the 6 beerrs beforehand :)"
				# console.warn "I'm sure you'll be fine though. you seem to have survived everything you've thrown at your body until now. actually, I think that could be used as good experience. I'd say that things come easier for me now than they did beforehand. I'd even go so far as to say as I'm a bit more enlightened. I think I'm coming around. I think I'm finally reaching that point that I always imagined I'd be at in x years when I'm steady, steadfast, and confident. so, you might be thinking to yourself that this guy is a liar, but I have just realized something. it's ALL about perspective. seriously. everything. I see myself realizing life. I may not have everything under control, but I tell you what, what... everything is how I imagineded it to be. every day I'm gaining more insight, more understanding, and a broador perspective. that sounds new-age. you're right. it is new age. a broader perspective is essentially a more open mind. I don't give a fuck what those new-aged hippies say, I *LIKE* a broader perspective. I like seeing more."
				# console.info "hey, so you ekow what? I really like doing this. I really like supporting people. I want everyone to grow and learn. I realize that it's not possible that all of us grow and evolve at the same rate, but I'd at least like to try and reduce that resistance. as I have become more solid in myself, I have noticed something amazing. first!!!!!!!!!! <(-- there are exclamations there because this is important. got ready! NEVER let anyone make you responsible for how they feel. ok, this will try and happen a lot, but you simply need to just get past it. it may even be possble that you could be making others responsible for how you feel. I did that once. there was once a time that I was not well in my head and I made my girlfriend responsible for how I felt. if I felt bad, I wanted her to comfort me. if I needed attention, she was the one that gave me the most. she was and is truly special. I don't doubt it even though we've been apart a long time now. What I'm trying to say here is that you simply cannot make someine else responsible for how you feel. believe it or not (if you don't, try it) but you can feel however you want in whatever moment you want."
				# console.info "so, if I can feel however I want in whatever moment, why do I feel bad sometimes, and need to combat that feeling by doing whatever small thing to make myself feel better? well that's a good question, and it depends a lot on your personality. if you're one of those people who do everything for the long-term, excluding risk, you may be a successful person or perhaps you just odentify yourself with the basetype - which is someone who isn't hedinistic in nature. you'd rather the biggor payoff. well here's news. most of us have some part of us that is that way. that's why they say the shy girls have more skelletons in the closet, the super hot hunks on tv are really insecure boys, etc. what I'm trying to say here is that, we are all a bit hedonistic in one way shapae or form. the reason is, this actually forms part of our personality to understand this. you want the experience. for reals... you want to leave that part of your personality in a bettor state than it was before."

				return window.Session = @poetry.Word.Session!
				muns = @poetry.Verse.Mun "where my dawgs at?" #, {persona: @book.session.persona}
				muns.on \empty ->
					# debugger
				console.log "persona:", @book.session.persona
				E \div null,
					E \div null, "we are new...."
					E \div null, "initialize the mun here... this is the new user experience..."
					E \div null, muns

		'404-no-longer-used':
			onenter: ->
				# debugger
				console.log "you don't have a session initialized. create a new session here"

				# @transition \login

			render: (E) ->
				# debugger
				return window.debugging = @poetry.Word.Session!
				# if @book.session.key
				# 	# debugger
				# 	return [
				# 		E \h2 null "welcome new user (insert the username here)"
				# 		E \ul c: \list,
				# 			* E \li null, "key:", @book.session.key
				# 			* E \li null, "persona", @book.session.persona
				# 			* E \li null, "mun", @book.session.mun
				# 		E \h4 null "... this is your first time on this web page. let's create a user or group..."
				# 		E \div null "this is a list of all of your users/groups:"
				# 		E \div null ->
				# 			#voice = new Voice
				# 			# an example of an external input:
				# 			# voice = @poetry.Voice.SearchInline \nue_search_mun
				# 			# voice = @poetry.Voice.MyMuns \nue, state: \nue
				# 			@debug.todo "this needs to become a poem: Poem/affinatyNUE"
				# 			# verse = @poetry.Verse.Mun {uid: @book.session.persona} #, state: \nue # voice: voice #this is redundant
				# 			# voice.on \update:search, (v) -> verse.meaning.set \name
				# 		# E \div null @poetry.Verse.Mun \search
				# 		E \div null "your currently active user/group:"
				# 		E \div null @poetry.Word.Mun @book.session.mun
				# 		E \div null,
				# 			E \button {
				# 				c: 'btn btn-primary'
				# 				onclick: ~>
				# 					@debug.todo "if we have groups... do nue.groups"
				# 					@transition '/'
				# 			}, "continue"
				# 	]
				# else
				# 	* E \div null "TODO: Show login"

		login:
			# onenter: ->
			# 	debugger
			render: (E) ->
				poem = @
				E \div c: \container,
					E \div c: 'col-sm-9',
						E \div c: \splash,
							E \h3 c: \title, "affinaty"
							E \div c: \description,
								E \ul c: \lala,
									E \li c: \i1,
										"a cool tagline here..."
									E \li c: \i1,
										"a cool tagline here..."
									E \li c: \i1,
										"a cool tagline here..."
					E \div c: 'col-sm-3',
						@poetry.Word.Session '/login'

		ENOENT2:
			onenter: ->
				console.log "lalala"
				# @transition \404

			render: (E) ->
				E \div null,
					E \h3 null "welcome to your first time on affinaty..."
					window.Session = @poetry.Word.Session!
					E \div null "TODO: set your datos"
					E \div null "TODO: save the session"
		ENOENT:
			onenter: ->
				console.log "NUE±±"
			render: (E) ->
				if @book.session.persona
					# debugger
					@poetry.Word.NUE!
				else
					debugger
					console.log "this shouldn't really happen, I don't think"

			# onenter: ->
			# 	console.log yay!

		'/home':
			render: (E) ->
				E \div null, ~>
					[
						# @poetry.Word.Mun.inst 1234
						"the home page"
					]
		'/profile':
			onenter: ->
				# if sess = @book.session.current
				# 	@transition \login
				# 	# if id = sess.mun
				# here we need a Poem:Mun(key) which has:
				# 0. basic privacy checks which will only show them if you are able to see them
				# 1. a basic component for photo uploads integrated into the (Word:Image)
				# 2. some comments
				# etc.


			render: (E) ->
				mun = @poetry.Word.Mun @book.session.mun, {
					goto: '/profile'
				}

				mun.once \state:ready ->
					debugger
				return mun


				# var cropper
				# E \div c: \cropper, (el) ->
				# 	cropper := new ICropper el, {
				# 		ratio: 1
				# 		image: \theme/demo.png
				# 		# preview: <[cropper-preview]>
				# 	}
				# 	E \div null "preview1"
				# 	E \div c: \preview1, (el) ->
				# 		cropper.bindPreview el
				# 	E \div null "preview1"
				# 	E \div c: \preview2, (el) ->
				# 		cropper.bindPreview el
				# return
				# 	* E \div id: \cropper-preview
					# * E \div null my_mun
					# * "TODO: the profile #{@book.session.mun}"

		'/':
			onenter: ->
				if @book.session.persona
					# debugger
					@transition '/home'
				# if @_is_new

				# nue = @get \nue
				# if typeof nue is \undefined
				# 	# debugger
				# 	@transition '/nue'

			render: (E) ->
				# debugger
				affinaty = @poetry.Voice.Affinaty
				nue = @get \nue
				# E \div null, "una mierda"
				E \div c: \container,
					E \div c: 'col-sm-7',
						E \h1 null, "Welcome to affinaty!"
						E \div null, "[TODO: the movie gallery here...]"
						# if typeof nue is \undefined
						# 	@poetry.Word.NUE! #@book.session.persona
						# else
						# 	E \div null "no need for a nue here..."
						# E \div null "nue:", typeof nue, nue
						E \div c: \affinaty-container, affinaty
					E \div c: 'col-sm-5',
						E \h2 null, "Regístrate"
						E \p null, "Conecta con gente como tú. Es gratis y muy fácil."
						window.login = @poetry.Voice.Login! #'/register'


		'/register':
			render: (E) -> @poetry.Word.Session! #'/register'

less: """
@require(less/affinaty.less);
"""