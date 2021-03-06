// Generated by LiveScript 1.2.0
var Path, Fs, Growl, ref$, DaFunk, Config, Implementation, Reality, LocalLibrary, Ambiente, UniVerse, to_load, add_growl, amb;
console.log("welcome to verse");
console.log("argv:", process.argv);
console.log("TODO: add verse stuff here");
process.on('uncaughtException', function(err){
  console.error("uncaught error:", err.stack);
  if (err.filename) {
    console.log("error in " + err.filename);
  }
  throw err;
});
Path = require('path');
Fs = require('fs');
Growl = require('Growl');
require('LiveScript');
ref$ = require('MachineShop'), DaFunk = ref$.DaFunk, Config = ref$.Config;
Implementation = require(Path.join(__dirname, 'src', 'Implementation')).Implementation;
Reality = require(Path.join(__dirname, 'src', 'Reality')).Reality;
LocalLibrary = require(Path.join(__dirname, 'src', 'LocalLibrary')).LocalLibrary;
ref$ = require(Path.join(__dirname, 'src', 'Source')), Ambiente = ref$.Ambiente, UniVerse = ref$.UniVerse;
to_load = 'verse';
add_growl = function(fsm){
  var title;
  title = fsm.namespace;
  title = title.substr(0, title.length - 4);
  fsm.on('debug:notify', function(data){
    return Growl(data.message, {
      title: title,
      image: './icons/fail.png'
    });
  });
  fsm.on('debug:error', function(data){
    return Growl(data.message, {
      title: title,
      image: './icons/fail.png'
    });
  });
  fsm.on('compile:success', function(dd){
    return Growl(this.path + " compiled correctly", {
      title: title,
      image: './icons/success.png'
    });
  });
  return fsm.on('compile:failure', function(err){
    return Growl(err.message, {
      title: title,
      image: './icons/fail.png'
    });
  });
};
amb = new Ambiente('sencillo');
amb.on('state:ready', function(){
  var impl, narrator;
  console.log("ambiente is ready!!");
  console.log("technically, I shouldn't need to wait for its ready state. the Implementation should do that");
  add_growl(impl = new Implementation(amb, "origin/Narrator.concept.ls"));
  return impl.on('compile:success', function(){
    var Narrator, narrator;
    _.each(impl._instances, function(inst){
      return inst.exec('destroy');
    });
    Narrator = impl.imbue(Reality);
    narrator = new Narrator({}, {
      port: 1155,
      domains: {
        'dev.affinaty.es': {
          poem: 'Affinaty@latest',
          title: "Affinaty@latest"
        },
        'affinaty.es': {
          poem: 'Affinaty@0.1.0',
          title: "affinaty"
        }
      }
    });
    return narrator.on('state:ready', function(){
      return console.log('HTTP ready');
    });
  });
});