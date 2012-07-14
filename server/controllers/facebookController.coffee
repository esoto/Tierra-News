b64url = require("b64url")
crypto = require("crypto")
qs = require("querystring")
restler = require("restler")
util = require("util")
Faceplate = (options) ->
  self = this
  @options = options or {}
  @app_id = @options.app_id
  @secret = @options.secret
  @middleware = ->
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

  @parse_signed_request = (signed_request, cb) ->
    encoded_data = signed_request.split(".", 2)
    sig = encoded_data[0]
    json = b64url.decode(encoded_data[1])
    data = JSON.parse(json)
    throw ("unknown algorithm. expected HMAC-SHA256")  if not data.algorithm or (data.algorithm.toUpperCase() isnt "HMAC-SHA256")
    secret = self.secret
    expected_sig = crypto.createHmac("sha256", secret).update(encoded_data[1]).digest("base64").replace(/\+/g, "-").replace(/\//g, "_").replace("=", "")
    throw ("bad signature")  if sig isnt expected_sig
    unless data.user_id
      cb data
      return
    if data.access_token
      cb data
      return
    throw ("no oauth token and no code to get one")  unless data.code
    params =
      client_id: self.app_id
      client_secret: self.secret
      redirect_uri: ""
      code: data.code

    request = restler.get("https://graph.facebook.com/oauth/access_token",
      query: params
    )
    request.on "fail", (data) ->
      result = JSON.parse(data)
      console.log "invalid code: " + result.error.message
      cb()

    request.on "success", (data) ->
      cb qs.parse(data)

FaceplateSession = (plate, signed_request) ->
  self = this
  @plate = plate
  if signed_request
    @token = signed_request.access_token
    @signed_request = signed_request
  @app = (cb) ->
    self.get "/" + self.plate.app_id, (err, app) ->
      cb app

  @me = (cb) ->
    if self.token
      self.get "/me", (err, me) ->
        cb me
    else
      cb()

  @get = (path, params, cb) ->
    if cb is `undefined`
      cb = params
      params = {}
    params.access_token = self.token  if self.token
    try
      restler.get("https://graph.facebook.com" + path,
        query: params
      ).on "complete", (data) ->
        result = JSON.parse(data)
        cb null, result
    catch err
      cb err

  @fql = (query, cb) ->
    params =
      access_token: self.token
      format: "json"

    method = undefined
    onComplete = undefined
    if typeof query is "string"
      method = "fql.query"
      params.query = query
      onComplete = cb
    else
      method = "fql.multiquery"
      params.queries = JSON.stringify(query)
      onComplete = (res) ->
        return cb(res)  if res.error_code
        data = {}
        res.forEach (q) ->
          data[q.name] = q.fql_result_set

        cb data
    restler.get("https://api.facebook.com/method/" + method,
      query: params
    ).on "complete", onComplete

  @post = (params, cb) ->
    restler.post("https://graph.facebook.com/me/feed",
      query:
        access_token: self.token

      data: params
    ).on "complete", (data) ->
      result = JSON.parse(data)
      cb (if result.data then result.data else result)

module.exports.middleware = (options) ->
  new Faceplate(options).middleware()