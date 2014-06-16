// Generated by LiveScript 1.2.0
var Library, ref$, Fsm, ToolShed, _, Session, out$ = typeof exports != 'undefined' && exports || this;
Library = require('./Library').Library;
ref$ = require('MachineShop'), Fsm = ref$.Fsm, ToolShed = ref$.ToolShed, _ = ref$._;
Session = (function(superclass){
  var prototype = extend$((import$(Session, superclass).displayName = 'Session', Session), superclass).prototype, constructor = Session;
  function Session(refs, key){
    this.refs = refs;
    this.current = {};
    Session.superclass.call(this, "Session(key)");
    this.debug("hello, we are a session. id: %s", key);
  }
  Object.defineProperty(prototype, 'key', {
    get: function(){
      return this.current.key;
    },
    configurable: true,
    enumerable: true
  });
  Object.defineProperty(prototype, 'persona', {
    get: function(){
      return this.current.persona;
    },
    configurable: true,
    enumerable: true
  });
  Object.defineProperty(prototype, 'ident', {
    get: function(){
      return this.current.ident;
    },
    configurable: true,
    enumerable: true
  });
  Object.defineProperty(prototype, 'mun', {
    get: function(){
      if (this.current.now) {
        return this.current.now.mun;
      }
    },
    configurable: true,
    enumerable: true
  });
  Object.defineProperty(prototype, 'poem', {
    get: function(){
      if (this.current.now) {
        return this.current.now.poem;
      }
    },
    configurable: true,
    enumerable: true
  });
  Object.defineProperty(prototype, 'id', {
    get: function(){
      var p;
      if (this.current.now && (p = this.current.now.poem)) {
        return this.current.now[p];
      }
    },
    configurable: true,
    enumerable: true
  });
  Object.defineProperty(prototype, 'now', {
    get: function(){
      return this.current.now || (this.current.now = {});
    },
    configurable: true,
    enumerable: true
  });
  prototype.states = {
    uninitialized: {
      onenter: function(){
        var this$ = this;
        this.debug("do nothing... wait to see whoami");
        return this.exec('persona.whoami', function(err, session){
          var name;
          this$.debug("executed whoami...");
          if (err) {
            name = this$['default'];
            return this$.debug("using default poem: %s", name);
          } else {
            name = this$.current.poem;
            return this$.debug("using session poem: %s", name);
          }
        });
      },
      'persona.whoami': function(cb){
        var this$ = this;
        return $.ajax({
          url: "/db/whoami",
          contentType: "application/json",
          success: function(result){
            this$.current = {
              key: result.key
            };
            if (result.persona) {
              this$.current.persona = result.persona;
              this$.current.now = result.now;
              this$.current.ident = result.ident;
            }
            if (typeof cb === 'function') {
              cb.call(this$, void 8, this$.current);
            }
            return this$.transition(result.persona ? 'authenticated' : 'not_authenticated');
          },
          error: function(res){
            var result;
            result = JSON.parse(res.responseText);
            if (typeof cb === 'function') {
              cb.call(this$, result);
            }
            return this$.transition('not_authenticated');
          }
        });
      }
    },
    authenticated: {
      onenter: function(){
        return this.debug("we're authenticated");
      },
      'mun.set': function(id, cb){
        var this$ = this;
        console.error("TODO");
        return $.ajax({
          url: "/db/whoami",
          type: 'post',
          dataType: 'json',
          data: JSON.stringify({
            mun: id,
            poem: this.refs.book.poem.key
          }),
          contentType: "application/json",
          success: function(result){
            var mun;
            this$.current.now = result;
            if (typeof cb === 'function') {
              cb.call(this$, void 8, result.mun);
            }
            if (mun = this$.mun) {
              return this$.emit('mun', mun);
            } else {
              return this$.emit('!mun');
            }
          },
          error: function(result){
            if (typeof cb === 'function') {
              return cb.call(this$, result);
            }
          }
        });
      },
      'mun.create': function(){
        this.debug.todo("add a function to create a new mun");
        return (function(){
          debugger;
        }());
      },
      'persona.logout': function(cb){
        var this$ = this;
        return $.ajax({
          url: "/db/logout",
          type: 'post',
          dataType: 'json',
          contentType: "application/json",
          success: function(result){
            this$.current = {};
            this$.transition('not_authenticated');
            this$.emit('noauth');
            if (typeof cb === 'function') {
              return cb();
            }
          },
          error: function(err){
            if (typeof cb === 'function') {
              return cb(err);
            }
          }
        });
      }
    },
    not_authenticated: {
      onenter: function(){
        return this.debug("session is ready now");
      },
      'persona.register': function(opts, cb){
        var this$ = this;
        return $.ajax({
          url: "/db/register",
          type: 'post',
          dataType: 'json',
          data: JSON.stringify(opts),
          contentType: "application/json",
          success: function(result){
            var key, persona;
            this$.debug("Welcome %s", result.ident);
            if (result.persona) {
              this$.current.persona = result.persona;
              this$.current.ident = result.ident;
              this$.current.now = result.now;
            }
            if (typeof cb === 'function') {
              cb.call(this$, void 8, this$.current);
            }
            if (key = this$.key) {
              this$.emit('key', key);
            } else {
              this$.emit('!key');
            }
            if (persona = this$.persona) {
              return this$.emit('persona', persona);
            } else {
              return this$.emit('!persona');
            }
          },
          error: function(result){
            this$.current = void 8;
            if (typeof cb === 'function') {
              return cb.call(this$, result);
            }
          }
        });
      },
      'persona.login': function(opts, cb){
        var this$ = this;
        return $.ajax({
          url: "/db/login",
          type: 'post',
          dataType: 'json',
          data: JSON.stringify({
            username: opts.user,
            password: opts.password
          }),
          contentType: "application/json",
          success: function(result){
            var key, persona, mun;
            this$.debug("Welcome %s", result.ident);
            if (result.persona) {
              this$.current.persona = result.persona;
              this$.current.ident = result.ident;
              this$.current.now = result.now;
            }
            if (key = this$.key) {
              this$.emit('key', key);
            } else {
              this$.emit('!key');
            }
            if (persona = this$.persona) {
              this$.emit('persona', persona);
            } else {
              this$.emit('!persona');
            }
            if (mun = this$.mun) {
              this$.emit('mun', mun);
            } else {
              this$.emit('!mun');
            }
            if (typeof cb === 'function') {
              cb.call(this$, void 8, this$.currrent);
            }
            this$.refs.book.emit('auth', this$.current);
            return this$.transition('authenticated');
          },
          error: function(result){
            this$.current = void 8;
            if (typeof cb === 'function') {
              cb.call(this$, result);
            }
            this$.refs.book.emit('noauth', result);
            return this$.transition(this$.initialState);
          }
        });
      }
    }
  };
  return Session;
}(Fsm));
out$.Session = Session;
function extend$(sub, sup){
  function fun(){} fun.prototype = (sub.superclass = sup).prototype;
  (sub.prototype = new fun).constructor = sub;
  if (typeof sup.extended == 'function') sup.extended(sub);
  return sub;
}
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}