
Http = require \http
assert = require \assert

{ Fsm, ToolShed, _ } = require 'MachineShop'

if typeof window isnt \object
	LevelDOWN = require \leveldown
LevelUP = require \levelup
LevelJS = require \level-js

# this needs an extensive test suite to test for:
# 1. delayed response
# 2. rev being updated on server between requests
# 3. patches display the correct diffs (look in the old code for diff funcs)
# ... etc.

# TODO: utilize Current storage modules for this

# an expierience can be classified as an emotion.
# you can state, that is hatred, or that is disgust
# or that can be love, or whatever
# this allows someone to classify something including a poem as an emotion
# once this is created we can use vertices to allow someone to see the things the want
# this is probably the best way to create a recommendation system...
# we would recommend something similar to that emotion mixed with the substance (this is the heart)

# this one is the local database of all objects in the list
# I can improve on it by making keys
# new incantations (xp) get added to the array
# when creating the bp, extend incantation
# has multiple connections to PublicDB and one to LocalDB

# technically, you shouldn't need a database with this
# even more cool, is when you reconnect, everything should go back to normal
# it's sorta like a client-side version of ArangoDB
class ExperienceDB extends Fsm
	(@incantation) ->
		@_ = []
		@_indices = {} # is this used?
		@_idx = {}
		@__request = []
		if assert
			@deleted = []

		super "ExperienceDB(#incantation)"

	states:
		uninitialized:
			onenter: ->
				console.log "we're gonna connect now..."

		connected:
			onenter: ->
				console.log "connected to the database now.."

		disconnected:
			onenter: ->
				console.log "disconnected from the universe"

	eventListeners:
		# something is new if it has not been experienced before

		# patch (key) ->
		found: (key, xp) ->
			# _.each @filters, (fn, f) ->
			@emit "found:#key", xp

		# XXX: implement diffing in changes
		changed: (key, xp, old_xp, diff) ->
			@emit "changed:#key", xp, old_xp, diff

		forgotten: (key, xp) ->
			k = "forgotten:key"
			@emit k, xp
			delete @eventListeners[k]

		error: (key, err) ->
			if key
				@emit "error:#key", err

		# send: (key, xp) ->

		# obtain: (key, xp) ->

	_set: (key, rev, xp) ->
		# XXX: set the item in the index as well!!
		for _xp, i in @_
			if _xp._key is key
				if rev
					if _xp._rev is rev
						@_.splice i, 1, xp
						return _xp
				else
					@_.splice i, 1, xp
					return _xp
		@_.push xp
		return false

	# returns null if key/rev was not found
	# otherwise, it returns the xp deleted (truthy)
	_del: (key, rev) ->
		# XXX: delete from index as well!!
		for _xp, i in @_
			if _xp._key is key
				if rev
					if _xp._rev is rev
						@_.splice i, 1
						return _xp
				else
					@_.splice i, 1
					return _xp
		return null


	_get: (key, rev) ->
		if @_idx and typeof(i = @_idx[key]) isnt \undefined
			if Array.isArray ii = @_[i]
				#TODO: search for the _rev
				return ii.0
			else return ii

		for xp in @_
			if xp._key is key
				if rev
					if xp._rev is rev
						return xp
				else return xp
		return null

	_req: (method, key, vals, cb) ->
		id = @incantation
		if key
			if assert and method is \delete
				if ~@deleted.indexOf key
					console.log "this shouldn't happen... kinda an insurance policy while testing"
					debugger
				else
					@deleted.push key
			id += "/#key"
			if @__request[key]
				console.log "already saving... throttle this"
				console.log "TODO: add 'saving' 'saved' 'save_timeout' events plus debounce with a cooldown to try again"
				@debug.todo "re-request in x time"
				# XXX: re-request in x time
				debugger
				# _.debounce @_req, @, 10

		opts = {method, path: "/db/#{id}"}
		req = Http.request opts, (res) !~>
			res.on \error (err) ->
				if key
					delete @__request[key]
				else if ~(idx = @__request.indexOf(req))
					@__request.splice idx, 1
				else
					@debug.error "unknown request!"
				@emit "error:#key", err
				debugger
				console.error "we've got an error!!", err

			data = ''; res.on \data (buf) -> if buf => data += buf

			res.on \end ~>
				@__request[key] = null
				if res.statusCode is 200
					# there should be a methid for an obj to register events
					# also, to unregister the events
					if method isnt \delete
						xp = ToolShed.objectify data, {}, {name: id}
						if xp._key and not xp._id
							xp._id = @incantation+'/'+xp._key
						cb null, xp if typeof cb is \function
					else if typeof cb is \function
						cb null, key
					# switch method
					# | \post =>
					# 	# @emit \changed, key, xp, vals
					# 	if typeof cb is \function
					# 		cb null, vals <<< xp
					# 	# @emit \found xp._key, xp
					# 	# if key isnt xp._key
					# 	# @_set xp._key, null, xp
					# 		# key := xp._key
					# | \get =>
					# 	# @emit \found key, xp
					# 	# @_set key, null, xp
					# 	if typeof cb is \function
					# 		cb null, xp
					# | \patch =>
					# 	# @_set key, vals._rev, vals
					# 	# @emit \changed key, xp
					# 	if typeof cb is \function
					# 		cb null, xp
					# | \delete =>
					# 	# @emit \forgotten key
					# 	# @emit \found key, xp
					# 	@_set key, null, xp
					# 	if typeof cb is \function
					# 		cb null, key

				else
					# switch method
					# | \patch =>
					# 	# @_del key, _xp = vals <<< xp
					# 	# @_set key, vals._rev, _xp = vals <<< xp
					# 	# @emit \changed key, xp

					# | \delete =>
					# 	# @emit \forgotten key
					# 	@_del key
					# 	if typeof cb is \function
					# 		cb null, key

					code = res.statusCode
					if code is 404
						code = \ENOENT
					else
						debugger
					# if code >= 300
					# 	code = \EMOVED
					@emit "error:#key", code: code
					if typeof cb is \function
						cb {code}, key

		if key => @__request[key] = req
		else @__request.push req
		if vals => req.write req_txt = JSON.stringify vals
		req.end!

	# XXX: add rev to all these functions
	get: (key, rev, cb) ->
		if typeof rev is \function
			cb = rev
			rev = void
		# if ~key.indexOf '/'
		# 	debugger
		@_req \get key, null, (err, xp) !~>
			if not err
				@emit \found key, xp
			if typeof cb is \function
				cb err, xp
		return @_get key

		# eventually make this use library (to utilize the public ether dbs)

		# UniVerse.exec \fetch key, xp._rev (err, new_xp) ~>
		# 	if _rev != _rev => \birth
		# 	else @emit \change new_xp._key, xp_diff(xp, new_xp)

	patch: (key, rev, xp, cb) ->
		if typeof rev is \object
			cb = xp
			xp = rev
			rev = void
		# XXX: if failed, unpatch and throw an error
		@_req \patch, key, xp, cb
		if not _xp = @_get key, rev
			@debug.error "dude you're trying to patch something that doesn't exist"
			return false
		_xp <<< xp
		@_req \patch, null, _xp, (err, xp) !~>
			if err
				@_set key, null, _xp
				@emit \changed key, _xp
				@emit \error err
			# if the patch was successful, we don't need to do anything


		@emit \changed key, _xp
		return _xp

	create: (xp, cb) ->
		# XXX: if failed, unpatch and throw an error
		# assert typeof xp._key is \undefined
		# assert typeof xp._id is \undefined

		vals = DaFunk.extend {}, xp
		assert typeof vals._rev is \undefined
		assert typeof vals._id is \undefined
		assert typeof vals._key is \undefined
		assert typeof vals._k is \undefined
		@_req \post, null, vals, (err, _xp) !~>
			_xp = xp <<< _xp
			@emit \changed xp._k, _xp
			@_set key, null, _xp
			if typeof cb is \function
				cb ...
		# @emit \found key, xp
		key = xp._k
		# key = Math.random!toString 32 .substr 2
		xp._key = xp._k = key
		xp._id = @incantation+'/'+key
		@emit \found key, xp
		@_set key, null, xp
		return xp

	forget: (key, cb) ->
		xp = @_get key
		@emit \forgotten key
		@_req \delete key, null, (err) !~>
			if err
				@emit \error, err
				@emit \found key, vals
				if typeof cb is \function
					cb ...
			# if deleted successfully, we don't need to do anything more..
	@@_ = {}
	# @@get = (incantation, key, cb) ->
	# 	if typeof (db = @@ExpDB[incantation]) is \undefined
	# 		@@ExpDB = db = new ExperienceDB incantation

	# 	db.exec \fetch key, cb

	# @@set = (incantation, key, cb) ->
	# @@patch = (incantation, key, cb) ->
	# @@destroy = (incantation, key, cb) ->


# var fn = function() {
# 	this.m = [];
# 	ExperienceDB._.Mun.forEach(function(m) {
# 		console.log("m:", m)
# 		if(m.name == this.name || m.name == "heavyk")
# 		if(m.mmm == "yay!")
# 		this.m.push(m._key);
# 	}, this)
# 	return this.m;
# }

parse_parens = (txt) ->
	throw new Error "we don't support paren parsing yet"
	p = i = q1 = q2 = 0
	len = txt.length
	while i < len
		c = txt[i++]
		switch c
		| '(' =>
			p++
		| ')' =>
			p--
		| \' =>
			if q1 => q1-- else q1 is 0 and q1++
		| \" =>
			if q2 => q2-- else q2 is 0 and q2++


	if ~(idx = txt.indexOf ')')
		return txt.substr 0, idx
	return ''

# obviously, asserts will be removed in non-debug compiles
# this idea rips off D programmong language. thanks walter! you are bright... :)
# assert "(lala == lala)" is parse_parens "(lala == lala) more shit"
# assert "(lala == (lala))" is parse_parens "(lala == (lala)) more shit"
# assert "(lala == (lala == ')'))" is parse_parens "(lala == (lala == ')')) more shit"

# there can be quests through time (d_created)
# there can also be quests through space (name)
# class SpaceQuest extends Quest
# 	(@_bp, @id, space_field, opts) ->
# class TimeQuest extends Quest
# 	(@_bp, @id, time_field, opts) ->
# these essentially organize the list into a manageable form.
# time quests append to the beginning or end
# space quests use a form of binary search to append directly into the beginning / middle / end

# in the future, heart quests will show how things are connected (using edges / vertices as different time-space quests)
#  hehehehe, this is AWESOME!

class Quest extends Fsm
	# (@book, @have, inqiry) ->
	(@_bp, @key, opts) ->
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

		# @Book.Poetry[incantation].on \new
		# if have is an experience, then use "get"

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

# this is to be used server-side as the individual objects of PublicDB
# class Experience extends Fsm

# wait a minute here!! we don't need to modify arango at all to make PublicDB!
# get the objects and serialize them according to the desired_order in the blueprint and then make them git commits.
# store the git commits into redis, and make it massively distributed
# do this in conjunction with EtherDB and you have a winning combo!!!

# this class simply coordinates the modifications to exp (not new or forgotten exp)
class Perspective extends Fsm
	(@incantation) ->
		@_ = {}
		super "Perspective(#incantation)"

	eventListeners:
		visible: (incantation, key, rev) ->
			@debug.todo "get the updates to this element and then emit them"
	states:
		connected:
			onenter: ->
				@debug "yay!! we're connected"
				@debug.todo "begin listening to events again on all experiences in the perspective"

			visible: (incantation, key, rev) ->
				@debug.todo "get the updates to this experience and then emit them"
				# first check the experiencedb for local changes
				# then send out a message to PerspectiveDB which is basically just a node server listening to replicate events from PublicDB.
				# in more advanced versions, it'll have a redis frontend which coordinates itself. for massive amounts of listeners with only a few of them listening to publicdb replications (they translate PublicDB -> redis pubsub events).
				# the events should just send (incantation:key:rev) to the server and first check to see if there's an update. if there is, return the new rev.
				# in the future, modify arango to be PublicDB, where arango essentially acts like a json serializer and git comitter, where the new revs are sha1 hashes

			invisible: (incantation, key, rev) ->
				@debug.todo "stop listining to the updates on this eexperience"

		disconnected:
			onenter: ->
				@debug "booo... we've been disconnected"


export ExperienceDB
export Quest