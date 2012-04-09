User = require('../models/User').User

module.exports =
	loadUser: (req, res, next) -> 
		console.log 'loadUser middleware', req.session.email
		if req.session.email
			User::findByEmail req.session.email, (user) ->
				req.user = if user then user else new User req.session.email
				console.info '|- found:', req.user
				next()
		else
			next()

	needUser: (req, res, next) -> 
		console.log 'andRestrict middleware'
		if not req.user
			console.info 'Not Authorized'
			res.send('Not Authorized', 403);
		else
			next()

	show: (req, res, next) -> 
		console.info 'profile.show', req.user
		res.render 'profile', 
			title: 'Sample node app'
			user: req.user || {email: req.session.email}

	save: (req, res, next) -> 
		console.info 'profile.save', req.user, req.body.user
		req.user.name = req.body.user.name
		req.user.save()
		res.redirect 'back'

