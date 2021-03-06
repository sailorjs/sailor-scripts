/**
 * Dependencies
 */
var CoffeeScript = require("coffee-script");

// Register CoffeeScript if exits
if(CoffeeScript.register) CoffeeScript.register();

var appHelper = require('./lib/appHelper');

/**
 * Exports
 */
module.exports = {
  run             : appHelper.run,
  exec            : appHelper.exec,
  exist           : appHelper.exist,
  clean           : appHelper.clean,
  newBase         : appHelper.newBase,
  newModule       : appHelper.newModule,
  link            : appHelper.link,
  linkModule      : appHelper.linkModule,
  linkOther       : appHelper.linkOther,
  lift            : appHelper.lift,
  linkDependency  : appHelper.linkDependency,
  writeModuleFile : appHelper.writeModuleFile
};
