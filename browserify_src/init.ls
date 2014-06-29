
Path = require \path
Url = require \url

{ Fsm, ToolShed, _ } = require 'MachineShop'
{ Debug } = ToolShed

var UniVerse

# is this even used any more??? - investigate the router
load_bps = (refs) ->
	# clear cache
	Blueprint._ = {}
	for k, v in Word._
		delete Word._[k]
		Word._[k] = {}
	refs.bp = {}
	refs.verse = {}

export router = (path, refs) ->
	throw new Error "you should not be calling this!"

	debug = Debug 'router'
	process.removeAllListeners \uncaughtException
	process.on \uncaughtException (err) ->
		console.error "uncaught error:", err.stack
		throw err

	content_el = doc.getElementById 'content'
	Poem "affinaty", {$, window}
	window.Poem = Poem
	load_bps refs

	content_el.innerHTML = ''
	path = path.split '/'
	if path.0 is ''
		path.splice 0, 1

	poem.session.route path

# XXX: this should eventually be improved
export init = (refs) ->
	console.log "init.init"
	debug = Debug 'init'

	window = refs.window
	doc = window.document
	refs.$ = $ = window.$
	refs.cE = cE = window.cE
	refs.aC = aC = window.aC
	cE.$ = $
	Mousetrap = window.Mousetrap
	UniVerse := require './UniVerse' .UniVerse

	window.UniVerse = UniVerse

	Dnode = require \dnode
	Shoe = require \shoe

	stream = Shoe '/dnode'
	# stream_lab = Shoe '/dnode-lab'
	# d = Dnode!# (remote) ->
	d = Dnode {
		Blueprint: (cmd, args) ->
			console.log "got some updates", &
	}
	d.on \remote (remote) !->
		# debugger
		console.log "connected!"
	d.pipe stream .pipe d
	# dlab = Dnode! # (remote) ->
	# 	# debugger
	# 	# console.log "lala"
	# dlab.on \remote, (remote) ->
	# 	debugger
	# 	remote.test 'lala' (s) ->
	# 		console.log 'beep => ' + s
	# 		dlab.end!
	# dlab.pipe stream_lab .pipe dlab

	# ONE-TIME INIT stuff
	if ToolShed.nw_version
		process.removeAllListeners \uncaughtException
		process.on \uncaughtException (err) ->
			console.error "uncaught error:", err.stack
			throw err

	url = Url.parse window.location.href
	cur_proto = url.protocol
	cur_host = url.host
	cur_path = url.path
	var cur_watcher, cur_file

	# console.error "beforeunload"
	# $ doc .bind "beforeunload", (e) ->
	# 	console.error "likely an error... you are leaving"
	# 	"you sure you want to leave here?"
	# maybe I should store this in the MultiVerse PublicDB - and then download it???
	host = url.hostname.toLowerCase!split '.'
	len = host.length
	figurehead = switch host[len-2]
	| \affinaty => \Affinaty
	| \hamsternippl => \MechanicOfTheSequence
	| otherwise => \UniVerse

	version = switch host[len-3]
	| \beta => \0.1.0
	| \dev => \latest
	| otherwise => \0.1.0

	el = null
	process.nextTick ->
		book = UniVerse.begin {window, require}, el
		book.exec \open figurehead, version, cur_path
		aC null, book
	# XXX: it would be awesome to implement some sort of loading screen here

	# this is old code. not sure about it. should be deleted when poems are working properly with less
	init_watcher = ->
		window.watches = []
		_.each $('link'), (e) ->
			if e.href
				uri = Url.parse e.href
				if uri.protocol is \file: or Path.extname(uri.path) is \.less
					p = Path.resolve uri.path.substr(1)
					console.log "gonna watch path", p
					watcher = Fs.watchFile p, {interval: 500}, (evt, filename) ->
						console.log "oh shit, a CSS update", window.less
						window.less.refresh!
					window.watches.push watcher
	console.log "TODO: .less file watching/reloading (add this to the laboratory)"

	return UniVerse





