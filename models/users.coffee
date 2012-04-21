mongoose = require('mongoose')

Schema = mongoose.Schema

UserSchema = new Schema({
	name      : String,
	firstName : String,
	email     : String
})

UserSchema.statics.findByEmail = (email, cb) ->
	@findOne({email: email}, (err, user) ->
		if err then throw err
		cb(user)
	)


UserSchema.on('init', (model) ->
  console.log 'Initializing UserSchema'
)

exports.User = mongoose.model('User', UserSchema)

