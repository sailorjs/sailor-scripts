## -- Dependencies -------------------------------------------------------------

path      = require 'path'
fs        = require 'fs-extra'
should    = require 'should'
scripts   = require '../'

## -- Setup -------------------------------------------------------------

DIR    = process.cwd()
APP    = 'testApp'
APP2   = 'testApp2'
MODULE = 'sailor-module-test'

options_app =
  folder       : 'testApp2'
  name         : 'testApp'
  repository   : 'testApp'
  organization : 'sailorjs'
  description  : 'A new Sailor Proyect'

options_module =
  folder       : 'sailor-module-test'
  name         : 'sailor-module-test'
  repository   : 'sailor-module-test'
  organization : 'sailorjs'
  description  : 'A new Sailor Proyect'

options_lift =
  log: level: 'silent'

## -- Test -------------------------------------------------------------

describe 'Sailor Scripts ::', ->

  describe 'Module', ->
    it 'created', (done) ->
      scripts.newModule  ->
        fs.existsSync("#{DIR}/#{APP}").should.eql true
        done()

    it 'created specifing the options', (done) ->
      scripts.newModule options_module, ->
        fs.existsSync("#{DIR}/#{MODULE}").should.eql true
        done()

  describe 'Base', ->
    it 'created ', (done) ->
      scripts.newBase ->
        fs.existsSync("#{DIR}/#{APP}").should.eql true
        done()

    it 'created specifing the options', (done)->
      scripts.newBase options_app , ->
        fs.existsSync("#{DIR}/#{APP2}").should.eql true
        done()

  xdescribe 'Link', ->
    it 'module in base project', (done) ->
      scripts.link "#{DIR}/#{MODULE}", "#{DIR}/#{APP}/node_modules/#{MODULE}", ->
        fs.existsSync("#{DIR}/#{APP}/node_modules/#{MODULE}").should.eql true
        done()

  describe 'writeModuleFile', ->
    it 'the name of the plugin in the config file', (done) ->
      scripts.writeModuleFile MODULE
      configFile = (require(path.resolve 'testApp/config/modules')).modules
      configFile[configFile.length-1].should.eql MODULE
      done()

  describe 'Lift', ->
    it 'sailor project', (done) ->
      scripts.lift options_lift, done

  describe 'Clean', ->
    it 'project files', (done) ->
      scripts.clean "#{DIR}/#{APP}"
      scripts.clean "#{DIR}/#{APP2}"
      scripts.clean "#{DIR}/#{MODULE}"

      fs.existsSync("#{DIR}/#{APP}").should.eql false
      fs.existsSync("#{DIR}/#{APP2}").should.eql false
      fs.existsSync("#{DIR}/#{MODULE}").should.eql false
      done()
