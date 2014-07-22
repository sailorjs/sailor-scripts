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

# -- PRIVATE ------------------------------------------------------------------

appName      = "testApp"
appName_path = path.join(__dirname, "../" + appName)

_change_path = (path) ->
  new_path = path or appName_path
  process.chdir new_path

# Make existsSync not crash on older versions of Node
fs.existsSync = fs.existsSync or path.existsSync

# -- PUBLIC ------------------------------------------------------------------

###
Create a new proyect using 'sails new' command
@param  {[Function]} done Callback
@return {[Function]}      Callback
###
build = (done) ->

  # Cleanup old test fixtures
  clean()
  exec sailsBin + " new " + appName, (err) ->
    if done
      return done(err)  if err
      done()

###
@description Lift a Sails Server
@return      {[Functon]} Callback
###
lift = -> # dir, options, done
  delete process.env.NODE_ENV
  args = Args([
    {dir:     Args.STRING   | Args.Optional, _default: appName_path}
    {options: Args.OBJECT   | Args.Optional, _default: {}}
    {done:    Args.FUNCTION | Args.Optional, _default: undefined}
  ], arguments)

  dir     = args.dir
  options = args.options
  done    = args.done
  _change_path dir

  _.defaults options,
    # defaults options. Only can be overwritten
    port: 1342

  Sails().lift options, (err, sails) ->
    if done
      return done(err)  if err
      sails.kill = sails.lower
      done null, sails

###
Concatenate build and lift actions
@param  {[type]}   options Sails option object
@param  {Function} done    Callback
@return {[type]}           Callback
###
buildAndLift = (options, done) ->
  build -> lift options, done

###
Clean a proyect
###
clean = -> # dir
  args = Args([
    {dir:     Args.STRING   | Args.Optional, _default: appName_path}
  ], arguments)

  dir     = args.dir
  wrench.rmdirSyncRecursive dir  if fs.existsSync(dir)

# var _linkPlugin = function(callback){
#   var origin = path.resolve(process.cwd(), '..');
#   var dist = path.resolve(process.cwd(), 'node_modules', pkg.name);
#   fs.symlink(origin, dist, callback);
# };

liftWithTwoSockets = (options, callback) ->
  if typeof options is "function"
    callback = options
    options = null
  lift options, (err, sails) ->
    return callback(err)  if err
    socket1 = _ioClient.connect("http://localhost:1342",
      "force new connection": true
    )
    socket1.on "connect", ->
      socket2 = _ioClient.connect("http://localhost:1342",
        "force new connection": true
      )
      socket2.on "connect", ->
        callback null, sails, socket1, socket2

buildAndLiftWithTwoSockets = (appName, options, callback) ->
  if typeof options is "function"
    callback = options
    options = null
  build appName, ->
    liftWithTwoSockets options, callback

# -- EXPORTS ------------------------------------------------------------------

module.exports =
  build        : build
  clean        : clean
  lift         : lift
  buildAndLift : buildAndLift
  # linkPlugin                 : _linkPlugin,
  # liftWithTwoSockets         : liftWithTwoSockets,
  # buildAndLiftWithTwoSockets : buildAndLiftWithTwoSockets
