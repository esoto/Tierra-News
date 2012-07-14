
class Routes

  constructor: (@app) ->    
    @app.use @middleware()
    @setupRoutes()

  middleware: =>
    return (req,res,next)  =>
      return next() if req.method != "GET"
      req.parseController.kaiseki.getObjects "posts", {},  (err, res, body) -> 
        req.posts = body
        next()


  setupRoutes: ->
    @app.get "/:link?" , (req,res) ->
      auth = req.session.authData  || null
      req.session.authData = null
      link = "'#{req.params.link}'" || false
      res.render "list" , { authData: JSON.stringify(auth) , posts: JSON.stringify(req.posts) , current: link  }



    

module.exports = Routes
