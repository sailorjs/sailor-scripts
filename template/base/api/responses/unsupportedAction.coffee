###
405 (Unsupported Action) Handler

Usage:
return res.unsupportedAction();
return res.unsupportedAction(data);
return res.unsupportedAction(data, 'some/specific/unsupportedAction/view');

e.g.:
```
return res.unsupportedAction(
'Please choose a valid `password` (6-12 characters)',
'trial/signup'
);
```
###
module.exports = unsupportedAction = (data, options) ->

  # Get access to `req`, `res`, & `sails`
  req = @req
  res = @res
  sails = req._sails

  # Set status code
  res.status 405

  # Log error to console
  if data isnt `undefined`
    sails.log.verbose "Sending 405 (\"Unsupported Action\") response: \n", data
  else
    sails.log.verbose "Sending 405 (\"Unsupported Action\") response"

  # Only include errors in response if application environment
  # is not set to 'production'.  In production, we shouldn't
  # send back any identifying information about errors.
  data = `undefined`  if sails.config.environment is "production"

  # If the user-agent wants JSON, always respond with JSON
  return res.jsonx(data)  if req.wantsJSON

  # If second argument is a string, we take that to mean it refers to a view.
  # If it was omitted, use an empty object (`{}`)
  options = (if (typeof options is "string") then view: options else options or {})

  # If a view was provided in options, serve it.
  # Otherwise try to guess an appropriate view, or if that doesn't
  # work, just send JSON.
  if options.view
    res.view options.view,
      data: data


  # If no second argument provided, try to serve the implied view,
  # but fall back to sending JSON(P) if no view can be inferred.
  else
    res.guessView
      data: data
    , couldNotGuessView = ->
      res.jsonx data

