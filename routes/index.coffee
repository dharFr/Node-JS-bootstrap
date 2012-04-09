# Misc
main = require './main'
# Profile access
profile = require './profile'
# Browserid auth
auth = require './auth'

module.exports = 
	main: main
	profile: profile
	auth: auth
