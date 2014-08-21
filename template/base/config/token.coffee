###
Token API Configuration

Example of token with this configuration:
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.InNhaWxvcmpzIg.F860b-9kK3d1k8ESaFIwek_W5BMH2U8-qEE8TbTv-0k
###
module.exports.token =

  ###
  List of domain that can access to the API

  If you use '*' can be whatever domain.
  You can specify different domain as array.

  eg:
    '*'
    'http://myDomain.com'
    ['http://myDomain.com', 'http://myDomain.es']
  ###
  origins : '*'

  ###
  Secret key used for generate the token
  ###
  secret  : 'sailorjs4theWin_$$'

  ###
  The data that we want to coded
  ###
  payload: 'sailorjs'

  ###
  Algorithm for create the token
  The supported algorithms for encoding and
  decoding are HS256, HS384, HS512 and RS256.
  ###
  algorithm : 'HS256'

