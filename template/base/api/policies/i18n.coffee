## -- Dependencies -------------------------------------------------------------

sailor    = require 'sailorjs'
translate = sailor.translate

## -- Exports ------------------------------------------------------------------

module.exports = (req, res, next) ->

  sails    = req._sails
  locales  = sails.config.i18n.locales
  _default = sails.config.i18n.defaultLocale
  lang     = req.param 'lang'

  lang = req.language or _default unless lang?

  # updated the language in `req` and `translate`
  req.language = lang
  req.region   = lang
  translate.lang lang
  req.params.lang ?= lang

  sails.log.debug "i18n Middleware :: Language is #{lang}"
  next()
