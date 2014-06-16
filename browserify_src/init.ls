
Path = require \path
Url = require \url
# Fs = require \fs


{ Fsm, ToolShed, _ } = require 'MachineShop'
{ Debug } = ToolShed


var UniVerse


# { PublicDB, LocalDB, Blueprint, Word } = require './sandra/PublicDB'
# { Poem, Verse, Voice, Tone, Rhythm, Stanza } = require './sandra/Poem'

# Uuid = require \node-uuid
#Jive = require \jivejs

load_bps = (refs) ->
	# clear cache
	Blueprint._ = {}
	for k, v in Word._
		delete Word._[k]
		Word._[k] = {}
	refs.bp = {}
	refs.verse = {}

# torrent streaming
# https://github.com/mafintosh/peerflix

# extend publicdb
# https://github.com/mafintosh/mongojs
# https://github.com/mafintosh/mongoc

# have a look at this ui framework:
# http://bladerunnerjs.org/docs/use/getting_started/

# improve verse
# https://github.com/mafintosh/cable

# https://crackstation.net/hashing-security.htm

# http services
# https://github.com/mafintosh/respawn
# https://github.com/mafintosh/polo
# https://github.com/mafintosh/etcd-registry
# https://github.com/mafintosh/tar-fs

# -------

# pretty cool visualizations of sierpinski triangles (with src)
# http://www.oftenpaper.net/sierpinski.htm
# http://www.oftenpaper.net/index.htm#cellularautomata

export router = (path, refs) ->
	console.error "you should not be calling this!"
	return

	debug = Debug 'router'
	process.removeAllListeners \uncaughtException
	process.on \uncaughtException (err) ->
		console.error "uncaught error:", err.stack
		throw err

	content_el = doc.getElementById 'content'
	console.log "router path", path
	console.log "content_el", content_el
	Poem "affinaty", {$, window}
	window.Poem = Poem
	load_bps refs

	content_el.innerHTML = ''
	console.log "path: #{path}"
	path = path.split '/'
	if path.0 is ''
		path.splice 0, 1

	poem.session.route path

# make the poem init a different function
# move this code over to the poem init function


export init = (refs) ->
	console.log "init.init"
	debug = Debug 'init'
	debug "init poem manager affinaty"
	# if typeof UniVerse is \undefined


	# if typeof UniVerse is \object
	# 	console.log "already initialized UniVerse", UniVerse
	# 	return UniVerse

	window = refs.window
	doc = window.document
	refs.$ = $ = window.$
	refs.cE = cE = window.cE
	refs.aC = aC = window.aC
	cE.$ = $
	#THREE := window.component.require 'timoxley-threejs'
	Mousetrap = window.Mousetrap
	#ColorPicker := window.component.require 'component-color-picker'
	#Popover := window.component.require 'component-popover'

	console.log "initializing UniVerse", UniVerse
	UniVerse := require './UniVerse' .UniVerse

	window.UniVerse = UniVerse

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

	# it could be kinda fun to make the version defined by the hostname (eg. http://v1.0.affinaty.es - http://latest.affinaty.es)
	version = switch host[len-3]
	| \beta => \0.1.0
	| \dev => \latest
	| otherwise => \0.1.0

	# figurehead = switch url.hostname
	# | \local.beta.affinaty.es \beta.affinaty.es =>
	# 		\Affinaty@0.1.0
	# | \local.affinaty.es \affinaty.es =>
	# 		\Affinaty@0.1.0
	# | \local.dev.affinaty.es \dev.affinaty.es =>
	# 		\Affinaty@latest
	# | \dev.sandrafeltes.com => \Sandra
	# | \hamsternippl.es => \MechanicOfTheSequence
	# | otherwise => \UniVerse #\splash

	# for now, I'm using the hostname as the bookname, but really this can be anything...
	# this should be automated in some way...
	# I'm thinking some sort of regex for the host with some kind of mapping
	# have a look at this: https://github.com/nodejitsu/node-http-proxy/issues/355
	# UniVerse.book = new PoetryBook refs, figurehead#, figurehead
	# window.body.
	el = null
	process.nextTick ->
		book = UniVerse.begin {window, require}, el
		book.exec \open figurehead, version, cur_path
		aC null, book
	# UniVerse.exec \persona (persona) ->
	# 	if persona
	# 		UniVerse.debug "we have discovered that you are logged in as:", persona.get \name
	# 		storybook = persona.get(\storybook)
	# 		@debug "you are currently on the storybook:", storybook
	# 		book.exec \open storybook
	# 	else
	# 		# debugger
	# 		UniVerse.debug "you are not logged in. we are going to just simply open the default"
	# 		book.exec \open figurehead, \latest, cur_path #'login'
	# UniVerse.book.transition figurehead
	console.log "maybe do some sort of loading screen here eventually"

	# mabe make this Poetry.poetry
	# UniVerse.poetry = poetry = new Fsm "Poetry" {


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
	#init_watcher!

	# maybe do some extends....
	return UniVerse

	#############################
	#############################
	#############################



	######################## INIT ###############





