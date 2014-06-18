
console.log "welcome to verse"
console.log "argv:", process.argv
console.log "TODO: add verse stuff here"

Path = require \path
Fs = require \fs
Growl = require \growl

require \LiveScript

{ DaFunk, Config, Debug } = require \MachineShop
{ Implementation } = require Path.join __dirname, \src \Implementation
{ Reality } = require Path.join __dirname, \src \Reality
{ LocalLibrary } = require Path.join __dirname, \src \LocalLibrary
{ Ambiente, UniVerse } = require Path.join __dirname, \src \Source

debug = Debug \verse

print_uncaught = (err) ->
	if err.filename
		# @debug "error compiling file: #{err.filename} - #err"
		console.log "error compiling file: #{err.filename} - #err"
	else
		# @debug.error "uncaughtException: #{err.stack}"
		console.error "uncaughtException: #{err.stack}"
process.on \uncaughtException print_uncaught

# console.log "W", __dirname+"/browserify_src"
# watcher = Fs.watch __dirname+"/browserify_src", (evt) ->
# 	console.log "disturbance", evt
# 	exec "lsc -cb --output lib browserify_src/*.ls"

# return

# env.exec \imbue \PublicDB, Reality, (PublicDB) ->
# verse = new Implementation uV, './origin/Verse.ls'
# verse.on \ready (Verse) ->
# 	Verse \concept://UniVerse

# Verse \verse

# env = new Ambiente 'MultiVerse'
# library = new LocalLibrary {},
# 	protos: __dirname + '/protos'
# 	path: __dirname + '/library'

# in the end, Uni = the beginning of origin, so
# a UniVerse is Uni + Verse
# Uni = is where the implementations begin. it's a shell, or an interface to a program.
# it could be a subprocess, or a dbus type system of communication. it could also be dnode (in the case of Verse)

add_growl = (fsm) ->
	title = fsm.namespace
	title = title.substr 0, title.length - 4
	# fsm.on \debug, (data) -> Growl data.message, {title}
	fsm.on \debug:notify, (data) -> Growl data.message, {title, image: \./icons/fail.png}
	fsm.on \debug:error, (data) -> Growl data.message, {title, image: \./icons/fail.png}

	fsm.on \compile:success, (dd) ->
		Growl "#{@path} compiled correctly", {title, image: \./icons/success.png}
	fsm.on \compile:failure, (err) -> Growl err.message, {title, image: \./icons/fail.png}

amb = new Ambiente \sencillo
amb.on \state:ready ->
	console.log "ambiente is ready!!"
	console.log "technically, I shouldn't need to wait for its ready state. the Implementation should do that"
	# UniVerse here
	add_growl \
		impl = new Implementation amb, "origin/ArangoDB.concept.ls"

	var narrator
	impl.on \compile:success ->
		_.each impl._instances, (inst) ->
			inst.exec \destroy

		ArangoDB = impl.imbue Reality
		# this should essentially be the config
		narrator = new ArangoDB {
			port: 1111
		}
		narrator.on \state:ready ->
			console.log 'HTTP ready'
