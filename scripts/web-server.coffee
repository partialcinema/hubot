# Description:
#   Web server.
#
# Dependencies:
#   
# Configuration:
#   
# Commands:
#   
# Author:
#	C. Thomas Bailey
#	Ian Edwards

express = require('express') #server
bodyParser = require('body-parser') #to read the information sent from a slack command

app = express()
app.use(bodyParser.urlencoded({ extended: false}))

getEventData = (req) ->
  eventData =
    channel:
      id: req.body.channel_id
      name: req.body.channel_name
    text: req.body.text


module.exports = (robot) ->

  handleSlackSlashCommand = (req, res) ->
    ev = getEventData req
    robot.logger.info "Got Slack slash command: #{JSON.stringify ev}"
    robot.emit 'rsvpRequested', ev
    res.sendStatus 200

	# receives the command, sends it to Helper
	app.post '/helper/rsvp', handleSlackSlashCommand

	app.get '/helper/auth', (req) ->
		robot.logger.info "Got auth request: #{JSON.stringify req.query}"

	# Actually initializes server
	server = app.listen 3000, () ->
	  host = server.address().address
	  port = server.address().port
	  robot.logger.info "Slash command server listening at http://#{host}:#{port}"
