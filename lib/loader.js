
function aC(el, els, idx) {
	if(!el) {
		//el = document.getElementsByTagName('body')[0];
		el = document.body;
	}
	// if(els && typeof els.className === 'string' && ~els.className.indexOf('Poem Affinaty'))
	// 	debugger;
	switch(typeof els) {
		case 'string':
		case 'number':
		case 'boolean':
			if(els !== '') {
				els = document.createTextNode(els)
				el.appendChild(els);
			}
			break;
		break;
		case 'function':
			// DEBUG
			//try {throw new Error('m')} catch(e) {
			//	loading = cE('div', 0, "loading in progres,,,s", e.stack);
			//}
			//TODO: only do the loading box when the stack depth is large
			return aC.call(this, el, els.call(el, cE));
			/*
			loading = cE('div', {c: 'loading'}, "loading...");
			//el.appendChild(loading);
			aC(el, loading, idx);
			aC.next(function(p, c, i, l, scope) {
				return function() {
					while(typeof c === 'function') {
						c = c.call(scope, p);
					}
					if(l.parentNode) p.removeChild(l);
					var df = document.createDocumentFragment();
					aC.call(scope, df, c, i);
					console.log("p.replaceChild(df, l)", p, df, l)
					//p.replaceChild(df, l);
					//debugger
					p.insertBefore(df, l);
					p.deleteNode(l);
				}
			} (el, els, idx, loading, this));
			return el;
			*/
		case 'object':
			var fn;
			// if(typeof els.get === 'function') {
			// 	return aC(el, els.get());
			// }
			if(typeof (fn = els._render) === 'function') {
				//console.log('calling render func', els);
				return aC(el, fn.call(els, cE), idx);
			}

			if(typeof (fn = els.appendChild) === 'function') {
				if(typeof fn !== 'function') {
					//console.error('el', el, typeof el.appendChild, els)
					return
				}
				//var i = el;
				//while(i && i.parentNode) i = i.parentNode;
				//console.log("::::inserting", idx, i)
				// if(els.className && ~els.className.indexOf('password')) debugger
				try {
					if(typeof idx === 'undefined') {
						el.appendChild(els);
					} else {
						el.insertBefore(els, el.childNodes[idx]);
					}
				} catch(e) {
					console.error(el, els, idx)
					console.error("funkiness!!!", e.stack)
				}
			} else if(els.length >= 0) {
				if(els.length)for(var i = 0, df = document.createDocumentFragment(); i < els.length; i++) {
					aC(df, els[i]);
				}
				// someday, maybe cache this and do df.cloneNode(true)
				aC(el, df, idx);
			} else {
				debugger
				console.log("edge case:", els, "->", el)
			}
	}
	return el;
}
aC.cb = []
aC.id = null
aC.next = function(fn) {
	if(typeof fn === 'function') {
		aC.cb.push(fn);
	}
	if(aC.cb.length && !aC.id) {
		aC.id = setTimeout(function(f) {
			return function() {
				f();
				aC.id = null
				aC.next();
			};
		}(aC.cb.shift()), 0);
	}
}

function rC(el) {
	if(!el) {
		el = document.body;
	}
	var e, _el = el;
	while(e = _el.lastChild) {
		_el.removeChild(e);
	}
	if(arguments.length > 1)
		aC.apply(this, arguments);
}

function cE(type, opts) {
	var e = document.createElement(type),
		holder = false,
		args = arguments,
		len = args.length;

	if(typeof opts === 'object' && opts !== null) {
		for(var i in opts) {
			var v = opts[i];
			if(typeof v !== 'undefined') switch(i) {
				case "c":
				case "class":
					e.className = (typeof(v.join) === 'function') ? v.join(' ') : v;
				break;
				case "data":
				for(var k in v) {
					//e.setAttribute('data-'+k, v[k]);
					e.dataset[k] = v[k];
					if(k === 'src' && v[k].indexOf('holder.js') === 0) holder = true
				}
				break;
				// I forget why I have this here... it's for bootstrap??
				case "aria":
				for(var k in v) {
					e.setAttribute('aria-'+k, v[k]);
				}
				break;
				case "for":
					e.htmlFor = v;
				break;
				case "s":
				case "style":
					e.style.cssText = v;
				break;
				case "t":
				case "template":
					v = SKIN.getTemplate(v);
				case "html":
					e.innerHTML = v;
				break;
				default:
					if(i.indexOf('on') === 0) {
						//console.log("add event listener", e, i, v)
						//if(this instanceof window)
							e.addEventListener(i.substr(2), v);
						// else
						// 	e.addEventListener(i.substr(2), _.bind(v, this));
					} else {
						e[i] = v;
					}
			}
		}
	}

	// this is only necessary if I want Holder.js support
	// othorwise, it just takes up CPU if, for example, you have holder and are creating a lot of elements
	var w = window;
	if(holder && w.Holder && !w.Holder.go) {
		//console.log("run holder")
		w.Holder.go = true;
		setTimeout(function() {
			w.Holder.go = false;
			w.Holder.run();
		}, 10);
	}

	if(len > 1) {
		for(var i = 2; i < len; i++) {
			var a = args[i];
			//while(typeof a === 'function') {
			//	a = a.call(this, e);
			//}
			// console.log("aC", this)
			// if(window.enable_logging)
			// 	console.log("aC", e, a)
			aC.call(this, e, a);
		}
	}

	return e;
}
cE.aC = aC;
cE.rC = rC;



// XXX: this is probably broken now... have a look
// also, go ahead and upgrade it and make an interface to it
// make it a full Fsm
window.component = {
	_load: function(component_json) {
		console.log("installing components... " + component_json);
		console.log("in dir "+ process.cwd());
		var conf;
		try {
			conf = Fs.readFileSync(component_json);
		} catch(e) {
			console.log("could not read components... not installing");
			return
		}

		conf = JSON.parse(conf);
		console.log("conf: "+JSON.stringify(conf))
		var pkgs = conf.dependencies;
		if(!pkgs) return;
		var st, this_st = Fs.statSync(component_json);

		console.log("got here "+component_json_path);
		///*
		try {
			st = Fs.statSync(component_json_path);
		} catch(e) {
			console.log("stat exception"+e)
		}

		function build() {
			console.log("GONNA BUILD")
			var builder = new Builder(odir);
			var start = new Date;
			builder.development();
			builder.copyFiles();
			builder.addLookup(Path.join("build"));
			//console.log('');
			console.log("GONNA BUILD2")
			//if(!future) future = new Future;
			builder.build(function(err, obj){
				if (err) {
					console.log("build error!" + err)
					Component.utils.fatal(err.message);
					//return future.return(err);
				}

				Fs.writeFileSync(css_path, obj.css);
				Fs.utimesSync(css_path, new Date, this_st.mtime);

				var name = typeof conf.name === 'string' ? conf.name : 'component';
				var js = '(function(){\n' + obj.require + obj.js + 'window.component.require = require;\n})();';
				Fs.writeFileSync(js_path, js);
				Fs.utimesSync(js_path, new Date, this_st.mtime);

				/*
				bundle.add_resource({
					type: "js",
					path: "/component.js",
					data: "" + js,
					where: 'client'
				});

				bundle.add_resource({
					type: "css",
					path: "/component.css",
					data: "" + obj.css,
					where: 'client'
				});
				*/

				var duration = new Date - start;
				log('write', js_path);
				log('write', css_path);
				log('js', (js.length / 1024 | 0) + 'kb');
				log('css', (obj.css.length / 1024 | 0) + 'kb');
				log('duration', duration + 'ms');
				console.log();
			});
		}

		if(!st || st.mtime.getTime() !== this_st.mtime.getTime()) {
			contents = Fs.readFileSync(component_json);
			Fs.writeFileSync(component_json_path, contents);
			Fs.utimesSync(component_json_path, new Date, this_st.mtime);

			var dev = true; // XXX: get this from the config
			if(dev && conf.development) {
				pkgs = pkgs.concat(normalize(conf.development));
			}

			conf.remotes = conf.remotes || [];
			conf.remotes.push('https://raw.github.com');

			var install = function(name, version, cb) {
				var i = 0;
				var report = function(pkg, options) {
					options = options || {};
					if(pkg.inFlight) return;
					log('install', pkg.name + '@' + pkg.version);

					pkg.on('error', function(err){
						if (404 != err.status) utils.fatal(err.stack);
						if (false !== options.error) {
							log('error', err.message);
							//process.exit(1);
							if(pkg.name === name) cb(err);
						}
					});

					pkg.on('dep', function(dep){
						log('dep', dep.name + '@' + dep.version);
						report(dep);
					});

					pkg.on('exists', function(dep){
						log('exists', dep.name + '@' + dep.version);
						if(pkg.name === name) cb();
					});

					pkg.on('file', function(file){
						log('fetch', pkg.name + ':' + file);
					});

					pkg.on('end', function(){
						log('complete', pkg.name);
						if(pkg.name === name) cb();
					});
				};
				var pkg = Component.install(name, version, {
					dest: "./build",
					dev: dev,
					remotes: conf.remotes
				});

				report(pkg);
				pkg.install();
			};

			batch = new Batch
			_.each(pkgs, function(url, pkg) {
				var parts = pkg.split('@');
				var name = parts.shift();
				var version = parts.shift() || 'master';
				var rname = pkg.replace('/', '-');
				//TODO: if some time has passed, say 2-3 days, do an update instead of skipping it (for master)
				//TODO: when implementing specific versions, do a version compare here and update if necessary
				//if(Fs.existsSync(Path.join(odir, name))) return;
				batch.push(function(done) {
					install(name, version, done);
				});
			});

			batch.end(function() {
				try {
					Fs.utimesSync(js_path, new Date, new Date);
				} catch(e) {}
				process.nextTick(build);
			});
		} else {
			try {
				st = Fs.statSync(js_path);
			} catch(e) {}
			if(!st || st.mtime.getTime() !== this_st.mtime.getTime()) {
				//TODO: use serve_path to determine the location in the build dir
				build();
			}
		}
	}
}

setTimeout(function() {
	navigator.version= (function(){
			var ua= navigator.userAgent, tem,
			M= ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*([\d\.]+)/i) || [];
			if(/trident/i.test(M[1])){
					tem=  /\brv[ :]+(\d+(\.\d+)?)/g.exec(ua) || [];
					return 'IE '+(tem[1] || '');
			}
			M= M[2]? [M[1], M[2]]:[navigator.appName, navigator.appVersion, '-?'];
			if((tem= ua.match(/version\/([\.\d]+)/i))!= null) M[2]= tem[1];
			return M.join(' ');
	})();
}, 0);

