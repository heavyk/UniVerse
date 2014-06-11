# bootstrap the UniVerse

Path = require \path
Growl = require \Growl

{ DaFunk, Config } = require \MachineShop
{ Blueprint } = require './src/Blueprint'
{ Implementation } = require './src/Implementation'
{ Reality } = require './src/Reality'
{ LocalLibrary } = require './src/LocalLibrary'

# ldb = new LocalDB path: __dirname + 'src' # more options here...
# { EtherDB } = require './src/EtherDB'



multiverse = require './multiverse'
# uv_bp = require './src/UniVerse.blueprint'

# db = new EtherDB
# db.exec \fetch \UniVerse@latest

# multiverse = Config 'multiverse.json'
# multiverse.on \ready (config) ->
# 	# console.log "multiverse", config
# 	console.log "multiverse ready"
# 	console.log "STEP 1. load the local library"

# Library = new Implementation "src/Library.concept.ls"

# library = new LocalLibrary {multiverse},
# 	protos: __dirname + '/protos'
# 	path: __dirname + '/library'


# return


# TODO: hook the laboratory into the machina

add_growl = (fsm) ->
	title = fsm.namespace
	title = title.substr 0, title.length - 4
	# fsm.on \debug, (data) -> Growl data.message, {title}
	fsm.on \debug:notify, (data) -> Growl data.message, {title, image: \./icons/fail.png}
	fsm.on \debug:error, (data) -> Growl data.message, {title, image: \./icons/fail.png}

	fsm.on \compile:success, (dd) ->
		Growl "#{@path} compiled correctly", {title, image: \./icons/success.png}
	fsm.on \compile:failure, (err) -> Growl err.message, {title, image: \./icons/fail.png}

add_dir_growl = (dir) ->
	dir.on \new:SrcDir (d) ->
		add_dir_growl d
	dir.on \new:Src (src) ->
		add_growl src

# add_growl \
# 	impl = new Implementation path: "origin/Laboratory.concept.ls" outfile: "library/Laboratory.concept.js"
# impl.on \ready ->
# 	Laboratory = impl.imbue Reality
# 	lab = new Laboratory { library }, technician: \volcrum

	# lab.on \new:Project (prj) ->
	# 	add_growl prj
	# 	prj.on \new:SrcDir (dir) ->
	# 		add_dir_growl dir

add_growl \
	impl = new Implementation path: "origin/MultiVerse.concept.ls" outfile: "library/MultiVerse.concept.js"
impl.on \ready ->
	MultiVerse = impl.imbue Reality
	multiverse = new MultiVerse { library }
	multiverse.exec \load \sencillo, (err, uV) ->
		console.log "loaded sencillo..."

