###
Dependencies
###
sailor    = require 'sailorjs'
chalk     = require 'sailorjs/node_modules/chalk'
translate = sailor.translate
errorify  = sailor.errorify


###
hasToken Middleware

Check if the request can access to the API endopoin.
Also check if token param exist and check if the value
is the correct
###
module.exports = (req, res, next) ->

  sails  = req._sails
  token  = req.param 'token'
  url    = req.baseUrl

  unless tokenService.validateOrigin(url)
    err = msg: translate.get("Token.InvalidOrigin")
    sails.log.debug "Token Middleware :: #{chalk.red('request')} from #{chalk.cyan(url)}"
    return res.invalid(errorify.serialize(err))

  unless tokenService.validateToken(token)
    err = msg: translate.get("Token.InvalidKey")
    sails.log.debug "Token Middleware :: #{chalk.green('request')} and #{chalk.red('token')} from #{chalk.cyan(url)}"
    return res.invalid(errorify.serialize(err))

  sails.log.debug "Token Middleware :: #{chalk.green('request')} and #{chalk.green('token')} from #{chalk.cyan(url)}"
  next()
