Path = require \path
# Galaxy = require \galaxy
Fs = require \fs
Http = require \http
# Enchilada = require \enchilada
Browserify = require \browserify
Express = require \express
{ GridFS, GridStream } = require \GridFS
ImageMagick = require \imagemagick-native
Crypto = require \crypto
Backoff = require \backoff
Dnode = require \dnode
Shoe = require \shoe
Base58 = require \base58-native
HttpProxy = require \http-proxy
Suspend = require \suspend
Thunkify = require \thunkify

# to recompile all modules below a dir:
# for f in `find ~/Projects/ -type f -name binding.gyp -print`; do cd $(dirname "$f") && node-gyp rebuild --nodedir ~/Projects/node; don

#Multipart = Galaxy.unstar require \co-multipart
Multipart = require \co-multipart
Co = require \co

# implement this using thread.js
# https://github.com/rob333/thread.js/

# https://github.com/omsmith/simple-virtual-hosts

# https://github.com/feross/WebTorrent

{ Fsm, ToolShed } = require \MachineShop
{ Debug, _, Config } = ToolShed

#peom_db = new PublicDB name: \poem
#affinaty_db = new PublicDB name: \affinaty

svc_name = process.env.SVC_NAME || Path.basename(__filename).split '.' .0
debug = Debug "Service(#{svc_name})"

process.on \uncaughtException (err) ->
	debug "uncaughtException %s", err.stack

pubdb_proxy = HttpProxy.createProxyServer target: 'http://127.0.0.1:1111'
dnode_proxy = HttpProxy.createProxyServer target: 'ws://127.0.0.1:1133' ws: true

fs_DB = new GridFS \fs
img_DB = new GridFS \img

#TODO: remove the dependency on GridFS -- actually, just convert it in js2ls
#switch to koa
# use the following:
# https://npmjs.org/package/koa-resource

# implement stylecow to remove styles not used in certain browsers.
# save each one as a distinct version (if there is no difference)
# http://oscarotero.github.io/stylecow-node/

# have a look at this for vhosts
# https://github.com/hufyhang/nover


readFile = Thunkify(Fs.readFile)
these_dirs = <[theme node_modules build doc lib mode less third_party]>

app = Express!
for i in these_dirs
	app.use '/'+i, Express.static Path.join __dirname, \.. \.., i
#app.use Express.cookieParser \lala
app.use (req, res, next) ->
	url = req.url
	debug "req.url %s", url
	console.log "host:", req.host
	is_static = 0
	for i in these_dirs
		if url.indexOf(i) is 0
			is_static++
			break
	if is_static
		console.error "kkkk 404", req.url
		res.status 404
		res.end "404!"
	else if url is \/file-upload
		#parts = yield* Multipart req#, (err, parts) ->
		(Co ->*
			parts = yield from Multipart req #, concurrency: 1
			converted = {}
			for file in parts.files
				buf = yield readFile file.path
				console.log "read file #{file.path}", buf, buf.length
				sha1 = Crypto.createHash \sha1
				sha1.update jpg_buf = ImageMagick.convert {
					srcData: buf
					width: 256
					height: 256
					quality: 80
					format: \JPEG
					resizeStyle: \aspectfit
					debug: 1
				}
				sha1_hex = sha1.digest \hex
				sha1_b58 = Base58.encode new Buffer sha1_hex, \hex
				console.log "writing #{sha1_b58} to gridfs"
				#yield Thunkify(img_DB.put).call img_DB, jpg_buf, sha1_b58, \w, (err, res) -> console.log "put", &

				converted[sha1_b58] = jpg_buf
				#res.end sha1_b58
				#return sha1_b58
			parts.dispose!
			return converted
		) (err, converted) ->
			if err then console.log err.stack
			#res.end converted.0
			#sha1_b58 = converted
			_.each converted, (jpg_buf, sha1_b58) ->
				console.log "putting", sha1_b58, jpg_buf.length
				img_DB.put jpg_buf, sha1_b58, \w, {content_type: 'image/jpeg'}, (err, meta) ->
					console.log "put", err, meta
					res.end sha1_b58

	else if url.substr(0, 4) is '/uV/'
		console.log "UniVerse func!"

	else if url.substr(0, 3) is '/i/'
		#rs = GridStream.createGridReadStream \img,
		console.log "looking for:", url.substr(3)
		img_DB.get url.substr(3), (err, data) ->
			console.log "data:", err, data
			console.log "data:", &
			res.set 'Content-Type', 'image/jpeg'
			res.end data
	else if url.substr(0, 6) is \/poem/
		# this is a poem
		# I should be getting ths out of the database
		poem_url = url.substr 6
		if ~(i = poem_url.indexOf '/')
			poem_path = poem_url.substr i
			poem_name = poem_url.substr 0, i-1
		else
			poem_name = poem_path
			poem_path = '/'
		console.log "requesting a poem:", poem_name, "path:", poem_path

		#TODO: get this from the database...
	else if url.substr(0, 7) is '/build/'
		# what time is it? k-breezy. k-breezy? kay-breeezy!
		suburl = url.substr 7
		# just doo'n what I do
		if suburl is 'blueshift.js'
			console.log "bundling..."
			b = Browserify {
				require:
					http: \http-browserify
			}
			b.on \error (err) ->
				console.log "browserify error", err
			b.add './blueshift.js'
			bundle = b.bundle!
			bundle.on \error (err) ->
				console.log "bundle error:", err
				# res.status 500
				# res.end JSON.stringify {err}
				next err
			# bundle.pipe process.stdout
			bundle.pipe res
		else next!
	else if url.substr(0, 7) is '/dnode/'
		console.log "we have a dnode...."
		suburl = url.substr 7
		# req.url = "/dev/PublicDB-0.0.1/" + suburl
		req.headers.host = 'localhost:9999'
		dnode_proxy.web req, res, (err) ->
			console.log "dnode error", err.stack
		# next!
	else if url.substr(0, 4) is '/db/'
		suburl = url.substr 4
		# this is for dev...
		# req.url = "/dev/PublicDB-0.0.1/" + suburl
		req.url = "/PublicDB/" + suburl
		req.headers.host = 'localhost:1111'
		console.log "suburl: '#suburl'"
		if suburl.substr(0, 4) is '_bp/'
			console.log "we are request a bp:", suburl.substr 4
		pubdb_proxy.web req, res, (err) ->
			console.log "error", err.stack
		/*
		rereq_options = {
			host: 'localhost'
			port: 1111
			method: req.method
			path: pubdb_url
		}
		rereq = Http.request rereq_options, (err, rereq_res) ->
			console.log "response", rereq_res
			if err
				throw err
			res.pipe rereq_res
		rereq.pipe req
		*/
	else if url is '/' or true
		res.end """
		<!DOCTYPE html>
		<html lang="en">
			<head>
				<meta charset="utf-8"/>
				<title>SUUUPER SECRET</title>
				<link rel="stylesheet" href="/lib/codemirror.css">
				<meta name="viewport" content="width=device-width, initial-scale=1.0">
				<script src="/lib/loader.js"></script>
				<script src="/lib/codemirror.js"></script>
				<!-- script src="/lib/blueshift.js"></script -->
				<script src="/node_modules/Current/jive.js"></script>
				<script src="/mode/livescript/livescript.js"></script>
				<script src="/build/component.js"></script>
				<script src="/build/bootstrap/assets/js/jquery.js"></script>
				<script src="/build/bootstrap/assets/js/holder.js"></script>
				<script src="/build/bootstrap/dist/js/bootstrap.js"></script>
				<!--script src="https://login.persona.org/include.js"></script-->
				<!--script src="/third_party/tty.js/static/term.js"></script -->
				<script src="/third_party/term.js/src/term.js"></script>
				<!--script src="/third_party/tty.js/static/tty.js"></script -->
				<style>
				</style>
				<!-- link rel="stylesheet" href="/doc/docs.css" -->
				<link rel="stylesheet" href="/theme/solarized.css">
				<link rel="stylesheet" href="/build/component.css">
				<!-- link rel="stylesheet" type="text/css" href="/build/bootstrap/dist/css/bootstrap.css" -->
				<!--link rel="stylesheet/less" type="text/css" href="/build/bootstrap/less/bootstrap.less"-->
				<link rel="stylesheet/less" type="text/css" href="/less/affinaty.less">
				<script type="text/javascript">
				less = {
						env: "development", // or "production"
						async: false,       // load imports async
						fileAsync: false,   // load imports async when in a page under
																// a file protocol
						poll: 1000,         // when in watch mode, time in ms between polls
						functions: {},      // user functions, keyed by name
						dumpLineNumbers: "all", // or "mediaQuery" or "all"
						relativeUrls: true,// whether to adjust url's to be relative
																// if false, url's are already relative to the
																// entry less file
						//rootpath: "http://localhost:1111/"// a path to add on to the start of every url
																//resource
				};
				</script>
				<script src="/node_modules/less/dist/less-1.4.2.js"></script>
			</head>
			<body>
				<script src="/third_party/mousetrap/mousetrap.js"></script>
				<script src="/build/blueshift.js"></script>
				<script>
				</script>
			</body>
		</html>
		"""
		#Path.basename poem_url
		#ToolShed.stat poem_url, (err, st) ->
		#	if not err and st.isDirectory!
		#		console.log "poem index"
	else if url is \/loading =>
		res.end """
		<!DOCTYPE html>
		<html lang="en">
			<head>
				<meta charset="utf-8"/>
				<title>loading...</title>
				<link rel="stylesheet" href="lib/codemirror.css">
				<meta name="viewport" content="width=device-width, initial-scale=1.0">
				<script src="lib/loader.js"></script>
				<script src="build/component.js"></script>
				<script src="build/bootstrap/assets/js/jquery.js"></script>
				<script src="build/bootstrap/dist/js/bootstrap.js"></script>
				<style>
				</style>
				<link rel="stylesheet" href="doc/docs.css">
				<link rel="stylesheet" href="theme/solarized.css">
				<link rel="stylesheet" href="build/component.css">
				<link rel="stylesheet" type="text/css" href="build/bootstrap/dist/css/bootstrap.css">
			</head>
			<body>
				<script>
					#{Fs.readFileSync Path.join __dirname, 'loading.js'}
					console.log('hello from loading');
					$(document).ready(function($) {
						console.log('jquery ready', spinner)
					});
				</script>
			</body>
		</html>
		"""
	else if url is \/dev =>
		# TODO: make this handlebars
		f = Fs.readFileSync Path.join(__dirname, \.. "index.html"), 'utf-8'
		res.end f + ''
	else
		console.error "kkkk 404", req.url
		res.status 404
		res.end "404!"

# http://brainwallet.org/ - js btc wallet creator

Browserify ''
# app.use Enchilada {
# 	src: __dirname
# }

server = Http.createServer app
process.env.PORT = process.env.PORT || 1155
port = process.env.PORT
server.on \upgrade (req, socket, head) ->
	dnode_proxy.ws req, socket, head

app_listen = ->
	console.log "going to try to listen on", port
	server.listen port

process.on \exit ->
	server.close ->
		debug "stopped accepting connections on #port"
	debug "closing http down"

server.on \error (err) ->
	console.error "http error", err, app.listening
	if err.code is \EADDRINUSE and not app.listening
		setTimeout app_listen, 1000

server.on \listening ->
	console.log "#{svc_name}: listening on port #port"
	app.listening = true
	if process.send
		process.send {
			type: \ready
			port: port
		}

sock = Shoe (stream) ->
	d = Dnode {
		require: (v, cb) ->
			cb v.toUpperCase!
	}
	d.pipe stream .pipe d
console.log "install into /dnode"
sock.install app, '/dnode'

last_ping = Date.now!

process.on \message (msg) ->
	#debug "got message:%s data:%O", msg.type, msg
	if msg is \ping
		last_ping := Date.now!

setInterval ->
	if process.send
		diff = Date.now! - last_ping
		if diff > 6000
			last_ping.i++
		else last_ping.i = 0

		if last_ping.i >= 2
			debug "killing myself"
			debug "last_ping %d", diff
			processlas.exit 0
, 2000

/*
console.log '9faae0df7df55b2a3b943ba78a0e5d1e9684a583'
console.log Base58.encode new Buffer '9faae0df7df55b2a3b943ba78a0e5d1e9684a583', \hex


console.log "reading file..."
Fs.readFile "/var/folders/h7/497s2bm17p13mtl3zjzn9j7c0000gn/T/88514-11dfhrs.jpg", (err, buf) ->
	console.log "read file", err, buf
	sha1 = Crypto.createHash \sha1
	sha1.update jpg_buf = ImageMagick.convert {
		srcData: buf
		width: 256
		#height: 256
		quality: 80
		format: \JPEG
		resizeStyle: \aspectfit
		debug: 1
	}

	sha1_hex = sha1.digest \hex
	sha1_b58 = Base58.encode new Buffer sha1_hex, \hex
	Fs.writeFile filename = "#{sha1_b58}.jpg", jpg_buf, (err) ->
		console.log "wrote #filename", err
*/

# config_path = Path.join ToolShed.HOME_DIR, ".UniVerse", "UniVerse.json"
# config = Config config_path, {
# 	domains:
# 		'dev.sandrafeltes.com':
# 			poem: "Sandra@latest"
# }

# config.on \ready ->
# 	console.log "UniVerse config ready!"
# 	for domain, c in config.domains
# 		console.log "domain: #{domain}", c
app_listen!
