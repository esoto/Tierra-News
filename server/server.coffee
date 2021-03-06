port =  process.env.PORT || 9294

if !process.env.NODE_ENV
  console.log "Loading Env Variables"
  LoadEnv = require("./loadEnv")
  LoadEnv.load()

express = require('express')
# RedisController = require('./controllers/redisController')


Routes = require("./routes")
Opfserver = require("opfcli")
TwitterController = require('./controllers/twitterController')
#EmailController = require('./controllers/emailController')
ParseController = require('./controllers/parseController')
FacebookController = require('./controllers/facebookController')


##Setup Server
app = express.createServer()
app.use express.logger()
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.session({ secret: process.env.SESSION_SECRET || 'secret123' }),


# new RedisController(app)

app.set 'view engine'  , 'jade'
app.set 'views' , './views'

app.use Opfserver.middleware()      
app.use(express.static("./public"))

#new EmailController(app)
new ParseController(app)    
new TwitterController(app)
new FacebookController(app)

routes = new Routes(app)

app.listen(port)
console.log "Listening on port " + port

