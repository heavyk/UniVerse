assert = require \assert
Http = require \http
path-to-regexp = require \path-to-regexp

{ Fsm, ToolShed, DaFunk, _, Machina } = require 'MachineShop'
{ StoryBook } = require './StoryBook'
{ ExperienceDB, Perspective, Quest } = require './ExperienceDB'
window.Machina = Machina

Tone =
	'also|initialize': ->
		# get the bp from the universe just like 'Meaning' does
		# then, overlay the voice on top of the meaning (or the verse)
		for k, p of @_bp._blueprint.layout
			if not p.hidden and typeof @parts[k] is \undefined
				@parts[k] = ((type) ->
					(E) -> E \div c: "form-group #{type}"
				)(p.render || p.type.toString!toLowerCase!)

		if @_bp.incantation is \Login
			window.tone_ = @

		@_el.addEventListener "submit", (e) ~>
			e.preventDefault!
			@emit \submit, e
			return false
		if @_is_dirty
			@exec \verify

	eventListeners:
		verified: ->
			debugger
			@debug.todo "TODO: form verification"

	cmds:
		verify: ->
			if @_is_verified
				return true
			@debug.error "verify this for reals..."
			@_is_verified = true
		field_entry: (part, sv) !->
			voice = @
			if not _part = @_parts[part]
				throw new Error "trying to render a part('#part') but it isn't defined..."
			E = cE
			if not sv.type
				debugger
			type = sv.type.toString!toLowerCase! #this seems silly to be doing every time we render the form. instead, do it once when compiling the bp
			el = switch sv.render
			| \glyphicon =>
				icons = <[ glass music search envelope heart star star-empty user film th-large th th-list ok remove zoom-in zoom-out off signal cog trash home file time road download-alt download upload inbox play-circle repeat refresh list-alt lock flag headphones volume-off volume-down volume-up qrcode barcode tag tags poetry bookmark print camera font bold italic text-height text-width align-left align-center align-right align-justify list indent-left indent-right facetime-video picture pencil map-marker adjust tint edit share check move step-backward fast-backward backward play pause stop forward fast-forward step-forward eject chevron-left chevron-right plus-sign minus-sign remove-sign ok-sign question-sign info-sign screenshot remove-circle ok-circle ban-circle arrow-left arrow-right arrow-up arrow-down share-alt resize-full resize-small plus minus asterisk exclamation-sign gift leaf fire eye-open eye-close warning-sign plane calendar random comment magnet chevron-up chevron-down retweet shopping-cart folder-close folder-open resize-vertical resize-horizontal hdd bullhorn bell certificate thumbs-up thumbs-down hand-right hand-left hand-up hand-down circle-arrow-right circle-arrow-left circle-arrow-up circle-arrow-down globe wrench tasks filter briefcase fullscreen dashboard paperclip heart-empty link phone pushpin euro usd gbp sort sort-by-alphabet sort-by-alphabet-alt sort-by-order sort-by-order-alt sort-by-attributes sort-by-attributes-alt unchecked expand collapse collapse-top ]>
				E \div c: "form-group #{sv.render or type}",
					E \label, c: 'control-label col-lg-3 pull-left' for: 'input_'+part, (sv.label or part)
					E \div c: 'col-lg-3 col-3',
						iin = E \input,
							c: \form-control
							type: \text
							value: (voice.get(part) or sv.default or '')
							id: 'input_'+part
							placeholder: (sv.onempty or '')
							onchange: (e) ~> @set part, if typeof sv.onchange is \function and typeof (val = sv.onchange.call(@, @_xp, e)) isnt \undefined => val else e.target.value
					->
						b = E \button c: 'btn btn-default',
							E \span c: 'glyphicon glyphicon-cog'
						pop = window.$ b .popover {
							toggle: \popover
							content: ->
								#for icon in icons
								_.map icons, (icon) ->
									E \button,
										c: "btn btn-mini #{if icon is iin.value => 'btn-danger' else 'btn-primary'}"
										onclick: ->
											@set part, iin.value = icon
											pop.popover 'toggle'
										E \span c: "glyphicon glyphicon-#{icon}"
							title: "choose your icon"
						}
					sv.onrender
					if sv.oninfo => E \span c: \help-block, sv.oninfo
			| \colorpicker =>
				E \div c: "form-group #{sv.render or type}",
					E \label c: 'control-label col-lg-3 pull-left' for: 'input_'+part, (sv.label or part)
					E \div c: 'col-lg-3 col-3',
						iin = E \input,
							c: \form-control
							type: \text
							value: (voice.get(part) or sv.default or '')
							id: 'input_'+part
							placeholder: (sv.onempty or '')
							onchange: (e) ~> @set part, if typeof sv.onchange is \function and typeof (val = sv.onchange.call(@, @_xp, e)) isnt \undefined => val else e.target.value
					~>
						b = E \button c: 'btn btn-default pull-left',
							E \span c: 'glyphicon glyphicon-cog'
						cp = new window.ColorPicker
						cp.on \change, (e) ~>
							p = (v) ->
								v = v.toString 16
								if v.length < 2 => '0'+v else v
							@set part, iin.value = "#{p e.r}#{p e.g}#{p e.b}"
						pop = window.$ b .popover {
							toggle: \popover
							content: -> cp.el
							title: "choose your color"
						}
					sv.onrender
					if sv.oninfo => E \span c: \help-block, sv.oninfo
			| otherwise =>
				changed_val = (e) ~>
					voice.set part, if typeof sv.onchange is \function and typeof (val = sv.onchange.call(voice, voice._xp, e)) isnt \undefined => val else e.target.value
				switch type
				| \string =>
					E \div c: "form-group #{sv.render or type}",
						E \label c: 'control-label col-lg-3' for: 'input_'+part, (sv.label or part)
						if sv.render is \textarea
							E \textarea,
								c: \form-control
								id: 'input_'+part
								placeholder: (sv.onempty or '')
								onchange: changed_val
								onkeyup: _.debounce changed_val, 5000
								(voice.get(part) or sv.default or '')
								sv.onrender
						else
							E \input,
								c: \form-control
								type: if sv.render is \password then \password else \text
								value: (voice.get(part) or sv.default or '')
								id: 'input_'+part
								placeholder: (sv.onempty or '')
								onchange: ->
									changed_val ...
									voice.save!
								onkeyup: _.debounce changed_val, 2000
								sv.onrender
						if sv.oninfo => E \span c: \help-block, sv.oninfo
				| \number =>
					E \div c: "form-group #{sv.render or type}",
						E \label c: 'control-label col-lg-3' for: 'input_'+part, (sv.label or part)
						E \div c: \col-lg-8, ->
							if Array.isArray sv.enum
								E \div c: \btn-group data: toggle: \buttons,
									for e, i in sv.enum
										E \label c: 'btn btn-primary',
											E \input type: \radio name: part, id: part+''+i
											e
							else
								E \input,
									c: \form-control
									type: if sv.render is \spinner => \number else \range
									value: (voice.get(part) or sv.default.toString! or 0)
									min: sv.min
									max: sv.max
									step: sv.step
									id: 'input_'+part
									placeholder: (sv.onempty or '')
									onchange: (e) ~> @set part, if typeof sv.onchange is \function and typeof (val = sv.onchange.call(@, @_xp, e)) isnt \undefined => val else e.target.value
									sv.onrender
						if sv.oninfo => E \span c: \help-block, sv.oninfo
				| \date =>
					E \div c: "form-group #{sv.render or type}",
						E \label c: 'control-label col-lg-3' for: 'input_'+part, (sv.label or part)
						E \div c: \col-lg-8,
							E \input,
								c: \form-control
								type: \text
								id: 'input_'+part
								placeholder: (sv.onempty or '')
								onchange: (e) ~>
									@set part, new Date e.target.value
								sv.onrender
							if sv.oninfo => E \span c: \help-block, sv.oninfo
				| \boolean =>
					E \div c: "form-group #{sv.render or type}",
						E \label c: \checkbox,
							E \input type: \checkbox, checked: (voice.get(part) or sv.default or false)
							sv.label
							sv.onrender
						if sv.oninfo => E \span c: \help-block, contentEditable: true, sv.oninfo
				| otherwise =>
					E \div c: 'alert alert-error', "unknown schema type: "+ sv.type

			E.rC _part, el
			return el

	states:
		uninitialized:
			onenter: ->
				# I'm not 100% convinced that this is necessary
				schema = []
				_.each @_renderers, (field) ~>
					obj = @_bp._blueprint.layout[field]
					unless obj.hidden
						o = {}
						for k, v of obj
							o[k] = v
						o.field = field
						schema.push o
				@_schema = schema

				if @goto
					@transition @goto

		new:
			onenter: ->
				if not @states.new.renderers
					@states.new.renderers = _.keys @_bp._blueprint.layout


Timing =
	'also|initialize': ->
		@debug "welcome to an extension of Time"
		if @quests
			DaFunk.extend @quests, @_bp._blueprint.quests
		else
			@quests = @_bp._blueprint.quests

	# gonna write that bitch a sonnet. bitches love sonnets -shakespeare
	cmds:
		more_quest: ->
			if not @quest
				@debug.error "not questing anything!"
				return
			if not @quest._id
				@debug.error "nothing more to quest!"
				return
			@quest.exec \more_quest


		quest: (key, opts) ->
			if @quest
				@debug.error "this is probably an error because the event listeners need to be removed from the old quest and we neeed to garbage collect ot correctly"
			@quest = q = new Quest @_bp, key, opts
			verse = @
			q.on \* !->
				verse.emit ...
			@transition key

# this class gives "meaning" to the 'Word' (data) by spawning it with the encantador
# hehe, it's a Word Document ... get it?
# Meaning is a Fixed sign (think astrology)

# a Voice (Cardinal) extends Meaning implements Tone
# a Verse (Mutable) extends Meaning implements Timing
# a Word or Poem (Fixed) extends Meaning implements Definition


class Meaning extends Fsm
	var window,	cE,	aC,	$
	(@book, @_bp, key, opts) ->
		self = @
		self._is_dirty = false
		self._dirty_vals = {}
		self._is_new = true
		client_key = Math.random!toString 32 .substr 2
		self.refs = book.refs
		if typeof key is \object
			self._xp = key
			self._xp._k = client_key
			self._is_dirty = true
			key = key._key
			# @exec \verify

		if typeof key is \string
			self.id = id = if _bp.type is \Mutable
				'quest:'+key
			else
				_bp.incantation+'/'+key
		else
			self.id = _bp.incantation+'/'+client_key

		window := book.refs.window
		cE := window.cE
		aC := window.aC
		@_cE = ->
			cE.apply self, arguments
		@_cE.$ = $ := window.$
		@_cE.rC = window.rC
		@poetry = book.poetry
		@memory = book.memory[_bp.incantation]
		@_parts = {}
		if typeof opts is \object
			if typeof opts.el isnt \undefined
				self._el = opts.el
				delete opts.el
			DaFunk.extend self, opts

		switch _bp.type
		| \Cardinal =>
			if @_xp
				@_xp_tpl = {} <<< @_xp
				@_xp._k = client_key
			if typeof self._el isnt \object
				self._el = \form
		| \Mutable =>
			if key
				@initialState = key

		if not @_xp
			@_xp = {_k: client_key}

		if typeof self._el is \undefined then self._el = \div
		if typeof self._el is \string
			el_opts = if _bp.encantador then {c: _bp.encantador+' '+_bp.incantation+' container-fluid'} else {}
			self._el = cE self._el, el_opts
		else if typeof self._el is \function
			self._el = self._el.call this, cE
		else if typeof self._el isnt \object
			throw new Error "I dunno what to do! "+typeof self._el
		self._el.dataset.blueprint = _bp.fqvn
		self._el._machina = self

		if _bp.type is \Fixed and id
			@_loading = key

		if not @parts
			@parts = {}

		super "#{_bp.encantador}:#{_bp.incantation}(#{if key => key else if _bp.type is \Fixed then \new else _bp.type })"

		if not @id
			debugger

		switch _bp.type
		| \Mutable =>
			if key
				self.exec \quest, key, opts#, self._xp
		| \Abstract =>
			@debug.error "type is changed to significance"
			if key
				self.transition key
		| \Cardinal =>
			@debug.todo "we need cardinal types..."
			if typeof key is \string
				@debug.todo "load up the exp using this id"
			fallthrough
		| \Fixed => fallthrough
		| otherwise =>
			if id and _bp._blueprint.presence isnt \Abstract
				self.exec \load key
	render: ->
		"this is #{@namespace}"
	router: (path, is_back) ->
		window_href = window.location.href + ''
		window_href_base = window_href.substr 0, window_href.lastIndexOf '/'
		proto = cur_proto
		url_poem = cur_url_poem
		if ~path.indexOf window_href_base
			path = path.substr window_href_base.length
		else
			if ~path.indexOf "://"
				proto = path.split '://'
				if proto.length > 1
					[proto, path] = proto
				else
					proto = \http
					path = proto.0
			#[url_poem, path] = path.split '/'
			if (i = path.indexOf '/') > 0
				url_poem = path.substr 0, i
				path = path.substr i
			else if i is 0
				url_poem = cur_url_poem
				path = path
			else
				url_poem = path
				path = '/'

		querystring = ''
		if i = ~path.indexOf '?'
			querystring = path.slice i + 1
			path = path.slice 0, i

		@debug "proto:#{proto} url_poem:#{url_poem} path:#{path}"
		#Poem._[name].transition path, {path, proto, poem: url_poem}

		switch path
		| \/disconnected =>
			@debug.todo "TODO: show disconnected thing..."
			refs.poem.emit \disconnected
			aC null, lala = cE \div c: 'modal-backdrop fade in'
			window.fsm.on \ready ->
				$ lala .remove!

	_render: -> @_el

	action_up: (path, evt) ->
		el = @_el.parentNode
		do
			if machina = el._machina
				process.nextTick ->
					if machina.states[machina.state][path]
						machina.exec path, evt
					else
						machina.transition path
				return machina
		while el = el.parentNode
		return null

	exp: (no_default) ->
		if no_default
			d = _.cloneDeep @_xp
			_.each @_bp.layout, (!(v, k) ->
				if v.required
					d[k] = @get k
			), this
		else
			d = {}
			_.each @_bp.layout, (!(v, k) ->
				if typeof (v = @get k, no_default) isnt \undefined
					d[k] = v
			), this
		return d
	get: (path, no_default) ->
		if @__loading
			return "loadi___ng..."
		if typeof (v = if ~path.indexOf '.' then get_path(@_xp, path) else @_xp[path]) is \undefined and not no_default and typeof (s = @_bp.layout[path]) isnt \undefined
			if typeof (v = s.default) is \function
				v = v.call this, s
		return v
	set: (path, val) ->
		@debug "set: %s %s %s", path, val, DaFunk.stringify @_xp
		assert @_bp._blueprint.type isnt \Abstract
		# TODO: validate
		# TODO: check for getters/setters
		# TODO: add read-only params (kinda silly though, I know... really only useful for verification)
		if path is \_rev or path is \_key or path is \_id
			@debug.error "'_rev', '_key' and '_id' are immutable properties. you have a bug somewhere..."
			return @_xp[path]

		prev_val = if ~path.indexOf '.'
			get_path(@_xp, path, val)
		else @_xp[path]

		unless _.isEqual val, prev_val
			@_is_dirty = true
			if ~path.indexOf '.'
				set_path(@_xp, path, val)
			else
				@_xp[path] := val
			@_dirty_vals[path] := val
			@emit \set path, val
			return val

	forget: (cb) ->
		@debug "forgetting %s", @key
		if @_is_new
			@exec \make_new
			if typeof cb is \function => cb.call this, null, this
		else
			@memory.forget @key, cb

	save: (cb) ->
		if @_bp._blueprint.presence is \Abstract
			return
		if @_is_new
			d = @exp true
			if d._rev
				@debug.error "TODO: you have a bug somewhere... you shouldn't have a _rev ever!!"
			@memory.create @_xp, (err, xp) ~>
				if err
					@emit \error err
				else
					@emit \created, xp
				if typeof cb is \function
					cb ...
		else if @_is_dirty
			@debug "saving dirty experience %s <= %s", DaFunk.stringify(@_xp), DaFunk.stringify(@_dirty_vals)
			@memory.patch @key, @_dirty_vals, (err, xp) ~>
				if err
					@emit \error err
				else
					@emit \patched, xp
				if typeof cb is \function
					cb ...
		else cb.call @, void, @_xp

	eventListeners:
		transition: (evt) !->
			set_path = 1
			self = @
			cE = self._cE
			aC = self.refs.window.aC
			path = evt.toState
			from_state = evt.fromState
			cur_state = @states[path]
			part_order = if cur_state.order => cur_state.order else @order
			parts = if cur_state.parts => cur_state.parts else @parts
			if typeof part_order is \string
				# OPTIMIZE! - this is kinda sucky. since this function is called so often, it probably can be optimized...
				part_order = [part_order]
			else if not part_order
				part_order = [\render]
				if not parts
					@_parts.render = @_el

			if not Array.isArray part_order
				throw new Error "blueprint '#{@_bp.fqvn}' does not specify 'order' for its parts: #{Object.keys @parts} - or at least it's not an array..."
			if typeof parts isnt \object
				throw new Error "you have not defined this blueprint's parts or the state's parts..."

			if part_order
				pi = 0
				for k, i in part_order
					# I'll admit, this is kinda funky logic here... there's no specific reason for it, at all...
					part = @_parts[k]
					if not part and (typeof (p = parts[k]) is \function or typeof (p = @parts[k]) is \function)
						@_parts[k] = part = p.call @, cE
					if part
						if (wrong_one = @_el.childNodes[pi]) isnt part
							@_el.removeChild wrong_one if wrong_one
							@_el.removeChild part if part.parentNode is @_el
							aC @_el, part, pi
						pi++

				part = @_el.childNodes[part_order.length]
				while part and part = part.nextSibling
					@_el.removeChild part


			do_render = (renderer) ->
				if typeof self.state isnt \undefined
					if @cmds.field_entry and rr = @_bp.layout[renderer]
						ret = @exec \field_entry, renderer, rr
					else if typeof (r = self.states[if typeof from_state isnt \undefined and self._loading => \loading else path][renderer]) is \function
						data = evt.args.0
						if (typeof self._parts is \undefined and el = self._el) or (typeof self._parts is \object and el = self._parts[renderer])
							rr = r.call(self, cE, data)
							rC.call @, el, rr
						else set_path--
						if path.0 is '/'
							if typeof from_state is \string and from_state.0 isnt '/'
								data = {path: path, mun: UniVerse.mun, poem: UniVerse.poem}
								self.replace_path data, "some title"
							else if set_path and data
								UniVerse.poem = data.poem
								self.push_path data, data.title + ""
			if part_order
				for p in part_order =>
					do_render.call this, p
			else
				do_render.call this, \render

		added: (el) ->
			# this will be to keep ref counts of the element...
		removed: (el) ->
			# TODO: when replacing the DOM element in the render function, emit this event
			#    do a dom walk on the removed node and see if _machina is defined. if it is, emit this
			throw new Error "wtf dude. not yet implemented"
		destroy: ->
			@debug "destroying..."
			# this is a first attempt to keep things clean memorywise...
			el = @_el
			if el
				el._machina = null
				if el.parentNode
					$ el .remove!

		invalidstate: (e) !->
			# show todo
			# check for states with variables
			path = e.attemptedState
			poem = @
			if path.0 is '/' and poem._regex_routes
				_.each poem._regex_routes, (regex, p) ->
					if ~path.indexOf regex.at_least
						m = path.match regex
						if m
							m.shift! # knock off first
							params = {}
							_.each m, (p, i) -> params[regex.keys[i].name] = p
							url = e.args.0
							url.params = params
							poem.transition p, url
							return false
			#@transition \invalidstate
			@debug.error "oh shit we're invalid (#{e.state} -> #{e.attemptedState}) %s", @_bp.encantador
			@debug.todo "moved to invalid state... if in debug mode, try to load the bluprint so you get to make the state right there..."
			debugger

	'memory:found': (xp) !->
		@_loading = null
		@key = key = xp._key
		@id = xp._id
		@_is_new = false
		@_is_new = !xp._rev
		if @_is_dirty
			@_is_dirty = false
			@_dirty_vals = {}
		#TODO: change its namespace?
		@memory.on "changed:#key" _.bind @'memory:changed', @
		@memory.on "deleted:#key" _.bind @'memory:deleted', @
		@_xp = xp
		if @state
			if @state is @initialState
				if typeof @goto is \string
					@transition @goto
				else
					@transition \ready
			else
				@emit \transition {fromState: @state, toState: @state, args:[]}
		else
			@transition \uninitialized
		# should be something more like this:
		# if @goto
		# 	@transition @goto
		# else
		# 	# re-render the element
		# 	@render!
		# XXX: fixme this is probably broken
		@memory.off "!found:#key", _.bind @'memory:!found', @
		@memory.off "found:#key", _.bind @'memory:found', @

	'memory:changed': (xp) !->
		# this should probably do something fancy. idea is:
		# 1. re-render into a dummy element.
		# 2. just swap out the fields which have changed
		# 3. maybe when swapping out the fields, I can give it some sort of effect
		# 4. this also could be cool for the future where I do some sort of action-replay deal
		# 5. it'd also be cool to save the _rev with a timestamp so I can do a page replay
		# check if key has changed?
		debugger
		@exec \changed xp, old_xp, diff

	'memory:deleted': !->
		@transition \deleted
		# maybe this should do something like:
		# 1. render a deleted element with an undo button.
		# 2. after a certain time passes (and no undo is pressed), it removes itself from the dom
		# 3. if undo is pressed, it'll transition to the undo state, and try to restore itself

	'memory:!found': !->
		@_loading = null
		@exec \make_new
		debugger
		@transition \not_found

	'memory:error': (err) !->
		@_loading = null # is this necessary?
		# @_error = err
		@transition if err.code => err.code else \error

	cmds:
		make_new: (erase_vals) ->
			if erase_vals
				@_xp = DaFunk.extend {}, @_xp_tpl
			else
				@_xp = DaFunk.extend {}, @_xp
				# because extend removes all keys starting with _, these shouldn't exist
				# delete @_xp._key
				# delete @_xp._id
				# delete @_xp._rev
			@_is_new = true
			# TODO: if not erase_vals, then determine the diff here
			@_dirty_vals = {}
			@_is_dirty = false

		load: (key, cb) ->
			if typeof key is \function
				cb = key
				key = @key
			incantation = @_bp.incantation
			@debug "load: %s", key
			if typeof key is \number
				key = @_bp.incantation + '/' + key
			if typeof key is \string
				# if not ~key.indexOf '/'
				# 	key = @_bp.incantation + '/' + key
				if ~key.indexOf '/'
					debugger
				# if ~@id.indexOf \Affinaty
				# 	debugger
				# if we're already loading one, then go ahead and abort the load, then load again
				#TODO: add some sort of timeout here for long loadings.
				# if experience = @book.library.experiences[key]
				# memory = @book.memory[incantation]
				@memory.on "error:#key" _.bind @'memory:error', @

				if xp = @memory.get key
					# @_xp = experience
					@'memory:found' xp
					if typeof cb is \function
						debugger
						cb_state = cb void, xp
					@transition if typeof cb_state is \string and @states[cb_state] then cb_state else if @state isnt @initialState then @state else \ready
				else
					# self = @
					@memory.on "found:#key", ~>
						@'memory:found' ...
					@memory.on "!found:#key" ~>
						@'memory:!found' ...
					@_loading = key
			else
				throw new Error "we don't know what kind of key this is: #{id} ... unable to load"
				# if typeof id is \object

				@debug.todo "check to see if it has a key"
				@debug.todo "@exec"

	states:
		uninitialized:
			onenter: ->

		loading:
			render: (E) ->
				E \div c: \loading, "loading..."

		new:
			onenter: ->

			render: (E) ->
				"TODO: new #{@namespace}... add the voice"


			validate: ->


		edit:
			onenter: ->

			render: (E) ->


		ready:
			onenter: ->

			render: (E) ->
				E \h4 null "Meaning::ready", "(this is a bug because it stould initialize in the uninitialized state)"

			validate: ->
				@debug.error "TODO: @validate state??"
				_.each @_bp.layout, (v, k) ->

		invalidstate:
			onenter: (e) ->

			render: (E) ->
				E \div c: \todo data: todo: "new_page_editor", "invalid state: TODO: make a new page editor"
				#TODO: make it search for the data after loading the element
				#TODO: make an external interface for the todos

	path: '/'
	replace_path: (data, title) ~>
		@debug "replacing path %s with title '%s'", data.path, title
		@debug.todo "if history is an array, make sure the ... wait, the latest, is the current one, right?"
		@path = data.path
		@path.data = data
		if title
			@title = title
		# window.history.replaceState data, title, data.path
	push_path: (data, title) ~>
		@debug "pushing path %s with title '%s'", data.path, title
		if not @history
			@history = []
		@history.push @title
		@replace_path data, title
		# window.history.pushState data, title+Math.random!toString(32).slice(2), data.path

Magnetism =
	emit: ->
		debugger

embody_bp = (bp) ->
	unless bp
		throw new Error "can't extend empty bp #bp"
	embody_bps = []
	embody_bp_ = []
	# this needs to be recursive!

	# why sdo I do this?
	embodies = if bp.encantador is bp.incantation then bp.embodies else [ bp.incantation ]
	if typeof embodies is \string
		embodies = [embodies]
	if _.isArray embodies and embodies.length
		while embodied_bp = embodies.shift!
			bpz = get_bp bp.encantador, embodied_bp
			if (eb = bpz.embodies)
				for incantation in (if typeof eb is \string => [eb] else eb)
					if not ~embody_bp_.indexOf incantation
						embodies.unshift incantation
				embody_bps.push bpz
				embody_bp_.push bpz.incantation


		embody_bps.unshift get_bp bp.encantador, bp.encantador
		embody_bp_.unshift bp.encantador
		embody_bps.unshift bp
		embody_bp_.unshift bp.incantation
		Da_Funk.embody.apply this, embody_bps
	else bp

get_bp = (encantador, incantation, version) ->
	if typeof encantador is \object
		{encantador, incantation, version} = encantador
	if ~(idx = incantation.indexOf '@')
		version = incantation.substr idx+1
		incantation = incantation.substr 0, idx
	if version and version isnt \latest
		#TODO: if we have conditional semver stuff (ex: >=0.1.0) do a custom query
		bp = Blueprint_collection.byExample {encantador, incantation, version}
	else
		bp_query.bind \encantador, encantador
		bp_query.bind \incantation, incantation
		bp = bp_query.execute!

	return bp.next!

class Blueprint extends Fsm
	(@refs, opts) ->
		if typeof opts is \object
			if opts.encantador
				@encantador = opts.encantador
			if opts.incantation
				@incantation = opts.incantation
			if opts.version
				@version = opts.version
		else if typeof opts is \string
			throw new Error "TODO: fqvn parsing"
		else
			throw new Error "we don't know whot to do with your blueprint, sorry"

		if typeof refs isnt \object
			@debug.error "you need to pass a 'refs' object to the StoryBook"
		else if not refs.book
			throw new Error "you have to reference a PoetryBook for a blueprint because we save the imbuement into the poetry book, obviously"

		@_blueprint = opts

		unless @incantation
			@debug.error "you need a incantation for your blueprint!"
			throw new Error "you need a incantation for your blueprint!"

		unless @encantador
			@debug.error "you need a encantador for your blueprint!"
			throw new Error "you need a encantador for your blueprint!"

		if not @version or @version is \*
			@version = \latest

		super "Blueprint(#{@fqvn = @encantador+':'+@incantation+'@'+@version})"

	imbue: (book, cb) !->
		assert book instanceof StoryBook
		if @state is \ready
			var blueprint_inst
			library = @refs.library #.poetry
			_bp = @
			_deps = @_deps
			_blueprint = @_blueprint
			# I'm not terribly happy with this... I really want to sort out the library and the databases...
			# for now though, this is good enough
			if typeof book.memory[@incantation] is \undefined
				book.memory[@incantation] = new ExperienceDB @incantation
			#OPTIMIZE: this could be potentially costly to call DaFunk.extend ... I dunno...
			#OPTIMIZE: perhaps instead of eval, we should use new Function
			if typeof book.poetry[@encantador] is \undefined
				eval """
				(function(){
					var #{@encantador} = blueprint_inst = (function(superclass){
						var prototype = extend$((import$(#{@encantador}, superclass).displayName = '#{@encantador}', #{@encantador}), superclass).prototype, constructor = #{@encantador};
						function #{@encantador} (book, _bp, key, opts) {
							if(!(this instanceof #{@encantador})) return new #{@encantador}(key, opts);
							//#{if @type is \Cardinal then 'DaFunk.extend(this, DefineTone);' else ''}
							//#{if @type is \Mutable then 'DaFunk.extend(this, DefineTiming);' else ''}
							//#{if @type is \Fixed then 'DaFunk.extend(this, DefineSymbolic);' else ''}
							#{@encantador}.superclass.call(this, book, _bp, key, opts);
						}
						DaFunk.extend(prototype, _blueprint.machina);
						return #{@encantador};
					}(Meaning));
					DaFunk.extend(#{@encantador}, Magnetism);
					book.poetry['#{@encantador}'] = #{@encantador};
				}())
				"""


			if @encantador isnt @incantation
				eval """
				(function(){
					var #{@incantation} = blueprint_inst = (function(superclass){
						var embodies = _deps.embodies, prototype = extend$((import$(#{@encantador}, superclass).displayName = '#{@encantador}', #{@encantador}), superclass).prototype, constructor = #{@encantador};
						function #{@encantador} (key, opts) {
							if(!(this instanceof #{@encantador})) return new #{@encantador}(key, opts);
							#{if @type is \Cardinal then 'DaFunk.extend(this, Tone);\n' else ''}
							#{if @type is \Mutable then 'DaFunk.extend(this, Timing);\n' else ''}
							//#{if @type is \Fixed then 'DaFunk.extend(this, Symbolic);\n' else ''}
							#{@encantador}.superclass.call(this, book, _bp, key, opts);
						}
						/*
						if(embodies) {
							for(var i in _deps.embodies) {
								DaFunk.extend(prototype, book.poetry['#{@encantador}'].prototype);
							}
						}
						*/
						DaFunk.extend(prototype, _blueprint.machina);
						return #{@encantador};
					}(book.poetry['#{@encantador}']));
					//book.poetry['#{@encantador}']['#{@incantation}'] = #{@incantation};
					//book.poetry['#{@encantador}']['#{@incantation}@#{@version}'] = #{@incantation};
					book.add_poetry('#{@encantador}', '#{@incantation}', '#{@version}', #{@incantation});
				}())
				"""
			@debug "_deps", @_deps

			if (deps = Object.keys @_deps) and deps.length
				for d in deps
					bp = @_deps[d]
					if typeof bp is \object and (not book.poetry[@encantador] or not book.poetry[@encantador][@incantation])
						bp.imbue book
			if typeof cb is \function
				# debugger
				cb null, blueprint_inst, this
				return void
		else if typeof cb is \function
			# debugger
			@once \state:new !~>
				err = new Error "blueprint cannot be located so we're assuming it's new for now"
				err.code = \ENOOB
				cb err, null, this
			@once \state:error !~>
				err = new Error "blueprint has some sort of error"
				err.code = \ENOENT
				cb err, null, this
			@once \state:ready !~>
				imbued = @imbue book
				# debugger
				cb null, imbued, this
		else
			@debug.error "you can't imbue a blueprint that's not yet ready!: #{@fqvn}"
			# @debug "not ready!!" "encantador", @encantador, "incantation", @incantation
		return blueprint_inst

	states:
		uninitialized:
			onenter: ->
				process_bp = ~>
					if not bp = @_blueprint
						debugger
						return
					@type = if bp.type then bp.type else
						switch bp.encantador
						| \Poem \Word => \Fixed
						| \Verse => \Mutable
						| \Voice => \Cardinal

					@layout = bp.layout || {}
					@_deps = {}
					_deps = DaFunk.embody {}, bp.poetry
					@debug "deps", _deps
					long_incantation = @fqvn
					embodies = bp.embodies
					if typeof embodies is \string
						embodies = [embodies]
					@_deps.embodies = embodies
					UniVerse = @refs.UniVerse
					unless book = @refs.book
						debugger
					task = @task "get deps for #{@fqvn}"

					if @encantador isnt @incantation
						task.push "getting encantador: #{@encantador}" (done) ->
							encantador = incantation = @encantador
							version = \latest
							if ~(idx = incantation.indexOf '@')
								version = incantation.substr idx+1
								encantador = incantation = incantation.substr 0, idx
							UniVerse.library.exec \fetch {encantador, incantation, version}, @refs.book, (err, bp) ~>
								@debug "fetched... %s:%s", encantador, incantation
								@_deps.encantador = bp
								# bp.once \state:ready ~> done!
								done!

					if embodies
						_.each embodies, (incantation, ii) ->
							task.push "getting embodied: #{incantation}" (done) ->
								unless incantation
									debugger
								encantador = @encantador
								version = \latest
								if ~(idx = incantation.indexOf '@')
									version = incantation.substr idx+1
									incantation := incantation.substr 0, idx
								UniVerse.library.exec \fetch {encantador, incantation, version}, @refs.book, (err, bp) ~>
									@_deps.embodies[ii] = bp
									# bp.once_initialized ~> done!
									done!

					_.each _deps, (deps, encantador) ~>
						_.each deps, (version, incantation) ~>
							@debug "getting element: #{encantador}:#{incantation}@#{version}"
							task.push "getting element: #{encantador}:#{incantation}@#{version}" (done) ->
								UniVerse.library.exec \fetch {encantador, incantation, version}, @refs.book, (err, bp) ~>
									@debug "got element: #{encantador}:#{incantation}@#{version}"
									console.log "got element: #{encantador}:#{incantation}@#{version}", deps, task
									@_deps[bp.fqvn] = bp
									done!

					task.end (err, res) ~>
						@transitionSoon \ready
				req = Http.get {
					path: "/bp/#{@encantador}/#{@incantation}#{if @version and @version isnt \latest => '?version=' + @version else ''}"
				}, (res) !~>
					data = ''
					res.on \error (err) ->
						@debug.error "we've got an error!!", err

					res.on \data (buf) ->
						data += buf

					res.on \end ~>
						if res.statusCode is 200
							@_blueprint = DaFunk.objectify data, {require: @refs.book.refs.require}, {name: @namespace}
							if @version is \latest
								@version = @_blueprint.version
								@fqvn = @encantador+':'+@incantation+'@'+@version
								@refs.library.blueprints[@fqvn] = @
							if typeof @refs.book._[@encantador] isnt \object
								@refs.book._[@encantador] = {}
							if typeof @refs.book._[@encantador][@version] isnt \object
								@refs.book._[@encantador][@version] = {}
							process_bp!
						else if res.statusCode is 204
							@transition \new
						else
							@transition \error

		ready:
			onenter: ->
				console.log "we are ready @ #{@namespace}"
			verify: (path, val) ->
				#TODO: add path splitting by '.'

		error:
			onenter: ->
				@debug.error "you have tried to load a blueprint which wasn't able to be fetched", @incantation

		new:
			onenter: ->
				@debug.todo "nice you don't know this bp yet, so now is the time to make it - make bp creation interface"


export Meaning
export Blueprint