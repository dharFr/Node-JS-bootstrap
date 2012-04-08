express = require 'express'
assets = require 'connect-assets'
routes = require './routes'
secrets = require './lib/secrets'

app = module.exports = express.createServer()

# browserId Configuration
if process.env.VCAP_APPLICATION
	AUDIENCE = "#{JSON.parse(process.env.VCAP_APPLICATION).uris[0]}"
else
	AUDIENCE = "http://localhost:3000"
console.log "defined browserid AUDIENCE:", AUDIENCE

# mongodb config
if process.env.VCAP_SERVICES
	env = JSON.parse process.env.VCAP_SERVICES
	mongo = env['mongodb-1.8'][0]['credentials']
else
	mongo = 
		"hostname":"localhost"
		"port":27017
		"username":""
		"password":""
		"name":""
		"db":"db"

# mongodb init
require('./lib/db').init mongo

app.configure ->
	app.set 'views', __dirname + '/views'
	app.set 'view engine', 'jade'
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use express.cookieParser()
	app.use express.session secret: secrets.session
	app.use app.router
	app.use express.static(__dirname + '/public')
	app.use assets() #build: true

app.configure 'development', ->
	app.use( express.errorHandler(
		dumpExceptions: true
		showStack: true
	) )

app.configure 'production', ->
	app.use( express.errorHandler() )

# Routes
app.post '/auth', routes.auth(AUDIENCE)
app.get '/logout', routes.logout
app.get '/', routes.index
exports = app