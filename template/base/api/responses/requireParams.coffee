###
Handler for require params
delegate in badRequest
###
module.exports = requireParams = (data, options) ->

  # Get access to `req`, `res`, & `sails`
  req = @req
  res = @res
  sails = req._sails

  # Data is an array of properties to check
  missing = []
  hasOwn = Object::hasOwnProperty
  Array.isArray(params) or (params = [params])

  params.forEach (param) ->
    missing.push "Missing required parameter: " + param  if not (req.body and hasOwnProperty.call(req.body, param)) and not (req.params and hasOwnProperty.call(req.params, param)) and not hasOwnProperty.call(req.query, param)

  res.badRequest(missing, options) if missing.length
