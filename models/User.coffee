db = require('../lib/db').db()
db.bind 'users',
   findByEmail: (email, fn) -> @findOne {email: email}, fn

class User
	constructor: (@email, @name) ->

	save: (fn) -> 
		User::findByEmail @email, (user) =>
			user = user || {}
			db.collection('users').update user, @, upsert: true, fn


User::findByEmail = (email, callback) ->
	db.collection('users').findByEmail email, (err, user)-> 
		if callback
			if user
				callback new User(user.email, user.name)
			else 
				callback null

module.exports =
	User: User