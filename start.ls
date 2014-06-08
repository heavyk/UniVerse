# bootstrap the UniVerse


Path = require \path
Growl = require \Growl
growl_enabled = false


{ DaFunk, Config } = require \MachineShop
{ Blueprint, LocalLibrary } = require './src/Blueprint'
{ Implementation } = require './src/Implementation'
{ Reality } = require './src/Reality'
# { Laboratory } = require './src/Laboratory'
# { LocalDB } = require './src/LocalDB'

# ldb = new LocalDB path: __dirname + 'src' # more options here...
# { EtherDB } = require './src/EtherDB'



multiverse = require './multiverse'
# uv_bp = require './src/UniVerse.blueprint'

# db = new EtherDB
# db.exec \fetch \UniVerse@latest

multiverse = Config 'multiverse.json'
multiverse.on \ready (config) ->
	# console.log "multiverse", config
	console.log "multiverse ready"
	console.log "STEP 1. load the local library"

# Library = new Implementation "src/Library.concept.ls"

library = new LocalLibrary {multiverse},
	path: __dirname + '/library'


# return


# TODO: hook the laboratory into the machina

add_growl = (fsm) ->
	title = fsm.namespace
	title = title.substr 0, title.length - 4
	fsm.on \notify (msg) ->
		if growl_enabled => Growl msg, {title}
	fsm.on \error, (err) ->
		if growl_enabled => Growl err.message, {title, image: \./icons/fail.png}
	fsm.on \success, (dd) ->
		if growl_enabled => Growl dd.message, {title, image: \./icons/success.png}

add_dir_growl = (dir) ->
	dir.on \new:SrcDir (d) ->
		add_dir_growl d
	dir.on \new:Src (src) ->
		add_growl src

impl = new Implementation path: "src/Laboratory.concept.ls" outfile: "library/Laboratory.concept.js"
impl.on \ready (current_impl) ->

	Laboratory = impl.imbue Reality
	lab = new Laboratory { library }, technician: \volcrum

	# add_growl lab

	# lab.until \ready ->
	# 	Growl "all ready!", {title: lab.namespace, image: \./icons/success.png}
	# 	growl_enabled := true


	# lab.on \new:Project (prj) ->
	# 	add_growl prj
	# 	prj.on \new:SrcDir (dir) ->
	# 		add_dir_growl dir



# Source = require
# bp = new Blueprint uv_bp
# bp.on \ready ->
# 	console.log "bp is ready"
# 	Sencillo = UniVerse.imbue multiverse.sencillo
# 	Sencillo.on \ready ->
# 		console.log "UniVerse started"
# 		console.log "to configure it, open http://localhost/ in your browser"
# 		console.log "enjoy."
# 		@debug.notify "started up UniVerse!"

