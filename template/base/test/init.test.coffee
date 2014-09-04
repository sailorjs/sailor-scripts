## -- Dependencies -----------------------------------------------------------------------

pkg       = require '../package.json'
fs        = require 'fs'
sailor    = require 'sailorjs'
scripts   = sailor.scripts

## -- Setup ------------------------------------------------------------------------------

opts =
  log: level: "silent"

SCOPE =
  TEST: process.cwd()

before (done) ->
  scripts.clean "#{SCOPE.TEST}/.tmp/"
  scripts.lift opts, done
