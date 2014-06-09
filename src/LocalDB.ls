{ Fsm, Fabuloso, ToolShed, _ } = require 'MachineShop'
{ Debug } = ToolShed



class LocalDB extends Fsm
	(options) ->
		# debugger
		ToolShed.extend @, Fabuloso
		super "LocalDB"

	states:
		uninitialized:
			onenter: ->
				@transition \ready
			'node:onenter': ->
			'browser:onenter': ->
				@storage = new _.LargeLocalStorage options
				@storage.initialized.fail (err) ~>
					console.log "local storage error:", err
					@transition \error
				@storage.initialized.done ~>
					if typeof cb is \function then cb ...
					@transition \ready

		ready:
			onenter: ->
				@emit \ready

		error:
			onenter: ->
				@emit \error

	for k in <[get set remove list clear]>
		@@::[k] = ((k) -> (key, options, cb) ->
			throw new Error "TODO: implement a k/v storage..."
			# look into doing this over webrtc
			# rip off something like this: https://foundationdb.com/operations

			if @state is \error
				if typeof cb is \function
					cb {code: \ERRNOTAVAILABLE}
			else
				dfd = @storage[k].call @storage, key, options
				if typeof cb is \function
					dfd.then cb
				dfd)(k)
	@@::query = (query) ->
		console.log "TODO: query the LocalDB/PubliCDB"

export LocalDB