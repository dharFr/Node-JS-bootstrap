require("coffee-script");

var app = require('./startup');

app.listen(process.env.VMC_APP_PORT || 3000, process.env.VCAP_APP_HOST);
console.log("Express server running");