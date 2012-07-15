restler = require("restler")

class FacebookController
  
  constructor: (@app) ->
    @app.use @middleware()

  middleware: =>
    return (req , res , next)  =>
      console.log "facbook pass"
      req.facebookController = @
      return @startAuth(req,res) if(req.url?.indexOf("/sessions/facebook/login")     == 0)
      return @finishAuth(req,res) if(req.url?.indexOf("/sessions/facebook/callback")  == 0)
      next()
    
  startAuth: (req,res)->
    url = "https://www.facebook.com/dialog/oauth?
      client_id=135615446577396
     &redirect_uri=http://localhost:9294/sessions/facebook/callback"
    
    restler.get(url).on "complete", (result) =>
      if result instanceof Error
        sys.puts "Error: " + result.message
        @retry 5000
      else
        res.send result

  finishAuth:(req,res) ->
    console.log arguments

module.exports = FacebookController
