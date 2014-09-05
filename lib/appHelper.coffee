# -- DEPENDENCIES --------------------------------------------------------------

Args             = require 'args-js'
fs               = require 'fs-extra'
wrench           = require 'wrench'
path             = require 'path'
chalk            = require 'chalk'
sh               = require 'execSync'
_                = require 'lodash'
localDependecies = path.join __dirname, '../node_modules'
sailsBin         = path.join localDependecies, 'sails/bin/sails.js'
Sails            = require (path.join localDependecies, 'sails/lib/app')
sailsLift        = require (path.join localDependecies, 'sails/bin/sails-lift')
_ioClient        = require('./sails.io')(require('socket.io-client'))

# -- GLOBALS ------------------------------------------------------------------

SCOPE =
  SAILS  : null
  SAILOR : null
  APP    : null

OPTIONS =
  name         : 'testApp'
  organization : 'sailorjs'
  repository   : 'testApp'

TEMPLATE =
  BASE  : path.join(__dirname, '../template/base')
  MODULE: path.join(__dirname, '../template/module')
  FILES : ["README.md", "package.json"]

NO_MESSAGE = ">/dev/null 2>/dev/null"

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
   * Generate a new base proyect
   * @param  {String} dir     Optional path
   * @param  {Object} options Optional options, like:
   *   - name
   *   - organization
   *   - repository
   * @param  {Function} cb    Optional Callback
  ###
  @newBase: (dir, options, cb) =>
    args = Args([
      {dir          : Args.STRING   | Args.Optional, _default: "#{process.cwd()}" }
      {options      : Args.OBJECT   | Args.Optional, _default: OPTIONS            }
      {cb           : Args.FUNCTION | Args.Optional, _default: undefined          }
    ], arguments)

    SCOPE.APP    = "#{args.dir}/#{args.options.name}"
    wrench.copyDirSyncRecursive TEMPLATE.BASE, SCOPE.APP, forceDelete: true

    @_copyTemplate template, args.options for template in TEMPLATE.FILES

    appJSON  = require("#{SCOPE.APP}/package.json")
    delete appJSON.dependencies?.sailorjs

    SCOPE.SAILS  = @_resolvePath 'sails'
    SCOPE.SAILOR = @_resolvePath 'sailor'

    # search the depndencies in the SCOPE's or download
    @_copyDependencies(appJSON, args.cb)



  ###
   * Generate a new module for a project
   * @param  {String} dir     Optional path
   * @param  {Object} options Optional options, like:
   *   - name
   *   - organization
   *   - repository
   * @param  {Function} cb    Optional Callback
  ###
  @newModule: (dir, options, cb) =>
    args = Args([
      {dir          : Args.STRING   | Args.Optional, _default: "#{process.cwd()}" }
      {options      : Args.OBJECT   | Args.Optional, _default: OPTIONS            }
      {cb           : Args.FUNCTION | Args.Optional, _default: undefined          }
    ], arguments)

    SCOPE.APP    = "#{args.dir}/#{args.options.name}"
    wrench.copyDirSyncRecursive TEMPLATE.MODULE, SCOPE.APP, forceDelete: true

    @_copyTemplate template, args.options for template in TEMPLATE.FILES

    appJSON  = require("#{SCOPE.APP}/package.json")
    delete appJSON.dependencies?.sailorjs

    SCOPE.SAILS  = @_resolvePath 'sails'
    SCOPE.SAILOR = @_resolvePath 'sailor'

    # search the depndencies in the SCOPE's or download
    @_copyDependencies(appJSON, args.cb)



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
      {dir : Args.STRING   | Args.Optional, _default: path.join(process.cwd(), "/#{OPTIONS.name}/config/plugins.coffee")}
      {done: Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    if fs.existsSync args.dir
      fs.writeFileSync args.dir, "module.exports.plugins = [" + JSON.stringify(args.src) + "]"

    args.done?()



  ###
   * Clear a folder
   * @param  {[type]}   dir  Optional directory
   * @param  {Function} done Optional Callback
  ###
  @clean: (dir, done) ->
    args = Args([
      {dir : Args.STRING   | Args.Optional, _default: "#{process.cwd()}/#{OPTIONS.NAME}"}
      {done: Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    wrench.rmdirSyncRecursive args.dir  if fs.existsSync(args.dir)
    args.done?()



  ###
   * Run Sails 'lift' command
   * @param  {String}   dir     Optional directory
   * @param  {Object}   options Optional sails config object
   * @param  {Function} done    Optional Callback
  ###
  @lift: (dir, options, done) =>
    delete process.env.NODE_ENV
    args = Args([
      {dir:     Args.STRING   | Args.Optional, _default: process.cwd()}
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
    # first try to resolve the dependency locally
    return "#{localDependecies}/#{name}" if fs.existsSync("#{localDependecies}/#{name}")

    # second, try to resolve in global mode
    result = @execute "which #{name}"
    return null if result.code isnt 0

    result = @execute "which #{name}"

    if result.stdout[result.stdout.length-1] is '\n'
      result.stdout = result.stdout.substring(0, result.stdout.length - 1)

    fileType = fs.lstatSync(result.stdout)
    path.join fs.realpathSync(result.stdout), '../..' if fileType.isSymbolicLink()



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
    # get the names of the dependencies
    moduleNames     = _.union(Object.keys(pkg.devDependencies), Object.keys(pkg.dependencies))
    appDependencies = path.resolve SCOPE.APP, 'node_modules'
    fs.mkdirsSync appDependencies

    for moduleName in moduleNames
      try
        srcModulePath = @_searchDependency(moduleName)
        destModulePath = path.resolve(SCOPE.APP, 'node_modules', moduleName)
        fs.symlinkSync srcModulePath, destModulePath, "junction"

      catch e
        console.log "#{chalk.blue('info')}   : Dependency '#{moduleName}' doesn't found. Installing..."
        @run "cd #{appDependencies} && npm install #{moduleName}"

    # Finally link sailor
    sailorLocal = path.resolve(SCOPE.APP, 'node_modules', 'sailorjs')
    fs.symlink SCOPE.SAILOR, sailorLocal, "junction", (symLinkErr) ->
      cb?()



  ###
  Process a template file and copy it on the destinity
  ###
  @_copyTemplate: (fileName, options) ->
    absTemplatePath = path.resolve(SCOPE.APP, fileName)
    contents = fs.readFileSync absTemplatePath, "utf8"
    contents = _.template(contents, options)
    # With lodash teplates, HTML entities are escaped by default.
    # Default assumption is we DON'T want that, so we'll reverse it.
    contents = _.unescape(contents)  unless options.escapeHTMLEntities
    # copy the content of the variable into file
    fs.outputFileSync(absTemplatePath, contents)

# -- EXPORTS ------------------------------------------------------------------

exports = module.exports = AppHelper
