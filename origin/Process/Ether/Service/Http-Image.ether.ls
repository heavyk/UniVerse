motivation: \Service
implementation: \Http
inception: \Image
possesses:
	* \Origin
	* \Agreement
type: \Mutable
version: \0.1.0
description: "express yourself"
motd:
	* "why don't you hate me? it'd probably be easier, anyway"
poetry:
	Path:					\node://path
	Fs:						\node://fs
	Http:					\node://http
	Crypto: 			\node://crypto
	Browserify:		\npm://browserify
	Express:			\npm://express
	GridFS:				\npm://GridFS.GridFS
	# GridStream:		\npm://GridFS.GridStream
	ImageMagick:	\npm://imagemagick-native
	Backoff:			\npm://backoff
	Dnode:				\npm://dnode
	Shoe:					\npm://shoe
	Base58:				\npm://base58-native
	HttpProxy:		\npm://http-proxy
	Thunkify:			\npm://thunkify
	Mime:					\npm://mime
	Multipart:		\npm://co-multipart
	Co:						\npm://co

	ArangoDB:			\Verse://ArangoDB@latest
	MongoDB:			\Verse://MongoDB@latest
	Laboratory:		\Verse://Laboratory@latest
machina:
	initialize: (refs, opts) ->
		console.log "yay! pretty pictures..."