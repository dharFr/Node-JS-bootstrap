https = require 'https'
qs = require 'qs'

###
# GET home page.
###
exports.index = (req, res) -> res.render 'index', {title: 'Sample node app', user: req.session.email}

###
# browserid auth
###
exports.auth = (audience) ->
	return (req, resp) ->
		onVerifyResp = (bidRes) ->
			data = ""
			bidRes.setEncoding 'utf8'
			bidRes.on 'data', (chunk) -> data += chunk

			bidRes.on 'end', ->
				verified = JSON.parse data
				resp.contentType 'application/json'

				if verified.status == 'okay'
					console.info 'browserid auth successful, setting req.session.email'
					req.session.email = verified.email
					resp.redirect '/'
				else
					console.error verified.reason
					resp.writeHead 403
				
				resp.write data
				resp.end()
		
		assertion = req.body.assertion

		body = qs.stringify
			assertion: assertion
			audience: audience

		console.info 'verifying with browserid'
		request = https.request(
			host: 'browserid.org'
			path: '/verify'
			method: 'POST'
			headers: 
				'content-type': 'application/x-www-form-urlencoded'
				'content-length': body.length
			
		, onVerifyResp)
		
		request.write body
		request.end()
	
exports.logout = (req, resp) ->
	req.session.destroy()
	resp.redirect '/'
