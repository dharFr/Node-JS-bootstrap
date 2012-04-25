express  = require 'express'
assets   = require 'connect-assets'
mongoose = require 'mongoose'
connect  = require 'connect'

app = module.exports = express.createServer()

# browserId Configuration
if process.env.HOST
	AUDIENCE = process.env.HOST
else
	AUDIENCE = "http://localhost:3000"

console.log "defined browserid AUDIENCE:", AUDIENCE


# mongodb config
mongoUrl = process.env.MONGOLAB_URI|| "mongdb://localhost:27017/db"

console.log "mongoUrl : #{mongoUrl}"

mongoose.connect(mongoUrl, (err) ->
	if err then	throw err

	console.log 'Connected to DB'
)

# init routes
routes = require './routes'

console.log "Routes loaded"

publicDir = "#{__dirname}/public"

app.configure ->
	app.set 'views', __dirname + '/views'
	app.set 'view engine', 'jade'
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use connect.cookieParser(process.env.SECRET || 'my hard to guess secret')
	app.use connect.cookieSession(cookie: { maxAge: 30 * 60 * 1000 })
	app.use app.router
	app.use express.static publicDir
	app.use assets() #build: true

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

console.log "Configuring URLs"
# Routes
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
}

exports = app
