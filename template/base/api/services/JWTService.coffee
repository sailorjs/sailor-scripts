## -- Dependencies -------------------------------------------------------------

jwt         = require 'jsonwebtoken'
tokenConfig = sails.config.token

## -- Exports ------------------------------------------------------------------

module.exports =

  encode: (id) ->
    jwt.sign(id, tokenConfig.secret, tokenConfig.options)

  decode: (token, cb) ->
    jwt.verify token, tokenConfig.secret, tokenConfig.options, (err, decoded) ->
      cb(err, decoded)
