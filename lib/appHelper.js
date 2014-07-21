var fs        = require('fs-extra');
var wrench    = require('wrench');
var path      = require('path');

var exec      = require('child_process').exec;
var sailsBin  = path.resolve('./node_modules/sails/bin/sails.js');

var _         = require('lodash');
var _ioClient = require('./sails.io')(require('socket.io-client'));
var Sails     = require('sails/lib/app');
var sailsLift = require('sails/bin/sails-lift');

var appName      = 'testApp';
var appName_path = path.join(__dirname, '../'+ appName);
var options, done;

var change_path = function(){
  process.chdir(appName_path);
};

// Make existsSync not crash on older versions of Node
fs.existsSync = fs.existsSync || path.existsSync;


/**
 * Uses the Sails binary to create a namespaced test app
 * If no appName is given use 'testApp'
 *
 * It copies all the files in the fixtures folder into their
 * respective place in the test app so you don't need to worry
 * about setting up the fixtures.
 */
var _build = function(done) {

  // Cleanup old test fixtures
  _clean();

  exec(sailsBin + ' new ' + appName, function(err) {
    if(done){
      if (err) return done(err);
      return done();
    }
  });
};


var _lift = function( /* options, done */ ) {

  delete process.env.NODE_ENV;
  change_path();

  // Parameter checker like a shit
  if (arguments.length === 0) options = {};

  if (arguments.length === 1) {
    if (typeof arguments[0] !== 'function')
      options = arguments[0] || {};
    else
      done = arguments[0];
  }

  if (arguments.length === 2) {
    options = arguments[0] || {};
    done  = arguments[1];
  }

  _.defaults(options, {
    port: 1342
  });

  Sails().lift(options, function(err, sails) {
    if (done) {
      if (err) return done(err);
      sails.kill = sails.lower;
      return done(null, sails);
    }
  });

};

var _buildAndLift = function(options, done) {
  _build(function(){
    _lift(options, done);
  });
};

var _clean = function() {
  if (fs.existsSync(appName_path)) {
    wrench.rmdirSyncRecursive(appName_path);
  }
};

// var _linkPlugin = function(callback){
//   var origin = path.resolve(process.cwd(), '..');
//   var dist = path.resolve(process.cwd(), 'node_modules', pkg.name);
//   fs.symlink(origin, dist, callback);
// };

var _liftWithTwoSockets = function(options, callback) {
  if (typeof options == 'function') {
    callback = options;
    options = null;
  }
  _lift(options, function(err, sails) {
    if (err) {
      return callback(err);
    }
    var socket1 = _ioClient.connect('http://localhost:1342', {
      'force new connection': true
    });
    socket1.on('connect', function() {
      var socket2 = _ioClient.connect('http://localhost:1342', {
        'force new connection': true
      });
      socket2.on('connect', function() {
        callback(null, sails, socket1, socket2);
      });
    });
  });
};

var _buildAndLiftWithTwoSockets = function(appName, options, callback) {
  if (typeof options == 'function') {
    callback = options;
    options = null;
  }
  _build(appName, function() {
    _liftWithTwoSockets(options, callback);
  });
};

// Exports
module.exports = {
  build                      : _build,
  clean                      : _clean,
  // linkPlugin                 : _linkPlugin,
  lift                       : _lift,
  buildAndLift               : _buildAndLift,
  // liftWithTwoSockets         : _liftWithTwoSockets,
  // buildAndLiftWithTwoSockets : _buildAndLiftWithTwoSockets
};
