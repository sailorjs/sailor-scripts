## -- Dependencies -----------------------------------------------------------------------

pkg       = require '../package.json'
url       = require './helpers/urlHelper'
fs        = require 'fs'
should    = require 'should'
request   = require 'superagent'
scripts   = require 'sailor-scripts'

## -- Setup ------------------------------------------------------------------------------

opts =
  log: level: "silent"
  plugins: [pkg.name]

MODULE = process.cwd()
LINK   = "#{process.cwd()}/testApp/node_modules/sailor-module-user"

## -- Test ------------------------------------------------------------------------------

before (done) ->
  if (!fs.existsSync("#{MODULE}/testApp"))
    scripts.newBase ->
      scripts.link MODULE, LINK, ->
        scripts.writePluginFile pkg.name, ->
          scripts.lift opts, done
  else
    scripts.clean "#{MODULE}/.tmp/"
    scripts.clean "#{MODULE}/testApp/.tmp/"
    scripts.lift opts, done

describe "First Test :: /GET path", ->

  describe '200 OK', ->
    it "because this test is empty", (done) ->
      done()

  describe '404 NotFound', ->
    it "because this test is empty", (done) ->
      done()
