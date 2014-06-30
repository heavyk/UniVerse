
console.log "welcome to verse"
console.log "argv:", process.argv
console.log "TODO: add verse stuff here"

Path = require \path
Fs = require \fs
try
	# transition to use https://github.com/mikaelbr/node-notifier
	# or this one: https://github.com/Teamwork/node-notifier-allowed-in-mac-app-store (uses lower version of alloy/terminal-notifier)
	Growl = require \growl
catch e
	Growl = ->

require \LiveScript

{ DaFunk, Config, Debug } = require \MachineShop
{ Implementation } = require Path.join __dirname, \src \Implementation
{ Reality } = require Path.join __dirname, \src \Reality
{ Ether } = require Path.join __dirname, \src \Ether
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

console.log "argv", process.argv
verse = process.argv.3
version = process.argv.4

console.log "gonna monitor changes to the multiverse... if there are any, we should reload"
src = new Implementation null, "./JesusMuthaFuckinChrist.json.ls", "./source.json"
src.once \saved ->
	#TODO: source and ambiente should be separated
	console.log "source is ready!"

mV = new Implementation null, "./MultiVerse.json.ls", "./multiverse.json"
# mV.exec \watch
mV.on \compile:success ->
	console.log "compile was a success"
	@debug "multiverse modified..."
mV.on \state:ready (mv_impl) ->
	@debug "multiverse is READY"

mV.once \saved ->
	amb = new Ambiente process.env.AMBIENTE_ID || \sencillo
	# RETURNING WITH INTERNET
	amb.on \state:ready ->
		console.log "ambiente is ready!!"
		console.log "TODO: technically, I shouldn't need to wait for its ready state. the Implementation should do that"
		if VERSE_ID = process.env.VERSE_ID
			# console.log "spawning Implementation"
			# XXX: I should be spawning UniVerse.concept here..
			impl = new Implementation amb, "origin/#{VERSE_ID}.ls"
			impl.on \compile:success ->
				_.each impl._instances, (inst) ->
					inst.exec \destroy

				ArangoDB = impl.imbue Ether
				db = new ArangoDB {
					port: 1111
				}
				db.on \state:ready ->
					console.log 'ArangoDB ready'
		else
			amb.exec \add:verse \PublicDB.concept (verse) ->
				console.log "yay we got a verse:", verse.namespace
			amb.exec \add:verse \Narrator.concept (verse) ->
				console.log "yay we got a verse:", verse.namespace
		# END RETURNING WITH INTERNET
		# add_growl \
		# 	impl = new Implementation amb, "origin/PublicDB.concept.ls"

		# FOR LOCAL BELOW
		console.log "load narrator"
		add_growl \
			impl = new Implementation amb, "origin/Narrator.concept.ls"

		var db
		impl.on \compile:success ->
			_.each impl._instances, (inst) ->
				inst.exec \destroy

			ArangoDB = impl.imbue Ether
			# this should essentially be the config
			db = new ArangoDB {
				port: 1155
			}
			db.on \state:ready ->
				console.log 'ArangoDB ready'
