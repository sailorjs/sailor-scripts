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
forceRequire     = require 'force-require'

# -- GLOBALS ------------------------------------------------------------------

SCOPE =
  SAILS  : null
  SAILOR : null
  APP    : null

OPTIONS =
  name         : 'testApp'
  repository   : 'testApp'
  organization : 'sailorjs'
  description  : 'A new Sailor Proyect'

TEMPLATE =
  BASE  : path.join(__dirname, '../template/base')
  MODULE: path.join(__dirname, '../template/module')
  FILES : ["README.md", "LICENSE.md", "package.json"]
  REGEX : /(README\.md)|(LICENSE\.md)|(package\.json)/g

NO_MESSAGE = ">/dev/null 2>/dev/null"

# -- PUBLIC ------------------------------------------------------------------

class AppHelper

  ###
   * Run a shell command without ouput
   * @param  {String} command Command to execute
   * @param  {Function} orig Optional Callback
  ###
  @run: (command, cb) ->
    args = Args([
      {cmd : Args.STRING   | Args.Required                     }
      {cb  : Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    sh.run("#{args.cmd} #{NO_MESSAGE}")
    args.cb?()



  ###
   * Execute a shell command and return the output
   * @param  {String} command Command to execute
   * @param  {Function} orig Optional Callback
  ###
  @exec: (command, cb) ->
    args = Args([
      {cmd : Args.STRING   | Args.Required                     }
      {cb  : Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    result = sh.exec(args.cmd)
    if args.cb? then args.cb(result) else result



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
      {dir  : Args.STRING   | Args.Optional, _default: "#{process.cwd()}"}
      {opts : Args.OBJECT   | Args.Optional, _default: OPTIONS           }
      {cb   : Args.FUNCTION | Args.Optional, _default: undefined         }
    ], arguments)

    @_newTemplate(args.dir, args.opts, TEMPLATE.BASE, args.cb)



  ###
   * Generate a new module for a project
   * @param  {String} dir     Optional path
   * @param  {Object} options Optional options, like:
   *   - name of the folder
   *   - name of the organization (for the git account)
   *   - name of the repository
   * @param  {Function} cb    Optional Callback
  ###
  @newModule: (dir, options, cb) =>
    args = Args([
      {dir  : Args.STRING   | Args.Optional, _default: "#{process.cwd()}"}
      {opts : Args.OBJECT   | Args.Optional, _default: OPTIONS           }
      {cb   : Args.FUNCTION | Args.Optional, _default: undefined         }
    ], arguments)

    @_newTemplate(args.dir, args.opts, TEMPLATE.MODULE, args.cb)



  ###*
   * Check if exist a folder or file
  ###
  @exist:(orig, moduleName) ->
    args = Args([
      {orig       : Args.STRING   | Args.Optional, _default: "#{process.cwd()}"}
      {moduleName : Args.STRING   | Args.Required                              }
      {cb         : Args.FUNCTION | Args.Optional, _default: undefined         }
    ], arguments)

    filePath = path.resolve args.orig, args.moduleName
    if args.cb? then fs.exists filePath, -> args.cb() else fs.existsSync filePath



  ###
   * Clear a folder
   * @param  {[type]}   dir  Optional directory
   * @param  {Function} cb Optional Callback
  ###
  @clean: (dir, cb) ->
    args = Args([
      {dir : Args.STRING   | Args.Optional, _default: "#{process.cwd()}/#{OPTIONS.NAME}"}
      {cb  : Args.FUNCTION | Args.Optional, _default: undefined                         }
    ], arguments)

    wrench.rmdirSyncRecursive args.dir  if fs.existsSync(args.dir)

    args.cb?()



  ###
   * Run Sails 'lift' command
   * @param  {String}   dir     Optional directory
   * @param  {Object}   options Optional sails config object
   * @param  {Function} cb    Optional Callback
  ###
  @lift: (dir, options, cb) =>
    delete process.env.NODE_ENV
    args = Args([
      {dir    : Args.STRING   | Args.Optional, _default: process.cwd()}
      {options: Args.OBJECT   | Args.Optional, _default: {}           }
      {cb     : Args.FUNCTION | Args.Optional, _default: undefined    }
    ], arguments)

    @_changePath args.dir

    Sails().lift args.options, (err, sails) ->
      if args.cb?
        return args.cb(err)  if err
        sails.kill = sails.lower
        args.cb null, sails



  ###
   * Write in the module file in config/modules
   * @param  {String}   source Rext to write
   * @param  {Function} cb   Optional callback
  ###
  @writeModuleFile: (moduleName, baseName, cb) ->
    args = Args([
      {moduleName : Args.STRING   | Args.Required                        }
      {baseName   : Args.STRING   | Args.Optional, _default: OPTIONS.name}
      {cb         : Args.FUNCTION | Args.Optional, _default: undefined   }
    ], arguments)

    configFile = path.resolve args.baseName, 'config', 'modules.coffee'

    if fs.existsSync configFile
      moduleList = (require configFile).modules
      moduleList.push args.moduleName
      fs.writeFileSync configFile, "module.exports.modules = #{JSON.stringify(moduleList)}"

    args.cb?()



  ###
   * Create a symbolic link
   * @param  {String}   orig Origin path
   * @param  {String}   dist Destination path
   * @param  {Function} cb   Optional Callback
  ###
  @link: (orig, dist, cb) ->
    args = Args([
      {orig : Args.STRING   | Args.Optional, _default: "#{process.cwd()}"}
      {dist : Args.STRING   | Args.Required                              }
      {cb   : Args.FUNCTION | Args.Optional, _default: undefined         }
    ], arguments)

    fs.symlinkSync args.orig, args.dist
    args.cb?()



  ###*
   * helper to concat link and writeModuleFile functions
  ###
  @linkModule: (moduleName, cb) ->
    args = Args([
      {moduleName : Args.STRING   | Args.Required                               }
      {cb         : Args.FUNCTION | Args.Optional, _default: undefined          }
    ], arguments)

    linkFolder = path.resolve OPTIONS.name, 'node_modules', args.moduleName
    @link linkFolder, => @writeModuleFile args.moduleName, -> args.cb?()



  ###*
   * similar to linkModule but for dependencies that need
   * only for testing environment (for example, other module)
  ###
  @linkOther: (moduleName, cb) ->
    args = Args([
      {moduleName : Args.STRING   | Args.Required                               }
      {cb         : Args.FUNCTION | Args.Optional, _default: undefined          }
    ], arguments)

    linkFolder = path.resolve OPTIONS.name
    @linkDependency linkFolder, args.moduleName, => @writeModuleFile args.moduleName, -> args.cb?()


  ###
   * Link a dependency of the core in the folder of the project.
   * If the dependency is no possible to localize, then install it.
   * @param  {String}   orig        Optional orig path
   * @param  {Function} moduleName  Module Name
   * @param  {Function} cb          Optional callback
  ###
  @linkDependency: (orig, moduleName, cb) =>
    args = Args([
      {orig      : Args.STRING   | Args.Optional, _default: process.cwd()}
      {moduleName: Args.STRING   | Args.Required                         }
      {cb        : Args.FUNCTION | Args.Optional, _default: undefined    }
    ], arguments)

    srcModulePath = @_searchDependency(args.moduleName)
    destModulePath = path.resolve(args.orig, 'node_modules', args.moduleName)

    unless srcModulePath
      forceRequire scope: args.orig, name: args.moduleName, production: true
    else
      fs.symlinkSync srcModulePath, destModulePath, "junction" unless fs.existsSync(destModulePath)

    args.cb?()

  # -- PRIVATE ------------------------------------------------------------------

  ###
  Change the process path
  ###
  @_changePath: (dir) ->
    args = Args([
      {dir: Args.STRING | Args.Required}
    ], arguments)

    process.chdir args.dir



  ###
  Find the path of a dependency
  ###
  @_resolvePath: (name) ->
    # first try to resolve the dependency locally of this package
    return "#{localDependecies}/#{name}" if fs.existsSync("#{localDependecies}/#{name}")

    # second, try to resolve in global mode
    result = @exec "which #{name}"
    return null if result.code isnt 0

    if result.stdout[result.stdout.length-1] is '\n'
      result.stdout = result.stdout.substring(0, result.stdout.length - 1)

    fileType = fs.lstatSync(result.stdout)
    path.join fs.realpathSync(result.stdout), '../..' if fileType.isSymbolicLink()



  ###
  Localize a dependency and return the path
  ###
  @_searchDependency = (moduleName) ->
    try
      sailsJSON  = require("#{SCOPE.SAILS}/package.json")
      sailorJSON = require("#{SCOPE.SAILOR}/package.json")

      if sailsJSON['dependencies'][moduleName] or sailsJSON['devDependencies'][moduleName]
        path.join "#{SCOPE.SAILS}", 'node_modules', moduleName
      else if sailorJSON['dependencies'][moduleName] or sailorJSON['devDependencies'][moduleName]
        path.join "#{SCOPE.SAILOR}", 'node_modules', moduleName
      else throw new Error "Dependency '#{moduleName}' not found"
    catch e
      undefined

  ###
  For each dependency localize the source module path and create
  a symlink in the folder of the project
  ###
  @_linkDependencyFromPackage = (pkg, cb) =>
    # get the names of the dependencies
    moduleNames     = _.union(Object.keys(pkg.devDependencies), Object.keys(pkg.dependencies))
    appDependencies = path.resolve SCOPE.APP, 'node_modules'
    fs.mkdirsSync appDependencies

    # ensure that SCOPE.SAILOR exists
    unless SCOPE.SAILOR?
      console.log "#{chalk.blue('debug :')} Dependency 'sailorjs' doesn't found. Installing..."
      @run "cd #{appDependencies} && npm install sailorjs"
      SCOPE.SAILOR = path.resolve appDependencies, 'sailorjs'

    for moduleName in moduleNames
      try
        srcModulePath = @_searchDependency(moduleName)
        destModulePath = path.resolve(SCOPE.APP, 'node_modules', moduleName)
        fs.symlinkSync srcModulePath, destModulePath, "junction"

      catch e
        console.log "#{chalk.blue('debug :')} Dependency '#{moduleName}' doesn't found. Installing..."
        @run "cd #{appDependencies} && npm install #{moduleName}"

    # Finally link sailor if is necessary
    sailorLocal = path.resolve(SCOPE.APP, 'node_modules', 'sailorjs')

    if !fs.existsSync sailorLocal
      fs.symlinkSync SCOPE.SAILOR, sailorLocal, "junction"

    cb?()



  ###
  Process a template file and copy it on the destinity
  ###
  @_copyTemplate: (srcPath, options) ->
    destPath = path.resolve(SCOPE.APP, path.basename(srcPath))
    contents = fs.readFileSync srcPath, "utf8"
    contents = _.template(contents, options)
    # With lodash teplates, HTML entities are escaped by default.
    # Default assumption is we DON'T want that, so we'll reverse it.
    contents = _.unescape(contents)  unless options.escapeHTMLEntities
    # copy the content of the variable into file
    fs.outputFileSync(destPath, contents)



  ###
  Generate the scaffold base on a template
  ###
  @_newTemplate: (dir, options, templatePath, cb) =>

    SCOPE.APP = "#{dir}/#{options.name}"
    wrench.copyDirSyncRecursive templatePath, SCOPE.APP,
      forceDelete : true
      exclude     : TEMPLATE.REGEX

    @_copyTemplate "#{templatePath}/#{template}", options for template in TEMPLATE.FILES

    appJSON  = require("#{SCOPE.APP}/package.json")
    delete appJSON.dependencies?.sailorjs

    SCOPE.SAILS  = @_resolvePath 'sails'
    SCOPE.SAILOR = @_resolvePath 'sailor'

    @_linkDependencyFromPackage(appJSON, cb)


# -- EXPORTS ------------------------------------------------------------------

exports = module.exports = AppHelper
