###
# Depedencies
###

Args      = require("args-js")
fs        = require("fs-extra")
wrench    = require("wrench")
path      = require("path")
exec      = require("child_process").exec
sailsBin  = path.join(__dirname, "../node_modules/sails/bin/sails.js")
_         = require("lodash")
_ioClient = require("./sails.io")(require("socket.io-client"))
Sails     = require("sails/lib/app")
sailsLift = require("sails/bin/sails-lift")
sh        = require('execSync');

# -- PRIVATE ---------------------------------------------

DEFAULT_BASE       = 'testApp'
DEFAULT_MODULE     = 'sailor-module-test'
DEFAULT_BASE_PATH  = path.join(process.cwd(), "/#{DEFAULT_BASE}")
TEMPLATE_BASE      = path.join(__dirname, '../template/base')
TEMPLATE_MODULE    = path.join(__dirname, '../template/module')

CHANGE_PATH  = (dir) ->
  args = Args([
    {dir: Args.STRING | Args.Required}
  ], arguments)

  process.chdir args.dir

# -- STATIC ------------------------------------------------------------------

class AppHelper

  ###*
   * Execute a shell command
   * @param  {String} command Command to execute
   * @param  {Function} orig Optional Callback
  ###
  @execute: (command, done) ->
    args = Args([
      {cmd: Args.STRING    | Args.Required}
      {done: Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    sh.run(args.cmd)
    args.done?()



  ###*
   * Create a symbolic link
   * @param  {String}   orig Origin path
   * @param  {String}   dist Destination path
   * @param  {Function} done Optional Callback
  ###
  @link: (orig, dist, done) ->
    args = Args([
      {orig: Args.STRING   | Args.Required}
      {dist: Args.STRING   | Args.Required}
      {done: Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    fs.symlink args.orig, args.dist, ->
      args.done?()



  ###*
   * Write in the plugin file in config/plugins
   * @param  {String}   source Rext to write
   * @param  {Function} done   Optional callback
  ###
  @writePluginFile: (source, dir, done) ->
    args = Args([
      {src:  Args.STRING   | Args.Required}
      {dir : Args.STRING   | Args.Optional, _default: "#{DEFAULT_BASE_PATH}/config/plugins.coffee"}
      {done: Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    if fs.existsSync args.dir
      fs.writeFileSync args.dir, "module.exports.plugins = [" + JSON.stringify(args.src) + "]"

    args.done?()

  ###*
   * Generate a new base proyect
   * @param  {String}   name Optional name
   * @param  {String}   dir  Optional path
   * @param  {Function} done Optional Callback
  ###
  @newBase: (name, dir, options, done) =>
    args = Args([
      {name: Args.STRING   | Args.Optional, _default: DEFAULT_BASE}
      {dir : Args.STRING   | Args.Optional, _default: "#{process.cwd()}"}
      {done: Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    wrench.copyDirSyncRecursive TEMPLATE_BASE, "#{args.dir}/#{args.name}",
      forceDelete: true

    @execute("cd #{args.dir}/#{args.name} && npm install >/dev/null 2>/dev/null");
    args.done?()



  ###*
   * Generate a new module for a proyect
   * @param  {String}   name name
   * @param  {String}   dir  Optional path
   * @param  {Function} done Optional Callback
  ###
  @newModule: (name, dir, done) =>
    args = Args([
      {name: Args.STRING   | Args.Required }
      {dir : Args.STRING   | Args.Optional, _default: "#{process.cwd()}"}
      {done: Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    wrench.copyDirSyncRecursive TEMPLATE_MODULE, "#{args.dir}/#{args.name}",
      forceDelete: true
    @execute("cd #{args.dir}/#{args.name} && npm install >/dev/null 2>/dev/null");
    args.done?()



  ###*
   * Clear a folder
   * @param  {[type]}   dir  Optional directory
   * @param  {Function} done Optional Callback
  ###
  @clean: (dir, done) ->
    args = Args([
      {dir : Args.STRING   | Args.Optional, _default: "#{process.cwd()}/#{DEFAULT_BASE}"}
      {done: Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    wrench.rmdirSyncRecursive args.dir  if fs.existsSync(args.dir)
    args.done?()



  ###*
   * Run Sails 'new' command
   * @param  {[type]}   dir  Optional directory
   * @param  {Function} done Optional Callback
  ###
  @sailsNew: (dir, done) ->
    args = Args([
      {dir:     Args.STRING   | Args.Optional, _default: DEFAULT_BASE}
      {done:    Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    @clean(args.dir)
    exec sailsBin + " new " + DEFAULT_BASE, (err) ->
      if args.done?
        return args.done(err)  if err
        args.done()


  ###*
   * Run Sails 'lift' command
   * @param  {String}   dir     Optional directory
   * @param  {Object}   options Optional sails config object
   * @param  {Function} done    Optional Callback
  ###
  @lift: (dir, options, done) ->
    delete process.env.NODE_ENV
    args = Args([
      {dir:     Args.STRING   | Args.Optional, _default: DEFAULT_BASE}
      {options: Args.OBJECT   | Args.Optional, _default: {}}
      {done:    Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    CHANGE_PATH args.dir

    _.defaults args.options,
      # defaults options. Only can be overwritten
      port: 1342

    Sails().lift args.options, (err, sails) ->
      if args.done?
        return args.done(err)  if err
        sails.kill = sails.lower
        args.done null, sails

# -- EXPORTS -----------------------------------------------------------------

exports = module.exports = AppHelper
