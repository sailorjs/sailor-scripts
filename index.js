/**
 * Dependencies
 */
var CoffeeScript= require("coffee-script");

// Register CoffeeScript if exits
if(CoffeeScript.register) CoffeeScript.register();

var appHelper = require('./lib/appHelper');

/**
 * Exports
 */
module.exports = {
  newBase      : appHelper.newBase,
  newModule    : appHelper.newModule,
  link         : appHelper.link,
  clean        : appHelper.clean,
  build        : appHelper.build,
  lift         : appHelper.lift,
  buildAndLift : appHelper.buildAndLift
};
