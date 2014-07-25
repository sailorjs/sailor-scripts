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

# -- PRIVATE ---------------------------------------------

DEFAULT_NAME = 'testApp'
DEFAULT_PATH = path.join(__dirname, '../' + DEFAULT_NAME)
BASE_PATH    = path.join(__dirname, '../template/base')
MODULE_PATH  = path.join(__dirname, '../template/module')
CHANGE_PATH  = (dir) ->
  args = Args([
    {dir: Args.STRING | Args.Optional, _default: DEFAULT_PATH}
  ], arguments)

  process.chdir args.dir

class AppHelper

  # -- STATIC ------------------------------------------------------------------

  @newBase: (done)->
    args = Args([
      {dir:     Args.STRING   | Args.Optional, _default: "#{process.cwd()}/#{DEFAULT_NAME}"}
      {done:    Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    wrench.copyDirSyncRecursive BASE_PATH, args.dir,
      forceDelete: true

    done() if done?


  @clean: (dir) ->
    args = Args([
      {dir: Args.STRING | Args.Optional, _default: DEFAULT_PATH}
    ], arguments)

    wrench.rmdirSyncRecursive args.dir  if fs.existsSync(args.dir)



  @build: (dir, done) ->
    args = Args([
      {dir:     Args.STRING   | Args.Optional, _default: DEFAULT_NAME}
      {done:    Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    @clean(args.dir)
    exec sailsBin + " new " + DEFAULT_NAME, (err) ->
      if args.done?
        return args.done(err)  if err
        args.done()



  @lift: (dir, options, done) ->
    delete process.env.NODE_ENV
    args = Args([
      {dir:     Args.STRING   | Args.Optional, _default: DEFAULT_NAME}
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



  @buildAndLift: (dir, options, done) ->
    @build dir, =>
      @lift dir, options, done

# -- EXPORTS -----------------------------------------------------------------

exports = module.exports = AppHelper
