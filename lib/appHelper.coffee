# -- DEPENDENCIES --------------------------------------------------------------

Args      = require('args-js')
fs        = require('fs-extra')
wrench    = require('wrench')
path      = require('path')
exec      = require('child_process').exec
sailsBin  = path.join(__dirname, '../node_modules/sails/bin/sails.js')
_         = require('lodash')
_ioClient = require('./sails.io')(require('socket.io-client'))
Sails     = require('sails/lib/app')
sailsLift = require('sails/bin/sails-lift')
sh        = require('execSync')

# -- GLOBALS ------------------------------------------------------------------

DEFAULT_BASE       = 'testApp'
DEFAULT_MODULE     = 'sailor-module-test'
DEFAULT_BASE_PATH  = path.join(process.cwd(), "/#{DEFAULT_BASE}")
TEMPLATE_BASE      = path.join(__dirname, '../template/base')
TEMPLATE_MODULE    = path.join(__dirname, '../template/module')
NO_MESSAGE         = ">/dev/null 2>/dev/null"

SCOPE =
  SAILS  : null
  SAILOR : null
  APP    : null

# -- PUBLIC ------------------------------------------------------------------

class AppHelper

  ###
   * Run a shell command without ouput
   * @param  {String} command Command to execute
   * @param  {Function} orig Optional Callback
  ###
  @run: (command, done) ->
    args = Args([
      {cmd: Args.STRING    | Args.Required}
      {done: Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    sh.run("#{args.cmd} #{NO_MESSAGE}")
    args.done?()



  ###
   * Execute a shell command and return the output
   * @param  {String} command Command to execute
   * @param  {Function} orig Optional Callback
  ###
  @execute: (command, done) ->
    args = Args([
      {cmd: Args.STRING    | Args.Required}
      {done: Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    result = sh.exec(args.cmd)
    if args.done? then args.done(result) else result



  ###
   * Create a symbolic link
   * @param  {String}   orig Origin path
   * @param  {String}   dist Destination path
   * @param  {Function} done Optional Callback
  ###
  @link: (orig, dist, done) =>
    args = Args([
      {orig: Args.STRING   | Args.Required}
      {dist: Args.STRING   | Args.Required}
      {done: Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    fs.symlink args.orig, args.dist, -> args.done?()



  ###
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

    SCOPE.APP    = "#{args.dir}/#{args.name}"
    wrench.copyDirSyncRecursive TEMPLATE_BASE, SCOPE.APP, forceDelete: true

    appJSON  = require("#{SCOPE.APP}/package.json")
    delete appJSON.dependencies.sailorjs

    SCOPE.SAILS = @_resolvePath 'sails'
    SCOPE.SAILOR = @_resolvePath 'sailor'

    # search the dependency in sails or sailor and linkin in the folder of the project
    @_copyDependencies(appJSON, args.done)



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
    @run("cd #{args.dir}/#{args.name} && npm install >/dev/null 2>/dev/null");
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
  @lift: (dir, options, done) =>
    delete process.env.NODE_ENV
    args = Args([
      {dir:     Args.STRING   | Args.Optional, _default: DEFAULT_BASE}
      {options: Args.OBJECT   | Args.Optional, _default: {}}
      {done:    Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    @_changePath args.dir

    Sails().lift args.options, (err, sails) ->
      if args.done?
        return args.done(err)  if err
        sails.kill = sails.lower
        args.done null, sails

  # -- PRIVATE ------------------------------------------------------------------

  @_changePath: (dir) ->
    args = Args([
      {dir: Args.STRING | Args.Required}
    ], arguments)

    process.chdir args.dir



  @_resolvePath: (name) ->
    result = @execute "which #{name}"

    if result.stdout[result.stdout.length-1] is '\n'
      result.stdout = result.stdout.substring(0, result.stdout.length - 1)

    # get the relative path
    relative_path = result.stdout.split("/")
    relative_path.splice(relative_path.length-1, 1)
    relative_path = relative_path.join("/")
    # get the symlink value
    link  = fs.readlinkSync result.stdout
    route = path.resolve relative_path, link
    route = path.join route, '../..'



  ###
  Localize a dependency and return the path
  ###
  @_searchDependency = (moduleName) ->
    sailsJSON  = require("#{SCOPE.SAILS}/package.json")
    sailorJSON = require("#{SCOPE.SAILOR}/package.json")

    if sailsJSON['dependencies'][moduleName] or sailsJSON['devDependencies'][moduleName]
      path.join "#{SCOPE.SAILS}", 'node_modules', moduleName
    else if sailorJSON['dependencies'][moduleName] or sailorJSON['devDependencies'][moduleName]
      path.join "#{SCOPE.SAILOR}", 'node_modules', moduleName
    else throw new Error "Dependency '#{moduleName}' not found"



  ###
  For each Dependency localize the source module path and create
  a symlink in the folder of the project
  ###
  @_copyDependencies = (pkg, cb) =>
    moduleNames = Object.keys pkg.dependencies
    app_node    = path.resolve SCOPE.APP, 'node_modules'
    fs.mkdirsSync app_node

    for moduleName in moduleNames
      try
        srcModulePath = @_searchDependency(moduleName)
        destModulePath = path.resolve(SCOPE.APP, 'node_modules', moduleName)
        fs.symlinkSync srcModulePath, destModulePath, "junction"

      catch e
        console.log "Dependency #{moduleName} not found. Installing..."
        @run "cd #{app_node} && npm install #{moduleName}"

    # Finally link sailor
    sailorLocal = path.resolve(SCOPE.APP, 'node_modules', 'sailorjs')
    fs.symlink SCOPE.SAILOR, sailorLocal, "junction", (symLinkErr) ->
      cb?()

# -- EXPORTS ------------------------------------------------------------------

exports = module.exports = AppHelper
