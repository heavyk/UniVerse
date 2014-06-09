# bin/arangod -c lib/etc/PublicDB.conf --javascript.dev-app-path poems
# write config to etc/arangod/PublicDB.conf
# symlink to poems here:
# share/arangodb/js/apps/system

sencillo:
	name: "sencillo"
	version: "0.1.0"
	description: "fácilmente!!"
	bundle:
		node: "0.11.13"
		mongo: "2.6.1"
		arango: "2.0"
		# go: "1.2"
	dependencies:
		"GridFS": "^0.3.0"
		"backoff": "^2.3.0"
		"base58-native": "^0.1.4"
		"browserify": "*"
		"co": "^3.0.6"
		"co-multipart": "0.0.2"
		"http-proxy": "^1.1.4"
		"isarray": "0.0.1"
		"shoe": "0.0.15"
		"suspend": "^0.5.1"
		"thunkify": "^2.1.1"
		"traverse": "^0.6.6"
		"node-gyp": "*"
		"tar": "*"
		"request": "*"
	blueprint: 'src/UniVerse.blueprint'
	repos:
		"lib/node_modules/Laboratory":
			upstream: "github://heavyk/Laboratory"
			revision: "master"
		"src/third_party/ArangoDB":
			upstream: "github://triAGENS/ArangoDB"
			revision: "868dfd206b532ce7b90fcc84446720790b9f1ddd"
		'lib/node_modules/MachineShop':
			upstream: "github://heavyk/MachineShop"
			revision: "master"

		'lib/node_modules/deep-is':
			upstream: "github://thlorenz/deep-is"
		'lib/node_modules/fast-levenshtein':
			upstream: "github://hiddentao/fast-levenshtein"
		'lib/node_modules/type-check':
			upstream: "github://gkz/type-check"
		'lib/node_modules/optionator':
			upstream: "github://gkz/optionator"
		'lib/node_modules/levn':
			upstream: "github://gkz/levn"
		'lib/node_modules/prelude-ls':
			upstream: "github://gkz/prelude-ls"
		'lib/node_modules/LiveScript':
			upstream: "github://gkz/LiveScript"
			revision: "934ef45473dc7db143a8c2fd62c6ebfbedd84eec"
		'lib/node_modules/growl':
			upstream: "github://visionmedia/node-growl"
		'lib/node_modules/debug':
			upstream: "github://visionmedia/debug"

		'lib/node_modules/rimraf':
			upstream: "github://isaacs/rimraf"
		'lib/node_modules/semver':
			upstream: "github://isaacs/node-semver"
		'lib/node_modules/inherits':
			upstream: "github://isaacs/inherits"
		'lib/node_modules/fstream':
			upstream: "github://isaacs/fstream"
		'lib/node_modules/readable-stream':
			upstream: "github://isaacs/readable-stream"
		'lib/node_modules/ini':
			upstream: "github://isaacs/ini"
		'lib/node_modules/core-util-is':
			upstream: "github://isaacs/core-util-is"
		'lib/node_modules/graceful-fs':
			upstream: "github://isaacs/node-graceful-fs"
		'lib/node_modules/glob':
			upstream: "github://isaacs/node-glob"
		'lib/node_modules/minimatch':
			upstream: "github://isaacs/minimatch"
		'lib/node_modules/lru-cache':
			upstream: "github://isaacs/node-lru-cache"
		'lib/node_modules/sigmund':
			upstream: "github://isaacs/sigmund"

		'lib/node_modules/shelljs':
			upstream: "github://arturadib/shelljs"
		'lib/node_modules/printf':
			upstream: "github://wdavidw/node-printf"
		'lib/node_modules/eventemitter3':
			upstream: "github://3rd-Eden/EventEmitter3"
		'lib/node_modules/lazystream':
			upstream: "github://jpommerening/node-lazystream"
		'lib/node_modules/zip-stream':
			upstream: "github://ctalkington/node-zip-stream"
		'lib/node_modules/tar-stream':
			upstream: "github://mafintosh/tar-stream"
		'lib/node_modules/buffer-crc32':
			upstream: "github://brianloveswords/buffer-crc32"
		'lib/node_modules/file-utils':
			upstream: "github://SBoudrias/file-utils"
		'lib/node_modules/crc32-stream':
			upstream: "github://ctalkington/node-crc32-stream"
		'lib/node_modules/deflate-crc32-stream':
			upstream: "github://ctalkington/node-deflate-crc32-stream"
		'lib/node_modules/isbinaryfile':
			upstream: "github://gjtorikian/isBinaryFile"
		'lib/node_modules/findup-sync':
			upstream: "github://cowboy/node-findup-sync"
		'lib/node_modules/iconv-lite':
			upstream: "github://ashtuchkin/iconv-lite"
		'lib/node_modules/harmony-reflect':
			upstream: "github://tvcutsem/harmony-reflect"
		'lib/node_modules/mkdirp':
			upstream: "github://substack/node-mkdirp"
		'lib/node_modules/dnode':
			upstream: "github://substack/dnode"
		'lib/node_modules/wordwrap':
			upstream: "github://substack/node-wordwrap"
		'lib/node_modules/Archivista':
			upstream: "github://heavyk/Archivista"
		'lib/node_modules/walkdir':
			upstream: "github://soldair/node-walkdir"
		'lib/node_modules/archiver':
			upstream: "github://ctalkington/node-archiver"
		'lib/node_modules/dnode-protocol':
			upstream: "github://substack/dnode-protocol"
		'lib/node_modules/nan':
			upstream: "github://rvagg/nan"
		'lib/node_modules/weak':
			upstream: "github://TooTallNate/node-weak"
		'lib/node_modules/node-proxy':
			upstream: "github://samshull/node-proxy"
		'lib/node_modules/imagemagick-native':
			upstream: "github://mash/node-imagemagick-native"

		'lib/node_modules/lodash':
			upstream: "github://lodash/lodash"
		'lib/node_modules/less':
			upstream: "github://less/less.js"
		'lib/node_modules/mousetrap':
			upstream: "github://ccampbell/mousetrap"
		'lib/node_modules/term.js':
			upstream: "github://chjj/term.js"

		'src/third_party/bootstrap':
			upstream: "github://twbs/bootstrap"
		'src/third_party/mongo':
			upstream: "github://mongodb/mongo"
			revision: "r2.6.1"
		'src/third_party/node':
			upstream: "github://joyent/node"
			revision: "99c9930ad626e2796af23def7cac19b65c608d18"
#
# install package.json into lib (compiled from src/package.json.ls)
#