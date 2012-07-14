b64url = require("b64url")
crypto = require("crypto")
qs = require("querystring")
restler = require("restler")
util = require("util")

class FacebookController
  constructor: (@app) ->
    self = this
    @options = options or {}
    @app_id = process.env.FACEBOOK_APP_ID
    @secret = process.env.FACEBOOK_APP_SECRET

    @app.use @middleware()
    
  middleware: =>
    (req, res, next) ->
      if req.body.signed_request
        self.parse_signed_request req.body.signed_request, (decoded_signed_request) ->
          req.facebook = new FaceplateSession(self, decoded_signed_request)
          next()
      else if req.cookies["fbsr_" + self.app_id]
        self.parse_signed_request req.cookies["fbsr_" + self.app_id], (decoded_signed_request) ->
          req.facebook = new FaceplateSession(self, decoded_signed_request)
          next()
      else
        req.facebook = new FaceplateSession(self)
        next()
