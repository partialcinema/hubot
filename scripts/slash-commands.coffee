express = require('express')
bodyParser = require('body-parser')

app = express()
app.use(bodyParser.urlencoded({ extended: false}));

module.exports = (robot) ->
	# rec the command, sends it to Helper
	app.post '/', (req) ->
		eventData = 
			channel:
				id: req.body.channel_id
				name: req.body.channel_name
			text: req.body.text
		robot.emit 'rsvpRequested', eventData

	# Actually initializes server
	server = app.listen 3000, () ->
	  host = server.address().address
	  port = server.address().port
	  console.log "Slash command server listening at http://%s:%s", host, port