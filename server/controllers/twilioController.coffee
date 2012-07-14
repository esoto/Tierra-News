TwilioClient = require('twilio').RestClient

class TwilioController

  constructor: (@app) ->
    @twilio = new TwilioClient(process.env.TWILIO_ID , process.env.TWILIO_AUTH )

    @app.use @middleware()

  middleware: =>
    return (req,res,next)  =>
      req.twilioController = @
      next()

module.exports= TwilioController