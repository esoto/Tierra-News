port =  process.env.PORT || 9294

if !process.env.NODE_ENV
  console.log "Loading Env Variables"
  LoadEnv = require("./loadEnv")
  LoadEnv.load()

express = require('express')
RedisController = require('./controllers/redisController')

Routes = require("./routes")
Opfserver = require("opfcli")
TwitterController = require('./controllers/twitterController')
#EmailController = require('./controllers/emailController')
ParseController = require('./controllers/parseController')

##Setup Server
app = express.createServer()
app.use express.logger()
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.session({ secret: process.env.SESSION_SECRET || 'secret123' }),
require('faceplate').middleware({
  app_id: process.env.FACEBOOK_APP_ID,
  secret: process.env.FACEBOOK_SECRET,
  scope:  'user_likes,user_photos,user_photo_video_tags'
})

new RedisController(app)

app.set 'view engine'  , 'jade'
app.set 'views' , './views'

app.use Opfserver.middleware()      
app.use(express.static("./public"))

#new EmailController(app)
new ParseController(app)    
new TwitterController(app)

routes = new Routes(app)

app.listen(port)
console.log "Listening on port " + port


app.dynamicHelpers({
  'host': function(req, res) {
    return req.headers['host'];
  },
  'scheme': function(req, res) {
    return req.headers['x-forwarded-proto'] || 'http';
  },
  'url': function(req, res) {
    return function(path) {
      return app.dynamicViewHelpers.scheme(req, res) + app.dynamicViewHelpers.url_no_scheme(req, res)(path);
    }
  },
  'url_no_scheme': function(req, res) {
    return function(path) {
      return '://' + app.dynamicViewHelpers.host(req, res) + (path || '');
    }
  },
});


render_page = (req, res) ->
  req.facebook.app (app) ->
    req.facebook.me (user) ->
      res.render "index.ejs",
        layout: false
        req: req
        app: app
        user: user
handle_facebook_request = (req, res) ->
  if req.facebook.token
    async.parallel [ (cb) ->
      req.facebook.get "/me/friends",
        limit: 4
      , (friends) ->
        req.friends = friends
        cb()
    , (cb) ->
      req.facebook.get "/me/photos",
        limit: 16
      , (photos) ->
        req.photos = photos
        cb()
    , (cb) ->
      req.facebook.get "/me/likes",
        limit: 4
      , (likes) ->
        req.likes = likes
        cb()
    , (cb) ->
      req.facebook.fql "SELECT uid, name, is_app_user, pic_square FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1 = me()) AND is_app_user = 1", (result) ->
        req.friends_using_app = result
        cb()
     ], ->
      render_page req, res
  else
    render_page req, res

app.get('/', handle_facebook_request);
app.post('/', handle_facebook_request);
