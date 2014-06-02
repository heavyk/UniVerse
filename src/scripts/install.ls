# install

Path = require \path
Fs = require \fs

# _console_log = console.log
# global.console.log = (f) ->
# 	# _console_log "local log...", f, &.length
# 	if f is '@'
# 		try
# 			throw new Error "WOH"
# 		catch e
# 			console.log e.stack
# 	_console_log ...

# child_process = require \child_process
# _spawn = child_process.spawn
# child_process.spawn = (f) ->
# 	# _console_log "local log...", f, &.length
# 	try
# 		console.log "spawn", &.0, &.1
# 		_spawn ...
# 	catch e
# 		console.log "ERROR::::"
# 		console.log e.stack


UniVerse = require '../UniVerse'
{ ToolShed, Fsm } = require \MachineShop
require \shelljs/global

# console.log "universe", uV.begin
uV = UniVerse.uV
uV.exec \begin \Affinaty@latest (narrator) ->
	narrator.once \ready ->
		console.log "we're ready to tell of our experiences now"

console.log "CURRENT: get EtherDB running the services correctly"
return

arango_path = Path.resolve "#{__dirname}/../../third_party/ArangoDB"
node_path = Path.resolve "#{__dirname}/../../third_party/node"
go_path = Path.resolve "#{arango_path}/3rdParty/go-64"

# > check_tool brew-cask brew-cask

# add service: PublicDB
# ./third_party/ArangoDB/bin/arangod -c lib/etc/PublicDB.conf --javascript.dev-app-path poems
# add service: Laboratory
# add service: MongoDB
# add service: Http
# add service: bootstrap-docs

# -------------------------

# if refs.uV ask it for arango's path

console.log "go_path", go_path

class UniVerseInstaller extends Fsm
	(refs) ->
		super "UniVerseInstaller",
			# initialState: \lala

	states:
		uninitialized:
			onenter: ->
				check_tools = (task, tools, cb) ->
					tools = task.branch "check tools"
					for k,v in tools
						if not v or v is \latest or v is \*
							v = k
							tools.push (done) -> @exec \check_tool k, done
						else
							tools.push (done) -> @exec \check_tool k, v, done
						# tools.push (done) -> @exec \check_tool \bison, done
					task.choke (done) ->
						tools.end (err, res) ->
							if typeof cb is \function
								cb err, res
							done err, res

				# tools = @task "check tools"
				# tools.push (done) ->
				task = @task "install Blueshift"
				# task.push (done) -> @exec \check_tool \automake-1.14, \automake, done
				# task.push (done) -> @exec \check_tool \bison, done
				# task.push (done) -> @exec \check_tool \cmake, done
				# task.push (done) -> @exec \check_tool \hg, \mercurial, done
				task.push (done) ->
					if ToolShed.exists go_path
						done!
					else
						ToolShed.exec "hg clone -u release https://code.google.com/p/go #{go_path}", ->
							done!

				check_tools task, {
					"automake-1.14": \automake
					bison: \latest
					cmake: \latest
					hg: \mercurial
				}

				task.choke (done) ->
					console.log "exists" ToolShed.exists Path.join go_path, \bin \go
					if not ToolShed.exists Path.join go_path, \bin \go
						ToolShed.exec "sh all.bash" {cwd: "#{go_path}/src"} (err) ->
							if err
								console.warn "there might be an error in go:", err.message
								console.log "continuing..."
							else
								console.log "ALL INSTALLED"
							done!
					else
						done!

				task.choke (done) ->
					@debug.todo "only compile arango if the revision is different / not configured"
					console.log "arango_path", arango_path
					quick_exec = (cmd, cwd, done) ->
						if typeof cwd is \function
							done = cwd
							cwd = arango_path
						ToolShed.exec cmd, {cwd}, done
					ToolShed.stat Path.join(arango_path, \bin, \arangod), (err, st) ->
						if not err and st.isFile!
							done!
						else
							compile = task.branch "compile ArangoDB"
							# compile.choke (done) -> ToolShed.mkdir arango_path, done
							compile.choke (done) -> quick_exec "automake-1.14 --add-missing", done
							compile.choke (done) -> quick_exec "autoreconf", done
							compile.choke (done) ->
								quick_exec <[ ./configure
									--enable-all-in-one-v8
									--disable-all-in-one-libev
									--enable-all-in-one-icu
									--enable-maintainer-mode
									--enable-internal-go
									--disable-mruby]>join(' '), done
							# compile.choke (done) -> quick_exec "cmake .", done
							compile.choke (done) -> quick_exec "make -j8", done
							compile.end (err) ->
								if err
									@debug "compilation fiAILED	"
									console.log "compilation fiAILED	"
									# throw err

								done err

				task.end (err, res) ->
					console.log "task done..", err, res
					@debug.todo "add priority to todo (add object at beginning)"
					@debug.todo "copy etc file"
					if err
						throw err
					else
						@transition \ready

			check_tool: (tool, tool_name, done) ->
				if typeof tool_name is \function
					done = tool_name
					tool_name = tool

				if path = which tool
					echo "using #{tool} #{path}"
					done null, path
				else
					echo "installing #{tool_name}..."
					@debug.todo "it should adjust to its arch here... brew for osx. apt-get, etc. for linux"
					ToolShed.exec "brew install #{tool_name}", (err) ->
						if err
							throw err
						else
							echo "#{tool_name} installed"
						console.log "done", done
						path = which tool
						done err, path
		ready:
			onenter: ->
				console.log "HOLYYYYY SHIT"
				@debug.todo "start er up"

	cmds:
		update_go: (task, done) ->
			ToolShed.exec "hg pull" {cwd: go_path}, (err, res) ->
				console.log "pull...", err, res
				if err
					done err
				else
					ToolShed.exec "hg update" {cwd: go_path}, (err, res) ->
						console.log "updated...", err, res
						done!

		compile_node: (task, done) ->
			compile = task.branch "compile node"
			compile.choke (done) -> quick_exec node_path, "./configure --prefix=#{UniVerse.UNIVERSE_PATH}", done
		compile_arango: (task, done) ->
			compile = task.branch "compile ArangoDB"
			compile.choke (done) -> quick_exec "cmake .", done
			compile.choke (done) -> quick_exec "automake-1.14 --add-missing", done
			compile.choke (done) -> quick_exec "autoreconf", done
			compile.choke (done) ->
				quick_exec <[ ./configure
					--enable-all-in-one-v8
					--disable-all-in-one-libev
					--enable-all-in-one-icu
					--enable-maintainer-mode
					--enable-internal-go
					--disable-mruby]>join(' '), done
			compile.choke (done) -> quick_exec "make -j8", done
			compile.end (err) ->
				if err
					@debug "compilation fiAILED	"
					console.log "compilation fiAILED	"
					# throw err

				done err

		start: (opts, task, done) ->
			etc-file = (opts = {}) -> """
				[database]
				directory=#{if opts.db-path => Path.relative arango_path, opts.db-path else './db'}
				# maximal-journal-size = 33554432
				# remove-on-drop = true

				[server]
				disable-authentication = true
				endpoint = tcp://#{opts.host || 'localhost'}:#{opts.port || 1111}
				threads = #{opts.server-threads || 3}

				[scheduler]
				threads = #{opts.scheduler-threads || 3}

				[javascript]
				startup-directory = ./js
				action-directory = ./js/actions
				modules-path = ./js/server/modules;./js/common/modules;./js/node;./js/npm/node_modules
				package-path = ./js/npm
				app-path = #{opts.app-path || './js/apps'}

				[log]
				level = info
				severity = human
				"""
			console.log "gonna start..."
			console.log etc-file opts


pdb = new UniVerseInstaller

