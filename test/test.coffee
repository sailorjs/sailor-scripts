fs        = require 'fs-extra'
should    = require 'should'
scripts   = require '../'

DIR    = process.cwd()
APP    = 'testApp'
MODULE = "sailor-module-test"

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
      log: level: "silent"
      plugins: [MODULE]
    scripts.lift "#{DIR}/#{APP}", opts, done

xdescribe 'Build and Lift a proyect', ->
  it 'without errors', (done) ->
    opts = log: levailel: 'silent'
    scripts.buildAndLift opts, done

describe 'Clean a proyect', ->
  it 'without errors',->
    scripts.clean "#{DIR}/#{APP}"
    scripts.clean "#{DIR}/#{MODULE}"
    fs.existsSync("#{DIR}/#{APP}").should.eql false
    fs.existsSync("#{DIR}/#{MODULE}").should.eql false
