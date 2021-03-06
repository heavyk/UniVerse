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
ext = if argv.3 => '.' + argv.3 else '.ls'
# TODO: add // regex support
ToolShed.searchDownwardFor 'package.json', (err, path) ->
	if err => throw err
	files = []
	results = []
	found = 0
	dir = Path.dirname path
	# console.log dir + '\n' + ('=' * dir.length) + '\n'
	walker = Walk dir, {+follow_symlinks}
	walker.on \file, (path, st) ->
		if (path.substr -ext.length) is ext
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
