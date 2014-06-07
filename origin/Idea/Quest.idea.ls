called: \Quest
implements: \Process
version: \0.1.0

constructor: (@_bp, @key, opts) ->
	@book = _bp.refs.book
	@quest = _q = _bp._blueprint.quests[key]
	if typeof opts isnt \object
		opts = {}
	# since we're gonna use the key 'quests' and we're gonna pass opts to http, it's not fair to overwrite our (re)quest
	delete opts.quest
	@opts = opts
	@keys = []
	@_window = 10

	if _q
		# @inquire _q.inquiry
		@initialState = \quest
	else
		@initialState = \ENOQUEST

	super "#{_bp.incantation}:Quest(#key)"

machina:
	_filter_fn: null
	_inquire: (inquiry, depth) ->
		if typeof depth is \undefined
			depth = 0
			scope = {}
			js = ""
		ii = inquiry.split /[\n\t ]+/
		while ii and i = ii.shift!
			switch i.toUpperCase!
			| \FOR =>
				# var name
				v = ii.shift!
				if v.charAt(0) is '_'
					throw new Error "AQL does not allow any collections to start with '_'"
			| \IN =>
				# first, check vars, then check, incantation collections
				vi = ii.shift!
				if vi.charAt(0) is '_'
					throw new Error "AQL does not allow any vars to start with '_'"
				js += "this['#{v}'] = [];\n"
				if Array.isArray ExperienceDB._[vi]
					js += "_.each(this._['#{vi}'], function(#{v}){\n"
			| \FILTER =>
				# vv = ii.shift!
				if ii.0.charAt(0) is '('
					console.log "quickly parse the parens using a loop, then parse the expression into a function"
					joined = ii.join ' '
					console.log "this expression: '%s'", joined
					throw new Error "filters with expressions not yet supported. we accept pull requests :)"

					# parse the parens correctly
					# if ~(idx = joined.indexOf ')')
					multi_filter = true
					vars = [vv.substr(1)]
					while vp = ii.shift!
						switch vp.toUpperCase!
						| \|| => is_or = true
						| \&& => is_and = true
						| otherwise =>
							if vp.substr(-1) is ')'
								done = true
			| \LET =>
				throw new Error "we don't support expressions quite yet"
				l = ii.shift!
				expr = ii.join ' '
				js += "this['#{l}'] = function() {}"
				# scope[l] =
			| \SORT =>
				throw new Error "we don't support sorted things ...yet"
			| \LIMIT =>
				throw new Error "we don't support limits yet"
			| \RETURN =>
				r = ii.shift!
				r = ii.join ' '
				# check if it's a variable
				rr = r.split '.'
				js += "this['#{v}'].push(#{r})"
				ii = null

		@book.memory[vi].on \forgotten (key, xp) ~>
			console.log "forgot exp", key
			# debugger
			if ~(idx = @keys.indexOf key)
				@emit \removedAt key, idx
				if @keys.length < @_window
					@

		@book.memory[vi].on \found (key, xp) ~>
			console.log "we found xp", xp, @keys.indexOf key
			if not ~@keys.indexOf key
				# for now, we assume that it is true for the filter function :)
				# XXX: fixme!
				@emit \addedAt, key, 0

		return new Function js

	inquire: (inquiry) ->
		@filter_fn = @_inquire inquiry

	eventListeners:
		added: (key) ->
			@keys.push key

		addedAt: (key, i) ->
			@keys.splice i, 0, key

		removed: (key) ->
			if key
				assert @keys[*-1] is key
			@keys.pop!

		removedAt: (key, i) ->
			# debugger
			if key
				assert @keys[i] is key
			@keys.splice i, 1

	states:
		uninitialized:
			onenter: ->
				# if @key
				# 	@transition \quest
		ENOENT:
			onenter: ->
				@debug.error "lol, this quest doesn't exist"
				@debug.todo "overrite this with a word called QuestCreator\nthis should be an abstract object too, which then takes care of everything"


		quest:
			onenter: ->
				# just in case we're already (re)questing :)
				if @__loading
					@__loading.abort!
				opts = {quest: @key} <<< @opts
				@inquire @quest.inquiry
				# _length: 0
				# count: 0
				# size: 10
				# keys: []
				# more: false
				# id: false
				@emit \questing @key
				@exec \request opts

			more_quest: (opts) ->
				if not @_id
					debugger
					@debug.error "nothing more to quest!"
					return
				if typeof opts is \nubmer
					opts = {many: opts}
				else if typeof opts isnt \object
					opts = {}
				# bp = @_bp
				# id = @_id
				# key = @_key
				opts.cursor = @_id
				@exec \request opts

			request: (opts) ->
				# if typeof opts is \string
				# 	opts = {quest: opts}
				req_txt = JSON.stringify opts

				bp = @_bp
				# @_id = 0
				# @_length = 0
				# @_max_length = opts.pageSize || 10
				# @_key = key
				# @transition key
				# really, it's not necessary to put the whole bp if we're just passing the cursor id
				@__loading = req = Http.request { method: \post path: "/db/_/#{bp.encantador}:#{bp.incantation}@#{bp.version}/" }, (res) ~>
					res.on \error (err) ~>
						@__loading = null
						switch err.code
						| \ENOENT =>
							@debug.error "blueprint does not exist..."
						| \ENOQUESTS =>
							@debug.error "blueprint does not have any quests"
						| \ENOQUEST =>
							@debug.error "blueprint does not have any have this quest"
						| otherwise =>
							@debug.error "we've got an error!!"
						@transition err.code
					# perhaps an improvement here would we a streaming json parser?
					data = ''; res.on \data (buf) -> data += buf
					res.on \end ~>
						console.log "this is the result of loading a quest: (#{@key}):", res.statusCode
						@_loading = null
						unless opts.cursor
							@emit \empty
						if res.statusCode is 200
							if typeof data is \string and data.0 is '{'
								json = JSON.parse data
								@_more = json.hasMore
								# TODO: if hasMore, then set the expiry for the cursor id, to know if I should try with the id of not
								#TODO: send the cursor id timeout along with the response, if possible :)
								setTimeout ~>
									@debug "resetting more_quest cursor ... prolly doesn't exist now"
									@_id = 0
								, 20000
								# TODO: if hasMore, then set overflow scroll, save the element size, then
								if not @_id
									@_id = json.id
									@total = json.count
								if Array.isArray result = json.result
									console.log "results:", result
									if result.length is 0
										@emit \nada
									for key, i in result
										@emit \added, key
									@emit \more, json.count - result.length
									assert json.count >= result.length
								else @emit \nada

							else if typeof data is \undefined
								@emit \empty
						else
							# @transition \error
							@emit \error, {code: \ENOENT}
							@transition res.statusCode

						# debugger
						if @_more and @keys.length < @_window * 1.5
							# debugger
							@exec \more_quest

				req.on \error (err) ~>
					debugger
					console.error "(re)quest error", err
					@emit \error

				req.write req_txt
				req.end!

export Quest