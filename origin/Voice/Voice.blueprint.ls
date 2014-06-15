#TODO: make a few different form types
# I need one for a comments

encantador: \Voice
incantation: \Voice
type: \Cardinal
version: \0.1.0
machina:
	states:
		uninitialized:
			onenter: ->
				poetry = @poetry
				word = poetry.Word[@encantar].inst null
				bp = word.bp._blueprint.layout

		load:
			onenter: ->
				# doc := @doc = new @model._model dd
				# @transition \ready

		ready:
			onenter: ->
				@doc = doc
				@emit \ready

			render: (E) ->
				schema = []
				#schema2 = _.merge({}, @model.config.schema)
				_.each @model.__schema, (obj, field) ->
					#obj.field = field
					console.log obj
					unless obj.hidden
						o = {}
						for k, v of obj
							o[k] = v
						o.field = field
						schema.push o
				schema = _.sortBy schema, 'order'
				console.log "form:", schema

				field_entry = (sv) ~>
					#console.log "field_entry", sv, sv.field
					if not sv.type
						debugger
					type = sv.type.toString!
					switch sv.render
					| \glyphicon =>
						icons = <[ glass music search envelope heart star star-empty user film th-large th th-list ok remove zoom-in zoom-out off signal cog trash home file time road download-alt download upload inbox play-circle repeat refresh list-alt lock flag headphones volume-off volume-down volume-up qrcode barcode tag tags poetry bookmark print camera font bold italic text-height text-width align-left align-center align-right align-justify list indent-left indent-right facetime-video picture pencil map-marker adjust tint edit share check move step-backward fast-backward backward play pause stop forward fast-forward step-forward eject chevron-left chevron-right plus-sign minus-sign remove-sign ok-sign question-sign info-sign screenshot remove-circle ok-circle ban-circle arrow-left arrow-right arrow-up arrow-down share-alt resize-full resize-small plus minus asterisk exclamation-sign gift leaf fire eye-open eye-close warning-sign plane calendar random comment magnet chevron-up chevron-down retweet shopping-cart folder-close folder-open resize-vertical resize-horizontal hdd bullhorn bell certificate thumbs-up thumbs-down hand-right hand-left hand-up hand-down circle-arrow-right circle-arrow-left circle-arrow-up circle-arrow-down globe wrench tasks filter briefcase fullscreen dashboard paperclip heart-empty link phone pushpin euro usd gbp sort sort-by-alphabet sort-by-alphabet-alt sort-by-order sort-by-order-alt sort-by-attributes sort-by-attributes-alt unchecked expand collapse collapse-top ]>
						E \div c: "form-group #{sv.render or type}",
							E \label, c: 'control-label col-lg-3 pull-left' for: 'input_'+sv.field, (sv.label or sv.field)
							E \div c: 'col-lg-3 col-3',
								iin = E \input,
									c: \form-control
									type: \text
									value: (doc.get(sv.field) or sv.default or '')
									id: 'input_'+sv.field
									placeholder: (sv.onempty or '')
									onchange: (e) ~> @doc.set sv.field, if typeof sv.onchange is \function and typeof (val = sv.onchange.call(@, @doc, e)) isnt \undefined => val else e.target.value
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
													doc.set sv.field, iin.value = icon
													pop.popover 'toggle'
												E \span c: "glyphicon glyphicon-#{icon}"
									title: "choose your icon"
								}
							sv.onrender
							if sv.oninfo => E \span c: \help-block, sv.oninfo
					| \colorpicker =>
						E \div c: "form-group #{sv.render or type}",
							E \label c: 'control-label col-lg-3 pull-left' for: 'input_'+sv.field, (sv.label or sv.field)
							E \div c: 'col-lg-3 col-3',
								iin = E \input,
									c: \form-control
									type: \text
									value: (sv.default or '')
									id: 'input_'+sv.field
									placeholder: (sv.onempty or '')
									onchange: (e) ~> @doc.set sv.field, if typeof sv.onchange is \function and typeof (val = sv.onchange.call(@, @doc, e)) isnt \undefined => val else e.target.value
							->
								b = E \button c: 'btn btn-default pull-left',
									E \span c: 'glyphicon glyphicon-cog'
								cp = new window.ColorPicker
								cp.on \change, (e) ->
									p = (v) ->
										v = v.toString 16
										if v.length < 2 => '0'+v else v
									doc.set sv.field, iin.value = "#{p e.r}#{p e.g}#{p e.b}"
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
						switch type
						| \string =>
							E \div c: "form-group #{sv.render or type}",
								E \label c: 'control-label col-lg-3' for: 'input_'+sv.field, (sv.label or sv.field)
								E \div c: \col-lg-8,
									if sv.render is \textarea
										E \textarea,
											c: \form-control
											id: 'input_'+sv.field
											placeholder: (sv.onempty or '')
											onchange: (e) ~> @doc.set sv.field, if typeof sv.onchange is \function and typeof (val = sv.onchange.call(@, @doc, e)) isnt \undefined => val else e.target.value
											(sv.default or '')
											sv.onrender
									else
										E \input,
											c: \form-control
											type: \text
											value: (sv.default or '')
											id: 'input_'+sv.field
											placeholder: (sv.onempty or '')
											onchange: (e) ~> @doc.set sv.field, if typeof sv.onchange is \function and typeof (val = sv.onchange.call(@, @doc, e)) isnt \undefined => val else e.target.value
											sv.onrender
									if sv.oninfo => E \span c: \help-block, sv.oninfo
						| \number =>
							E \div c: "form-group #{sv.render or type}",
								E \label c: 'control-label col-lg-3' for: 'input_'+sv.field, (sv.label or sv.field)
								E \div c: \col-lg-8,
									window.num = E \input,
										c: \form-control
										type: if sv.render is \spinner => \number else \range
										value: (sv.default.toString! or 0)
										min: sv.min
										max: sv.max
										step: sv.step
										id: 'input_'+sv.field
										placeholder: (sv.onempty or '')
										onchange: (e) ~> @doc.set sv.field, if typeof sv.onchange is \function and typeof (val = sv.onchange.call(@, @doc, e)) isnt \undefined => val else e.target.value
										sv.onrender
									if sv.oninfo => E \span c: \help-block, sv.oninfo
						| \date =>
							E \div c: "form-group #{sv.render or type}",
								E \label c: 'control-label col-lg-3' for: 'input_'+sv.field, (sv.label or sv.field)
								E \div c: \col-lg-8,
									E \input,
										c: \form-control
										type: \text
										id: 'input_'+sv.field
										placeholder: (sv.onempty or '')
										onchange: (e) ~>
											#console.log "input changed", sv.field, e.target.value, e.target
											doc.set sv.field, new Date e.target.value
										sv.onrender
									if sv.oninfo => E \span c: \help-block, sv.oninfo
						| \boolean =>
							E \div c: "form-group #{sv.render or type}",
								E \label c: \checkbox,
									E \input type: \checkbox, checked: (sv.default or false)
									sv.label
									sv.onrender
								if sv.oninfo => E \span c: \help-block, contentEditable: true, sv.oninfo
						| otherwise =>
							E \div c: 'alert alert-error', "unknown schema type: "+ sv.type

				return E \form,
					c: 'form-horizontal'
					onsubmit: (e) ->
						e.preventDefault!
						return false
					#E \legend, null,
					#	"new "+@model.name
					!->
						if opts.tone
							refs2 = _.clone refs
							refs2.cE = (type, opts, ...extra) ->
								unless opts and typeof opts is \object
									opts = {}
								opts.contentEditable = true
								console.log "extra.length", extra.length

								refs.cE.apply this, [type, opts] ++ extra
							_get = doc.get
							_set = doc.set
							doc.get = (field) ->
								console.log "getting field:", field
								_get.call doc, field
							doc.set = (field, val) ->
								console.log "setting field:", field, '=', val
								_set.call doc, field, val
								preview.emit \transition
							console.warn window.preview = preview = opts.tone refs, doc
						return E \div c: \preview, preview
					_.map schema, field_entry
					E \div c: 'form-actions',
						E \div c: 'btn-toolbar',
							E \button,
								type: \submit
								c: 'btn btn-success'
								onclick: (e) ~>
									@emit \saving
									@doc.validate (err) ~>
										# XXX: validation should be done on the moment.
										#  it should also give also feedback as to what's wrong
										@doc.save (err) ~>
											# XXX: if there's an error, display the error
											#  if it's successful, show some sort of feedback should be automatic as well
											if err => throw err
											@emit \saved
											@transition \load
								if @doc.isNew then "Post" else "Save"
							E \button,
								type: \button
								c: 'btn btn-default'
								onclick: (e) ~>
									console.log "undo", e.target
									# XXX save all save/update operations into a log, with the capacity to 'undo'
									@emit \undo
								"Undo"