$(document).ready(function($) {
	// these are all the modules that I will need included from npm (later, add tis to be a part of the universe browserfy instance)
	// add these modules:
	// * [deAMDify](https://github.com/jaredhanson/deamdify) - translate AMD modules
	// to Node-style modules automatically
	// * [debowerify](https://github.com/eugeneware/debowerify) - use
	// [bower](http://bower.io) client packages more easily with browserify.
	// * [decomponentify](https://github.com/eugeneware/decomponentify) - use
	// [component](https://github.com/component/component) client packages seamlessly
	// with browserify.

	// TODO: make this specific to each poem and only has the required deps
	require('path-to-regexp');
	// require('./lala-components/icropper/icropper');

	console.log("gonna init soon...")
	setTimeout(function() {
		console.log("gonna init...")
		blueshift = require('./lib/init');
		blueshift.init({window: window, '$': $, require: require})
	}, 30)
});