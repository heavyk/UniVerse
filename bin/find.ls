#!/usr/bin/env lsc -n --harmony

# grep -Rn "\"out:" `find . -type f  -name '*.ls'`

argv = process.argv

require \shelljs/global

Path = require \path
Fs = require \fs
Walk = require \walkdir
SliceFile = require \slice-file
# TODO: Optionator = require \optionator
{ ToolShed } = require \MachineShop

# woah, check this out:
# https://github.com/gkz/grasp
find = argv.2
# TODO: add // regex support
ToolShed.searchDownwardFor 'package.json', (err, path) ->
	if err => throw err
	files = []
	results = []
	found = 0
	dir = Path.dirname path
	# console.log dir + '\n' + ('=' * dir.length) + '\n'
	walker = Walk dir
	walker.on \file (path, st) ->
		if (path.substr -3) is '.ls'
			line = 1
			emitted_filename = false
			s = (SliceFile path).slice!
			s.on \data (data) !->
				if ~(i = (d = data+'').indexOf find)
					unless emitted_filename
						rpath = path.substr dir.length+1
						console.log '\n' + rpath + '\n' + ('-' * rpath.length)
						emitted_filename := true
					console.log "#line: #{d.trim!}"
					results[rpath+':'+line] = d
					found++
				line++
			files.push path

	walker.on \end ->
		console.log "\nfound '#{argv.2}' #found times in #{files.length} files..."
		# grep argv.2, files


# if argv.length is 4
# 	do_hardlinks argv.2, argv.3
# else
# 	console.log "#{Path.basename argv.1} [srcdir] [destdir]"