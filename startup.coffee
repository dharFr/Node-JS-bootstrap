express  = require 'express'
assets   = require 'connect-assets'
mongoose = require 'mongoose'
connect  = require 'connect'

app = module.exports = express.createServer()

# browserId Configuration
# =======================

# CloudFoundry conf
AUDIENCE = if process.env.VCAP_APPLICATION
	"#{JSON.parse(process.env.VCAP_APPLICATION).uris[0]}"
# Heroku conf
else if process.env.HOST
	process.env.HOST
# Localhost
else
	"http://localhost:3000"

console.log "defined browserid AUDIENCE:", AUDIENCE


# mongodb Configuration
# =======================

# Heroku conf
mongoUrl = if process.env.MONGOLAB_URI
  process.env.MONGOLAB_URI
else
  # CloudFoundry 'mongo conf'
  if process.env.VCAP_SERVICES
    env = JSON.parse process.env.VCAP_SERVICES
    mc = env['mongodb-1.8'][0]['credentials']
  else 
    mc = 
      "hostname":"localhost"
      "port":27017
      "username":""
      "password":""
      "name":""
      "db":"db"

  mc.hostname = mc.hostname or 'localhost'
  mc.port = mc.port or 27017
  mc.db = mc.db or 'DB'

  if mc.username and mc.password
    "mongodb://#{mc.username}:#{mc.password}@#{mc.hostname}:#{mc.port}/#{mc.db}"
  else
    "mongodb://#{mc.hostname}:#{mc.port}/#{mc.db}"

console.log "mongoUrl : #{mongoUrl}"

mongoose.connect mongoUrl, (err) ->
	if err then	throw err
	console.log 'Connected to DB'


# App Configuration
# =======================
publicDir = "#{__dirname}/public"

app.configure ->
	app.set 'views', __dirname + '/views'
	app.set 'view engine', 'jade'
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use connect.cookieParser(process.env.SECRET || 'my hard to guess secret')
	app.use connect.cookieSession(cookie: { maxAge: 30 * 60 * 1000 })
	app.use connect.csrf()
	app.use app.router
	app.use express.static publicDir
	app.use assets() #build: true

app.use (err, req, res, next) ->
	if err.status
		res.status(err.status)
	
	if err.status == 403
		res.sendfile "#{publicDir}/403.html"
	else
		next(err)

app.configure 'development', ->
	app.use( express.errorHandler(
		dumpExceptions: true
		showStack: true
	))

app.configure 'production', ->
	app.use( express.errorHandler() )

# 404 Page
app.use (req, res, next) ->
	res.status(404)
	res.sendfile "#{publicDir}/404.html"

# Routes & middlewares conf
# =========================
console.log "Loading Routes"
routes = require './routes'

console.log "Configuring URLs"

app.post '/auth', routes.auth.auth(AUDIENCE)
app.get '/logout', routes.auth.logout

needAuth = [routes.profile.loadUser, routes.profile.needUser]

app.get '/profile', needAuth, routes.profile.show
app.post '/profile', needAuth, routes.profile.save

app.get '/', routes.profile.loadUser, routes.main.index

app.helpers {
	appName: 'Sample node app'
}

app.dynamicHelpers {
	user: (req, res) -> req.user
	_csrf: (req, res) -> req.session._csrf
}

exports = app
