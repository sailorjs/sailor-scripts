###
Dependencies
###
jwt = require 'jwt-simple'


###
tokenService
###
module.exports =

  validateOrigin: (url) ->
    origins = sails.config.token.origins
    origins = [origins] if typeof origins is 'string'

    return true if origins[0] is '*' or origins[0] is url
    return true for origin in origins when origin is url
    false

  validateToken: (token) ->
    return false if token is `undefined`
    try
      @decodeToken(token) is sails.config.token.payload
    catch e
      false

  encodeToken: ->
    payload   = sails.config.token.payload
    secret    = sails.config.token.secret
    algorithm = sails.config.token.algorithm

    jwt.encode(payload, secret, algorithm)

  decodeToken: (token) ->
    secret    = sails.config.token.secret
    algorithm = sails.config.token.algorithm

    jwt.decode(token, secret, algorithm)
