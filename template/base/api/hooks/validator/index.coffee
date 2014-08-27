expressValidator = require('sailorjs/node_modules/sailor-validator/node_modules/express-validator')

module.exports = (sails) ->
  routes:
    before:
      "*": expressValidator()

