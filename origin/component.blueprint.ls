# this is pretty basic right now. make it more like the npm one, to automatically fetch the component and build it and stuff
name: \component
implements: \poetry
version: \0.1.0
type \Fixed
this: ->
	if @window and component = @window.component
		return {component}
	else
		throw new Error "your poem does not include component yet. go ahead and add it to the narrator's implementation"
returns: (module) -> @component.require module