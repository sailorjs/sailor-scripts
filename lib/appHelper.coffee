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

appName      = "testApp"
appName_path = path.join(__dirname, "../" + appName)

change_path = (path) ->
  new_path = path or appName_path
  process.chdir new_path

# Make existsSync not crash on older versions of Node
fs.existsSync = fs.existsSync or path.existsSync

###
Uses the Sails binary to create a namespaced test app
If no appName is given use 'testApp'

It copies all the files in the fixtures folder into their
respective place in the test app so you don't need to worry
about setting up the fixtures.
###

###
Create a new proyect using 'sails new' command
@param  {Function} done [Optional Callback]
@return {[type]}        [callback Function]
###
_build = (done) ->

  # Cleanup old test fixtures
  _clean()
  exec sailsBin + " new " + appName, (err) ->
    if done
      return done(err)  if err
      done()

_lift = -> # dir, options, done
  delete process.env.NODE_ENV

  args = Args([
    {dir:     Args.STRING   | Args.Optional, _default: appName_path}
    {options: Args.OBJECT   | Args.Optional, _default: {}}
    {done:    Args.FUNCTION | Args.Optional, _default: undefined}
  ], arguments)

  dir     = args.dir
  options = args.options
  done    = args.done
  change_path dir

  _.defaults options,
    # defaults options. Only can be overwritten
    port: 1342

  Sails().lift options, (err, sails) ->
    if done
      return done(err)  if err
      sails.kill = sails.lower
      done null, sails

_buildAndLift = (options, done) ->
  _build -> _lift options, done

_clean = ->
  wrench.rmdirSyncRecursive appName_path  if fs.existsSync(appName_path)


# var _linkPlugin = function(callback){
#   var origin = path.resolve(process.cwd(), '..');
#   var dist = path.resolve(process.cwd(), 'node_modules', pkg.name);
#   fs.symlink(origin, dist, callback);
# };
_liftWithTwoSockets = (options, callback) ->
  if typeof options is "function"
    callback = options
    options = null
  _lift options, (err, sails) ->
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

_buildAndLiftWithTwoSockets = (appName, options, callback) ->
  if typeof options is "function"
    callback = options
    options = null
  _build appName, ->
    _liftWithTwoSockets options, callback


# Exports
module.exports =
  build: _build
  clean: _clean

  # linkPlugin                 : _linkPlugin,
  lift: _lift
  buildAndLift: _buildAndLift

# liftWithTwoSockets         : _liftWithTwoSockets,
# buildAndLiftWithTwoSockets : _buildAndLiftWithTwoSockets
