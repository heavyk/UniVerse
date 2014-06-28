# bin/arangod -c lib/etc/PublicDB.conf --javascript.dev-app-path poems
# write config to etc/arangod/PublicDB.conf
# symlink to poems here:
# share/arangodb/js/apps/system


effortless:
	name: "effortless"
	version: "0.1.0"
	description: "an effortless UniVerse"
	bundle:
		"node": "0.10.28"
		"atom-shell": "0.13.0"

UniVerse:
	name: \UniVerse
	version: \0.1.0
	description: "communicate your ideas easily with poem and verse"
	motd:
		* "we're all singing the same song anyway"
	bundle:
		node:
			* \0.11.13
			* \0.10.28
		dependencies:
			"prompt": "0.2.13"
sencillo:
	name: "sencillo"
	version: "0.1.0"
	description: "fácilmente!!"
	bundle:
		"node": "0.11.13"
		"mongo": "2.6.1"
		"arango": "2.1.2"
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
	blueprint: "src/UniVerse.blueprint"
	# not yet implemented. will do shortly
	prepare: (prepare_done) ->
		task = @task 'prepare a UniVerse'
		# task.push (done) -> @exec \hardlink \src, "#{@PATH}/src", done
		# task.push (done) -> @exec \hardlink \origin, "#{@PATH}/origin", done
		# task.push (done) -> @exec \hardlink \node_modules/LiveScript, "#{@PATH}/node_modules/", done
		# task.push (done) -> @exec \hardlink \node_modules/harmony-reflect, "#{@PATH}/node_modules/", done
		# task.push (done) -> @exec \hardlink \node_modules/MachineShop, "#{@PATH}/node_modules/", done
		# task.push (done) -> @exec \hardlink \node_modules/growl, "#{@PATH}/node_modules/", done
		# task.push (done) -> @exec \hardlink \node_modules/prelude-ls, "#{@PATH}/node_modules/", done
		# task.push (done) -> @exec \hardlink \node_modules/lodash, "#{@PATH}/node_modules/", done
		# task.push (done) -> @exec \hardlink \node_modules/mkdirp, "#{@PATH}/node_modules/", done
		# task.push (done) -> @exec \hardlink \node_modules/walkdir, "#{@PATH}/node_modules/", done
		# task.push (done) -> @exec \hardlink \node_modules/semver, "#{@PATH}/node_modules/", done
		# task.push (done) -> @exec \hardlink \node_modules/rimraf, "#{@PATH}/node_modules/", done
		# task.push (done) -> @exec \hardlink \node_modules/printf, "#{@PATH}/node_modules/", done
		# task.push (done) -> @exec \hardlink \node_modules/eventemitter3, "#{@PATH}/node_modules/", done
		# task.push (done) -> @exec \hardlink \node_modules/postal, "#{@PATH}/node_modules/", done
		# task.push (done) -> @exec \hardlink \node_modules/deep-diff, "#{@PATH}/node_modules/", done
		# task.push (done) -> @exec \hardlink \multiverse.json, "#{@PATH}/multiverse.json", done
		# task.push (done) -> @exec \hardlink \verse.js, "#{@PATH}/verse.js", done
		# task.push (done) -> @exec \hardlink \install_salt.sh "#{@PATH}/", done
		task.push (done) -> @exec \hardlink \patches "#{@PATH}/", done
		task.end (err, res) ->
			console.log "prepare task done....", err, res
			prepare_done!
	Dockerfile:
		* 'FROM ubuntu:latest'
		# * 'FROM mechanicofthesequence:base'
		* 'MAINTAINER Kenneth Bentley "mechanicofthesequence@gmail.com"'

	# TODO: commit this to mechanicofthesequence/base

	# this is a direct ripoff of boot2docker...
		* 'ENV KERNEL_VERSION  3.14.1'
		* 'ENV AUFS_BRANCH     aufs3.14'

		* 'RUN apt-get update'
		* 'RUN apt-get dist-upgrade -y'
		* 'RUN apt-get install build-essential curl wget git-remote-gcrypt python -y'
		# * 'RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /depot_tools'
		# * 'ENV PATH $PATH:/depot_tools'
		* 'RUN git clone https://github.com/busterb/libressl.git /opt/libressl'
		# FIXME: remove boost bison and flex
		* 'RUN apt-get install --no-install-recommends -y ghc automake bison libboost1.55-all-dev flex dh-autoreconf'
		* 'WORKDIR /opt/libressl'
		* 'RUN ./autogen.sh'
		* 'RUN ./configure --prefix=/usr/'
		* 'RUN make -j8'
		# * 'RUN apt-get purge openssl libssl-dev -y'
		* 'RUN make install'
		* 'RUN git clone https://github.com/joyent/node.git /opt/node'
		* 'WORKDIR /opt/node'
		* 'RUN git checkout v0.10.28'
		* 'RUN ./configure'
		* 'RUN make -j8 install'



	# RUN mkdir /opt/Blueshift && \\
	#     cd /opt/Blueshift && \\
	#     repo init -u https://github.com/duralog/Blueshift.git \\
	#       --repo-url https://github.com/duralog/repo.git \\
	#       --no-repo-verify --depth=1
	# RUN cd /opt/Blueshift && repo sync

		# * 'ADD src /opt/Blueshift/src'
		# * 'ADD origin /opt/Blueshift/origin'
		# * 'ADD node_modules /opt/Blueshift/node_modules'
		# * 'WORKDIR /opt/Blueshift'
		# # * RUN npm install rvagg/node-leveldown#0.11-wip
		# # * RUN npm install npmd

		# # -- do not modify above --
		# * 'COPY verse.js /opt/Blueshift/'
		# * 'COPY multiverse.json /opt/Blueshift/'
		# * 'COPY install_salt.sh /opt/'

		# * 'RUN node --harmony verse.js'
	# se hace el dockerfile con esto
	local_fs:
		'opt':
			'PublicDB':
				'.git':
					upstream: "github://heavyk/PublicDB"
					revision: "master"
			'git':
				'.git':
					upstream: "github://git/git"
					revision: "v2.0.0"
			'ArangoDB':
				'.git':
					upstream: "github://triAGENS/ArangoDB"
			'mongo':
				'.git':
					upstream: "github://mongodb/mongo"
					revision: "r2.6.1"
			'node':
				'.git':
					upstream: "github://joyent/node"
			'bootstrap':
				'.git':
					upstream: "github://twbs/bootstrap"

		'lib':
			'node_modules':
				'Laboratory':
					'.git':
						upstream: "github://heavyk/Laboratory"
						revision: "master"
				'MachineShop':
					'.git':
						upstream: "github://heavyk/MachineShop"
						revision: "master"
				'mime':
					'.git':
						upstream: "github://broofa/node-mime"
				'deep-is':
					'.git':
						upstream: "github://thlorenz/deep-is"
				'fast-levenshtein':
					'.git':
						upstream: "github://hiddentao/fast-levenshtein"
				'type-check':
					'.git':
						upstream: "github://gkz/type-check"
				'optionator':
					'.git':
						upstream: "github://gkz/optionator"
				'levn':
					'.git':
						upstream: "github://gkz/levn"
				'prelude-ls':
					'.git':
						upstream: "github://gkz/prelude-ls"
				'LiveScript':
					'.git':
						upstream: "github://gkz/LiveScript"
						revision: "934ef45473dc7db143a8c2fd62c6ebfbedd84eec"
				'growl':
					'.git':
						upstream: "github://visionmedia/node-growl"
				'debug':
					'.git':
						upstream: "github://visionmedia/debug"
				'rimraf':
					'.git':
						upstream: "github://isaacs/rimraf"
				'semver':
					'.git':
						upstream: "github://isaacs/node-semver"
				'inherits':
					'.git':
						upstream: "github://isaacs/inherits"
				'fstream':
					'.git':
						upstream: "github://isaacs/fstream"
				'readable-stream':
					'.git':
						upstream: "github://isaacs/readable-stream"
				'ini':
					'.git':
						upstream: "github://isaacs/ini"
				'core-util-is':
					'.git':
						upstream: "github://isaacs/core-util-is"
				'graceful-fs':
					'.git':
						upstream: "github://isaacs/node-graceful-fs"
				'glob':
					'.git':
						upstream: "github://isaacs/node-glob"
				'minimatch':
					'.git':
						upstream: "github://isaacs/minimatch"
				'lru-cache':
					'.git':
						upstream: "github://isaacs/node-lru-cache"
				'sigmund':
					'.git':
						upstream: "github://isaacs/sigmund"
				'shelljs':
					'.git':
						upstream: "github://arturadib/shelljs"
				'printf':
					'.git':
						upstream: "github://wdavidw/node-printf"
				'eventemitter3':
					'.git':
						upstream: "github://3rd-Eden/EventEmitter3"
				'lazystream':
					'.git':
						upstream: "github://jpommerening/node-lazystream"
				'zip-stream':
					'.git':
						upstream: "github://ctalkington/node-zip-stream"
				'tar-stream':
					'.git':
						upstream: "github://mafintosh/tar-stream"
				'buffer-crc32':
					'.git':
						upstream: "github://brianloveswords/buffer-crc32"
				'file-utils':
					'.git':
						upstream: "github://SBoudrias/file-utils"
				'crc32-stream':
					'.git':
						upstream: "github://ctalkington/node-crc32-stream"
				'deflate-crc32-stream':
					'.git':
						upstream: "github://ctalkington/node-deflate-crc32-stream"
				'isbinaryfile':
					'.git':
						upstream: "github://gjtorikian/isBinaryFile"
				'findup-sync':
					'.git':
						upstream: "github://cowboy/node-findup-sync"
				'iconv-lite':
					'.git':
						upstream: "github://ashtuchkin/iconv-lite"
				'harmony-reflect':
					'.git':
						upstream: "github://tvcutsem/harmony-reflect"
				'mkdirp':
					'.git':
						upstream: "github://substack/node-mkdirp"
				'dnode':
					'.git':
						upstream: "github://substack/dnode"
				'wordwrap':
					'.git':
						upstream: "github://substack/node-wordwrap"
				'Archivista':
					'.git':
						upstream: "github://heavyk/Archivista"
				'walkdir':
					'.git':
						upstream: "github://soldair/node-walkdir"
				'archiver':
					'.git':
						upstream: "github://ctalkington/node-archiver"
				'dnode-protocol':
					'.git':
						upstream: "github://substack/dnode-protocol"
				'nan':
					'.git':
						upstream: "github://rvagg/nan"
				'weak':
					'.git':
						upstream: "github://TooTallNate/node-weak"
				'node-proxy':
					'.git':
						upstream: "github://samshull/node-proxy"
				'imagemagick-native':
					'.git':
						upstream: "github://mash/node-imagemagick-native"

				'deep-diff':
					'.git':
						upstream: "github://flitbit/diff"
				'lodash':
					'.git':
						upstream: "github://lodash/lodash"
				'less':
					'.git':
						upstream: "github://less/less.js"
				'mousetrap':
					'.git':
						upstream: "github://ccampbell/mousetrap"
				'term.js':
					'.git':
						upstream: "github://chjj/term.js"

	repos:
		"lib/node_modules/Laboratory":
			upstream: "github://heavyk/Laboratory"
			revision: "master"
		# "lib/node_modules/MachineShop":
		# 	upstream: "github://heavyk/MachineShop"
		# 	revision: "master"
		# "opt/PublicDB":
		# 	upstream: "github://heavyk/PublicDB"
		# 	revision: "master"

		# "lib/node_modules/mime":
		# 	upstream: "github://broofa/node-mime"
		# "lib/node_modules/deep-is":
		# 	upstream: "github://thlorenz/deep-is"
		# "lib/node_modules/fast-levenshtein":
		# 	upstream: "github://hiddentao/fast-levenshtein"
		# "lib/node_modules/type-check":
		# 	upstream: "github://gkz/type-check"
		# "lib/node_modules/optionator":
		# 	upstream: "github://gkz/optionator"
		# "lib/node_modules/levn":
		# 	upstream: "github://gkz/levn"
		# "lib/node_modules/prelude-ls":
		# 	upstream: "github://gkz/prelude-ls"
		# "lib/node_modules/LiveScript":
		# 	upstream: "github://gkz/LiveScript"
		# 	revision: "934ef45473dc7db143a8c2fd62c6ebfbedd84eec"
		# "lib/node_modules/growl":
		# 	upstream: "github://visionmedia/node-growl"
		# "lib/node_modules/debug":
		# 	upstream: "github://visionmedia/debug"

		# "lib/node_modules/rimraf":
		# 	upstream: "github://isaacs/rimraf"
		# "lib/node_modules/semver":
		# 	upstream: "github://isaacs/node-semver"
		# "lib/node_modules/inherits":
		# 	upstream: "github://isaacs/inherits"
		# "lib/node_modules/fstream":
		# 	upstream: "github://isaacs/fstream"
		# "lib/node_modules/readable-stream":
		# 	upstream: "github://isaacs/readable-stream"
		# "lib/node_modules/ini":
		# 	upstream: "github://isaacs/ini"
		# "lib/node_modules/core-util-is":
		# 	upstream: "github://isaacs/core-util-is"
		# "lib/node_modules/graceful-fs":
		# 	upstream: "github://isaacs/node-graceful-fs"
		# "lib/node_modules/glob":
		# 	upstream: "github://isaacs/node-glob"
		# "lib/node_modules/minimatch":
		# 	upstream: "github://isaacs/minimatch"
		# "lib/node_modules/lru-cache":
		# 	upstream: "github://isaacs/node-lru-cache"
		# "lib/node_modules/sigmund":
		# 	upstream: "github://isaacs/sigmund"

		# "lib/node_modules/shelljs":
		# 	upstream: "github://arturadib/shelljs"
		# "lib/node_modules/printf":
		# 	upstream: "github://wdavidw/node-printf"
		# "lib/node_modules/eventemitter3":
		# 	upstream: "github://3rd-Eden/EventEmitter3"
		# "lib/node_modules/lazystream":
		# 	upstream: "github://jpommerening/node-lazystream"
		# "lib/node_modules/zip-stream":
		# 	upstream: "github://ctalkington/node-zip-stream"
		# "lib/node_modules/tar-stream":
		# 	upstream: "github://mafintosh/tar-stream"
		# "lib/node_modules/buffer-crc32":
		# 	upstream: "github://brianloveswords/buffer-crc32"
		# "lib/node_modules/file-utils":
		# 	upstream: "github://SBoudrias/file-utils"
		# "lib/node_modules/crc32-stream":
		# 	upstream: "github://ctalkington/node-crc32-stream"
		# "lib/node_modules/deflate-crc32-stream":
		# 	upstream: "github://ctalkington/node-deflate-crc32-stream"
		# "lib/node_modules/isbinaryfile":
		# 	upstream: "github://gjtorikian/isBinaryFile"
		# "lib/node_modules/findup-sync":
		# 	upstream: "github://cowboy/node-findup-sync"
		# "lib/node_modules/iconv-lite":
		# 	upstream: "github://ashtuchkin/iconv-lite"
		# "lib/node_modules/harmony-reflect":
		# 	upstream: "github://tvcutsem/harmony-reflect"
		# "lib/node_modules/mkdirp":
		# 	upstream: "github://substack/node-mkdirp"
		# "lib/node_modules/dnode":
		# 	upstream: "github://substack/dnode"
		# "lib/node_modules/wordwrap":
		# 	upstream: "github://substack/node-wordwrap"
		# "lib/node_modules/Archivista":
		# 	upstream: "github://heavyk/Archivista"
		# "lib/node_modules/walkdir":
		# 	upstream: "github://soldair/node-walkdir"
		# "lib/node_modules/archiver":
		# 	upstream: "github://ctalkington/node-archiver"
		# "lib/node_modules/dnode-protocol":
		# 	upstream: "github://substack/dnode-protocol"
		# "lib/node_modules/nan":
		# 	upstream: "github://rvagg/nan"
		# "lib/node_modules/weak":
		# 	upstream: "github://TooTallNate/node-weak"
		# "lib/node_modules/node-proxy":
		# 	upstream: "github://samshull/node-proxy"
		# "lib/node_modules/imagemagick-native":
		# 	upstream: "github://mash/node-imagemagick-native"

		# "lib/node_modules/deep-diff":
		# 	upstream: "github://flitbit/diff"
		# "lib/node_modules/lodash":
		# 	upstream: "github://lodash/lodash"
		# "lib/node_modules/less":
		# 	upstream: "github://less/less.js"
		# "lib/node_modules/mousetrap":
		# 	upstream: "github://ccampbell/mousetrap"
		# "lib/node_modules/term.js":
		# 	upstream: "github://chjj/term.js"

		# "opt/third_party/git":
		# 	upstream: "github://git/git"
		# 	revision: "v2.0.0"
		# "opt/third_party/ArangoDB":
		# 	upstream: "github://triAGENS/ArangoDB"
		# "third_party/bootstrap":
		# 	upstream: "github://twbs/bootstrap"
		# "opt/third_party/mongo":
		# 	upstream: "github://mongodb/mongo"
		# 	revision: "r2.6.1"
		# "opt/third_party/node":
		# 	upstream: "github://joyent/node"
bundles:
	node:
		"0.11.13":
			upstream: "github://joyent/node"
			revision: "99c9930ad626e2796af23def7cac19b65c608d18"
		"0.10.28":
			upstream: "github://joyent/node"
			revision: "99c9930ad626e2796af23def7cac19b65c608d18"

#
# install package.json into lib (compiled from src/package.json.ls)
#