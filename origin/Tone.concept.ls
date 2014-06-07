suggests: \Tone
improves:
	'extend.initialize': ->
		console.log "load up the voice that we want here... it'll have its own 'look'"
		# get the bp from the universe just like 'Meaning' does
		# then, overlay the voice on top of the meaning (or the verse)
		for k, p of @_bp._blueprint.layout
			# debugger
			if not p.hidden and typeof @parts[k] is \undefined
				@parts[k] = ((type) ->
					(E) -> E \div c: "form-group #{type}"
				)(p.render || p.type.toString!toLowerCase!)

		if @_bp.incantation is \Login
			# debugger
			window.tone_ = @

		# debugger
		@_el.addEventListener "submit", (e) ~>
			e.preventDefault!
			@emit \submit, e
			return false
		if @_is_dirty
			# debugger
			@exec \verify

	eventListeners:
		verified: ->
			debugger
			console.log "TODO: form verification"

		executed: (evt) ->
			# if evt.type is \field_entry
			# 	aC @_el, evt.ret

		# transition: (evt) ->
		# 	console.log "transition..."
		# 	cur_state = @states[evt.toState]
		# 	render_order = cur_state.order || @order
		# 	console.log "custom order:", render_order
		# 	lala = @_el
		# 	while el = lala.firstChild
		# 		lala.removeChild el
		# 	if not render_order
		# 		render_order = \render
		# 	if render_order
		# 		do_render = (field) ~>
		# 			if typeof field is \string
		# 				if rr = cur_state[field]
		# 					aC @_el, rr.call @, cE
		# 				else if rr = @_bp.layout[field]
		# 					if not rr.field
		# 						rr.field = field
		# 					ret = @exec field, \field_entry rr
		# 					# debugger
		# 			# else
		# 			# 	debugger
		# 		if typeof render_order is \string
		# 			do_render render_order

		# 		_.each render_order, do_render
		# 	@debug "transitioning: TONE %s -> %s", evt.fromState, @state

		# 	# debugger


	cmds:
		verify: ->
			if @_is_verified
				return true
			@debug.error "verify this for reals..."
			@_is_verified = true
			# debugger
		field_entry: (part, sv) !->
			voice = @
			if not _part = @_parts[part]
				throw new Error "trying to render a part('#part') but it isn't defined..."
			# sv = @_bp.layout
			# this needs some sort of abstraction to keep track of the values
			E = cE
			#console.log "field_entry", sv, part
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
											console.log "selected", icon
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
							if iin.value.length < 6 then console.log "error:", e
						pop = window.$ b .popover {
							toggle: \popover
							content: -> cp.el
							title: "choose your color"
						}
					sv.onrender
					if sv.oninfo => E \span c: \help-block, sv.oninfo
			| otherwise =>
				#if r = coolrenders[sv.render] and r!
				#else
				changed_val = (e) ~>
					console.log "onchange", if typeof sv.onchange is \function and typeof (val = sv.onchange.call(voice, voice._xp, e)) isnt \undefined => val else e.target.value
					# _.debounce
					voice.set part, if typeof sv.onchange is \function and typeof (val = sv.onchange.call(voice, voice._xp, e)) isnt \undefined => val else e.target.value
				switch type
				| \string =>
					E \div c: "form-group #{sv.render or type}",
						E \label c: 'control-label col-lg-3' for: 'input_'+part, (sv.label or part)
						# E \div c: \col-lg-8,
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
									# debugger
									console.log "gonna save..."
									changed_val ...
									voice.save!
								onkeyup: _.debounce changed_val, 2000
								sv.onrender
						if sv.oninfo => E \span c: \help-block, sv.oninfo
				| \number =>
					console.log "enum:", sv.enum
					# if sv.enum => debugger

					E \div c: "form-group #{sv.render or type}",
						E \label c: 'control-label col-lg-3' for: 'input_'+part, (sv.label or part)
						E \div c: \col-lg-8, ->
							if Array.isArray sv.enum
								# debugger
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
									#console.log "input changed", part, e.target.value, e.target
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

			# return E \form,
			# 	c: 'form-horizontal'
			# 	onsubmit: (e) ->
			# 		e.preventDefault!
			# 		return false
			# 	#E \legend, null,
			# 	#	"new "+@model.name
			# 	!->
			# 		if opts.tone
			# 			refs2 = _.clone refs
			# 			refs2.cE = (type, opts, ...extra) ->
			# 				unless opts and typeof opts is \object
			# 					opts = {}
			# 				opts.contentEditable = true
			# 				console.log "extra.length", extra.length

			# 				refs.cE.apply this, [type, opts] ++ extra
			# 			_get = doc.get
			# 			_set = doc.set
			# 			doc.get = (field) ->
			# 				console.log "getting field:", field
			# 				_get.call doc, field
			# 			doc.set = (field, val) ->
			# 				console.log "setting field:", field, '=', val
			# 				_set.call doc, field, val
			# 				preview.emit \transition
			# 			console.warn window.preview = preview = opts.tone refs, doc
			# 		return E \div c: \preview, preview
			# 	_.map schema, field_entry
			# 	E \div c: 'form-actions',
			# 		E \div c: 'btn-toolbar',
			# 			E \button,
			# 				type: \submit
			# 				c: 'btn btn-success'
			# 				onclick: (e) ~>
			# 					@emit \saving
			# 					@doc.validate (err) ~>
			# 						# XXX: validation should be done on the moment.
			# 						#  it should also give also feedback as to what's wrong
			# 						@doc.save (err) ~>
			# 							# XXX: if there's an error, display the error
			# 							#  if it's successful, show some sort of feedback should be automatic as well
			# 							if err => throw err
			# 							@emit \saved
			# 							@transition \load
			# 				if @doc.isNew then "Post" else "Save"
			# 			E \button,
			# 				type: \button
			# 				c: 'btn btn-default'
			# 				onclick: (e) ~>
			# 					console.log "undo", e.target
			# 					# XXX save all save/update operations into a log, with the capacity to 'undo'
			# 					@emit \undo
			# 				"Undo"
			# debugger
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
				console.log "Tone: we entered into a new state"
				if not @states.new.renderers
					@states.new.renderers = _.keys @_bp._blueprint.layout
