fs        = require 'fs-extra'
should    = require 'should'
scripts   = require '../'

DIR    = process.cwd()
APP    = 'testApp'
MODULE = "sailor-module-test"

# after (done) ->
#   scripts.clean "#{DIR}/#{APP}"
#   scripts.clean "#{DIR}/#{MODULE}", done

describe 'Base', ->

  it 'created a new based proyect without name', ->
    scripts.newBase ->
      fs.existsSync("#{DIR}/#{APP}").should.eql true

  it "created a new based proyect called 'testApp'", ->
    scripts.newBase "testApp", ->
      fs.existsSync("#{DIR}/#{APP}").should.eql true

describe 'Module', ->

  it 'created a new module for a base proyect', ->
   scripts.newModule "#{MODULE}", "#{DIR}", ->
    fs.existsSync("#{DIR}/#{MODULE}").should.eql true

describe 'Link', ->

  it 'module in base proyect without error', ->
    scripts.link "#{DIR}/#{MODULE}", "#{DIR}/#{APP}/node_modules/#{MODULE}", ->
      fs.existsSync("#{DIR}/#{APP}/node_modules/#{MODULE}").should.eql true

describe 'Lift', ->
  it 'starts sails server', (done) ->
    opts =
      plugins: [MODULE]
    scripts.lift "#{DIR}/#{APP}", opts, done


describe 'Build and Lift a proyect', ->
  it 'without errors', (done) ->
    opts = log: level: 'silent'
    scripts.buildAndLift opts, done

xdescribe 'Clean a proyect', ->
  it 'without erros',->
    scripts.clean()
    fs.existsSync("#{process.cwd()}/testApp").should.eql false
