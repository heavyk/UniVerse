UniVerse = require '../UniVerse'

# console.log "universe", uV.begin
uV = UniVerse.uV
# uV.exec \narrate \MySuperSite@latest (narrator) ->
uV.exec \begin \UniVerse@latest (narrator) ->
	narrator.once \ready ->
		console.log "we're ready to tell of our experiences now"

console.log "CURRENTLY WORKING ON: getting EtherDB imbuing the Ether correctly and starting the services"