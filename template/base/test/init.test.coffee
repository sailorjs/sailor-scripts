## -- Dependencies -----------------------------------------------------------------------

pkg          = require '../package.json'
sailor       = require 'sailorjs'
scripts      = sailor.scripts

## -- Setup ------------------------------------------------------------------------------

SCOPE =
  PATH : process.cwd()
  TMP  : '.tmp'

sailsOptions =
  log: level: "silent"

before (done) ->
  scripts.clean "#{SCOPE.PATH}/#{SCOPE.TMP}"
  scripts.lift "#{SCOPE.PATH}", sailsOptions, done
