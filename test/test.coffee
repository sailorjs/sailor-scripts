fs        = require 'fs-extra'
should    = require 'should'
scripts   = require '../'

describe 'Build and Lift a proyect', ->
  it 'without errors', (done) ->
    opts = log: level: 'silent'
    scripts.buildAndLift opts, done

describe 'Clean a proyect', ->
  it 'without erros',->
    scripts.clean()
    fs.existsSync("#{process.cwd()}/testApp").should.eql false
