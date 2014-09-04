## -- Dependencies -------------------------------------------------------------

jwt       = require 'jsonwebtoken'
sailor    = require 'sailorjs'
translate = sailor.translate
errorify  = sailor.errorify

## -- Exports -------------------------------------------------------------

module.exports = (req, res, next) ->
  token = undefined
  if req.method is "OPTIONS" and req.headers.hasOwnProperty("access-control-request-headers")
    hasAuthInAccessControl = !!~req.headers["access-control-request-headers"].split(",").map((header) ->
      header.trim()
    ).indexOf("authorization")
    return next() if hasAuthInAccessControl

  if req.headers and req.headers.authorization
    parts = req.headers.authorization.split(" ")
    if parts.length is 2
      scheme      = parts[0]
      credentials = parts[1]
      token       = credentials  if /^Bearer$/i.test(scheme)
    else
      err = msg: translate.get("Token.BadFormat")
      return res.badRequest(errorify.serialize(err))
  else
    err = msg: translate.get("Token.NotFound")
    return res.badRequest(errorify.serialize(err))

  JWTService.decode token, (err, decoded) ->
    if (err)
      if err.name is 'TokenExpiredError'
        error = msg: translate.get("Token.Expired")
        return res.badRequest(errorify.serialize(error))
      else
        ## TODO: Translate
        return res.badRequest(errorify.serialize(err))
    else
      req.user = decoded
      next()
