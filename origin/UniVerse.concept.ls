
# charting / graph library
# http://dc-js.github.io/dc.js/

# credit card form
# http://jessepollak.github.io/card/

# split the ssl into a subsystem
# https://github.com/gozdal/accessl/


idea: \UniVerse
version: \0.1.0
type: \Abstract
description: "the origin of everything"
concept:
	Technician:				\concept://Technician
	Project:					\concept://Project
	Library:					\concept://Library
local:
	Fs:								\node://fs
	Path:							\node://path
	Walk:							\npm://walkdir
	# Rimraf:						\npm://rimraf
	# Semver:						\npm://semver
	# Ini:							\npm://ini
	MachineShop:			\npm://MachineShop
	ToolShed:					\npm://MachineShop.ToolShed
	Config:						\npm://MachineShop.Config
# poetry:
# 	Word:
# 		Technician:			\latest
# 		Project:				\latest
embodies:
	* \Idea
	# * \Form
	# * \Creativity
	* \Verse
	* \Interactivity

machina:
	brand: "UniVerse" # (E) -> @name "Affinaty"