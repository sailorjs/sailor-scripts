###
Dependencies
###
sailor    = require 'sailorjs'
translate = sailor.translate

###
Bootstrap
(sails.config.bootstrap)

An asynchronous bootstrap function that runs before your Sails app gets lifted.
This gives you an opportunity to set up your data model, run jobs, or perform some special logic.

For more information on bootstrapping your app, check out:
http://links.sailsjs.org/docs/config/bootstrap
###
module.exports.bootstrap = (cb) ->
  translate.add sails.config.translations
  cb()
