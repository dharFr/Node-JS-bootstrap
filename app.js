require("coffee-script");

var app = require('./startup');

var port = process.env.PORT || 3000

app.listen(port);
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
