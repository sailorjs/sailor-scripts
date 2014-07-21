/**
 * Module Dependencies
 */
var scripts = require('../');

/**
 * Setup
 */

 var opts = {
   port: 8000
 };

 var callback = function(){};

scripts.buildAndLift();
// scripts.buildAndLift(opts);
// scripts.buildAndLift(callback);
// scripts.buildAndLift(opts, callback);
