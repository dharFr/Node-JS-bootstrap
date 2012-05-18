require("coffee-script");

var app = require('./startup');

// Heroku || CloudFoundry || localhost
var port = process.env.PORT || process.env.VCAP_APP_PORT || 3000

app.listen(port);
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
