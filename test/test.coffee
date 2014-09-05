## -- Dependencies -------------------------------------------------------------

path      = require 'path'
fs        = require 'fs-extra'
should    = require 'should'
scripts   = require '../'

## -- Setup -------------------------------------------------------------

DIR    = process.cwd()
APP    = 'testApp'
MODULE = 'sailor-module-test'

options_app =
  name         : 'testApp'
  repository   : 'testApp'
  organization : 'sailorjs'

options_module =
  name         : 'sailor-module-test'
  repository   : 'sailor-module-test'
  organization : 'sailorjs'

options_lift =
  log: level: 'silent'

# afterEach (done) ->
#   scripts.clean "#{DIR}/#{APP}", done

## -- Test -------------------------------------------------------------

describe 'Sailor Scripts ::', ->

  describe 'Base', ->
    it 'create ', (done) ->
      scripts.newBase ->
        fs.existsSync("#{DIR}/#{APP}").should.eql true
        done()

    it 'created specifing the options', (done)->
      scripts.newBase options_app , ->
        fs.existsSync("#{DIR}/#{APP}").should.eql true
        done()

  describe 'Module', ->
    xit 'created', (done) ->
      scripts.newModule  ->
        fs.existsSync("#{DIR}/#{APP}").should.eql true
        done()

    it 'created specifing the options', (done) ->
      scripts.newModule options_module, ->
        fs.existsSync("#{DIR}/#{MODULE}").should.eql true
        done()

  describe 'Link', ->
    it 'module in base project', (done) ->
      scripts.link "#{DIR}/#{MODULE}", "#{DIR}/#{APP}/node_modules/#{MODULE}", ->
        fs.existsSync("#{DIR}/#{APP}/node_modules/#{MODULE}").should.eql true
        done()

  describe 'writePluginFile', ->
    it 'the name of the plugin in the config file', (done) ->
      scripts.writePluginFile MODULE
      configFile = require(path.resolve 'testApp/config/plugins')
      configFile.plugins[0].should.eql MODULE
      done()

  describe 'Lift', ->
    it 'sailor project', (done) ->
      scripts.lift options_lift, done

  describe 'Clean', ->
    it 'project files', (done) ->
      scripts.clean "#{DIR}/#{APP}"
      scripts.clean "#{DIR}/#{MODULE}"
      fs.existsSync("#{DIR}/#{APP}").should.eql false
      fs.existsSync("#{DIR}/#{MODULE}").should.eql false
      done()
