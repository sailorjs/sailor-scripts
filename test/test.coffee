fs        = require 'fs-extra'
should    = require 'should'
scripts   = require '../'

DEFAULT_NAME = 'testApp'

describe 'Created a new Base Proyect', ->

  it 'create and copy the files of the proyect', ->
    scripts.newBase(->
      fs.existsSync("#{process.cwd()}/#{DEFAULT_NAME}").should.eql true
    )


  # it 'without errors',  ->
    # scripts.newBase
    # fs.existsSync("#{process.cwd()}/testApp").should.eql true


xdescribe 'Build and Lift a proyect', ->
  it 'without errors', (done) ->
    opts = log: level: 'silent'
    scripts.buildAndLift opts, done

xdescribe 'Clean a proyect', ->
  it 'without erros',->
    scripts.clean()
    fs.existsSync("#{process.cwd()}/testApp").should.eql false
