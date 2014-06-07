encantador: \Word # \Word@latest
incantation: \Persona
type: \Fixed
version: \0.1.0
embodies:
	* \Timely # this will import the d_created / d_modified fields, and the t_delta part

verify: (obj) ->
	console.log "verify that someone can do something to this model"
	console.log "I need access to the session here, along with the datos"

reset: ->
	# this is for resetting the database (starting over)
	if typeof console is \undefined
		console = require \console
	# console.log "lalalallala::", @lala
	# console.log "args", &.callee.identity
	# console.log "args", &.callee.this
	# console.log "Mun", @collection.name!
	hamsternipples = @users.get \hamsternipples
	MUNS = {}

	make_mun = ((data) ->
		id = @collection.name!+'/'+data._key
		unless data.uid
			data.uid = hamsternipples._key
		if @collection.exists id
			@collection.update id, data
		else @collection.save data
		#MUNS[data.name] = user
		# user.save
	).bind this
	make_mun {
		_key: '11'
		name: "kenny"
		full_name: "Kenneth Bentley"
	}
	make_mun {
		_key: '1155'
		name: "duralog"
		full_name: "flames of love"
	}
	make_mun {
		_key: '1111'
		name: "heavyk"
		full_name: "mechanic of the sequence"
	}
	make_mun {
		_key: '1234'
		name: "hamsternipples"
		full_name: "nips"
	}

queries:
	mine: """
	FOR d IN Mun
		FILTER d.uid == @uid
		SORT d.d_created DESC
		RETURN d
	"""
	# this belongs in RelationShip bp
	search: """
	TODO
	"""
# verses:
# 	Comments: (refs, query) ->
# 		new Verse refs, {
# 			model: \Comment
# 			tone: (refs, dd) ->
# 				new Tone refs, {
# 					_el: (E) -> E \div c: 'tamaguchi-log col-sm-12 col-lg-6'
# 					fsm:
# 						states:
# 							ready:
# 								render: (E, doc) ->
# 									E \div c: \media-body,
# 										E \h4 c: \media-heading,
# 											doc.render \link
# 											E \small null "commented..."
# 										doc.get \text
# 				}, dd
# 			_el: (E) -> E \div c: 'hidden tamaguchi-log'
# 			schema:
# 				tamaguchi:
# 					type: \ObjectId
# 					hidden: true
# 					required: true
# 				mun:
# 					type: \ObjectId
# 					hidden: true
# 					default: ->
# 						console.log "get the default user"
# 						"5155cd43572b5a715580d060"
# 				title:
# 					label: "Title"
# 					type: \string
# 					onempty: "headline for your log"
# 					required: true
# 					order: 1
# 				desc:
# 					label: "Description"
# 					render: \textarea
# 					type: \string
# 					onempty: "give a brief description of what happened"
# 					order: 2
# 				satisfaction:
# 					label: "How much satisfaction did it give you?"
# 					type: \number
# 					render: \percentbar
# 					min: 0
# 					max: 100
# 					step: 0.1
# 					default: 60
# 					order: 3
# 					# when automating this process, these events always should be non-returning (specifically return if needed)
# 					onrender: !(el) ->
# 						v = 0.6
# 						el.style.background-color = "rgb(#{parseInt (1 - v) * 255},#{parseInt v * 255},0)"
# 					onchange: !(doc, e) ->
# 						v = e.target.value / 100
# 						e.target.style.background-color = "rgb(#{parseInt (1 - v) * 255},#{parseInt v * 255},0)"
# 				color:
# 					label: "Pick a background color:"
# 					type: \string
# 					default: 'ffffff'
# 					render: \colorpicker
# 					order: 4
# 					hidden: true
# 				t1:
# 					type: \date
# 					hidden: true
# 				t2:
# 					type: \date
# 					hidden: true
# 				v1:
# 					type: \number
# 					hidden: true
# 				v2:
# 					type: \number
# 					hidden: true
# 			fsm:
# 				states:
# 					'*':
# 						onenter: ->
# 							while t = close_log.pop!
# 								clearTimeout t

# 					uninitialized:
# 						#onenter: -> @transition \ready
# 						render: -> "Loading Log..."

# 					ready:
# 						render: (E) ->
# 							return [
# 								#E \h3 null, "Log"
# 							]

# 					new:
# 						render: (E) ->
# 							return [
# 								@voice
# 							]

# 					saved:
# 						render: (E) ->
# 							alert = E \div c: 'alert alert-info', "successfully saved.."
# 							setTimeout ~>
# 								alert.addClass \hidden
# 								@transition \log
# 								#close_log.push setTimeout ~>
# 								# @transition \ready
# 								#, 20000
# 							, 2000
# 							return alert

# 					log:
# 						render: (E) ->
# 							console.log "LOGGGING", @rhythm
# 							return [
# 								@rhythm
# 							]
# 		}
# queries:
# 	profile_comments:

phrases:
	img_link: (E, d) ->
		E \a c: <[pull-left mun-link]> href: '/profile/'+@get(\_key),
			E \img c: <[img-thumbnail img-mun]> data: src: 'holder.js/64x64'
			if @get \is_you
				E \div c: \prox-box,
					E \span c: \prox s: 'background-color:\#f22;width:100%'
			else
				E \div c: \prox-box,
					E \span c: \prox s: 'background-color:\#722;width:40%'

	preferences: (E, d) ->
		console.log "welcome to Mun.profile"
		E \div null,
			E \h3, null, @get \name

	comments: (E, d) ->

	profile: (E, d) ->
		Comments = (refs, query = {}) ->
			console.log "rendering Comments"
			close_log = []

		who = @get \name
		id = @get \_id
		E \div c: \row,
			E \div, c: <[col-sm-4 col-lg-3 col-xl-2]>,
				E \div c: <[panel panel-default]>,
					E \div c: \panel-heading,
						E \h3 c: \panel-title, who
					E \div c: \panel-body,
						E \img c: <[img-rounded img-responsive]> data: src: 'holder.js/256x256'
				E \div c: <[panel panel-default]>,
					E \div c: \panel-heading,
						E \h3 c: \panel-title, "actions"
					E \div c: \panel-body,
						E \ul c: <[nav nav-pills nav-stacked]>,
							E \li null,
								E \a href: "/message/#id", "Message"
							E \li null,
								E \a href: "/todo/do/something/for/#{who}", "something else here"
			E \div, c: <[col-sm-8 col-lg-9 col-xl-10]>,
				E \div c: <[panel panel-default]>,
					E \div c: \panel-heading,
						E \h3 c: \panel-title, "#{@get(\full_name)}'s comments"
					E \div c: \panel-body,
						# E \div c: <[alert alert-warning alert-dismissable]>,
						# 	E \button type: \button c: \close data: dismiss: \alert
						# 	E \p null, "this is some introductory text here..."
						# 	E \button type: \button c: <[btn btn-primary]> data: dismiss: \alert, "Ok, got it.."
						# @render \preferences
						# @poetry.Verse.Comments d._key
						console.log "Comments" @, @poetry.Verse #.Comments

						E \div null, "make this a list ... !!!"
						E \div c: \media,
							@render \img_link
							E \div c: \media-body,
								E \h4 c: \media-heading,
									@render \txt_link
									E \small null "commented..."
								"eres tan wapo!"
						#return "TODO: make a wall with comments"
						#TODO: keep track of these alerts

api: (api) ->
	api.get '/search', (req, res) ->
		console.log "we got a search!!"

layout:
	name:
		label: "Name"
		type: \string
		required: true
		onempty: "please type a name for your Mun"
		oninfo: "the name everyone will see"
	full_name:
		label: "Full Name"
		type: \string
		required: true
		default: "an empty full name"
		onempty: "please type a name for your Mun"
		oninfo: "the name everyone will see"
	img:
		label: "Profile Image"
		type: \Image
		default: \lala.jpg
		onempty: "please upload a foto for your Mun"
		oninfo: "the image everyone will see associated with your Mun"
