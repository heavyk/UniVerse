#!/usr/bin/env lsc -n --harmony

argv = process.argv

require \shelljs/global

Path = require \path
Fs = require \fs
Walk = require \walkdir
# TODO: Optionator = require \optionator
{ ToolShed } = require \MachineShop

# woah, check this out:
# https://github.com/gkz/grasp

# TODO: do_git_hardlinks (only if the file is in git)
do_hardlinks = (input, output) ->
	if (input.substr -1) is '/'
		input = Path.resolve input
		walker = Walk input
		walker.on \directory (path) ->
			console.log "a directory!!"
			console.log path.indexOf input
			do_hardlinks path, output + (path.substr input.length+1)
		return

	if (output.substr -1) is '/'
		called = Path.basename input
		output = Path.join output, called

	input = Path.resolve input
	output = Path.resolve output
	ToolShed.mkdir output, (err) ->
		if err
			throw err
		walker = Walk input, {+no_recurse}, (path, st) ->
			src = path.substr input.length+1
			dest = Path.join output, src
			basename = Path.basename path
			if st.isFile!
				src = path.substr input.length+1
				dest = Path.join output, src
				Fs.link path, dest, (err) ->
				if err and err.code isnt \EEXIST
					throw err
				console.log "#src -> #dest"
			else if st.isDirectory!
				do_hardlinks path, dest
			# else
			# 	console.log "we have something else", path, st

		# Walk

if argv.length is 4
	do_hardlinks argv.2, argv.3
else
	console.log "#{Path.basename argv.1} [srcdir] [destdir]"