express = require('express') #server
bodyParser = require('body-parser') #to read the information sent from a slack command

app = express()
app.use(bodyParser.urlencoded({ extended: false}));

module.exports = (robot) ->
	# recieves the command, sends it to Helper
	app.post '/', (req) ->
		eventData = 
			channel:
				id: req.body.channel_id
				name: req.body.channel_name
			text: req.body.text
		robot.emit 'rsvpRequested', eventData

	app.get '/google/auth', (req) ->
		console.log 'Got auth request'

	# Actually initializes server
	server = app.listen 3000, () ->
	  host = server.address().address
	  port = server.address().port
	  console.log "Slash command server listening at http://%s:%s", host, port