###
# GET home page.
###
module.exports = 
	index: (req, res) -> res.render 'index', {title: 'Sample node app', user: req.user}
