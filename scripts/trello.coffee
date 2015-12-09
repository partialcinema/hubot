Trello = require "node-trello"
stringify = require "json-stringify-safe"
t = new Trello process.env.TRELLO_API_KEY, process.env.TRELLO_AUTH_TOKEN

REHEARSAL_LIST_ID = "54eb3b3dfdb230279a7de1be"
SHOWS_LIST_ID = "54ee81eb99350b65e55cf902"

# t.get "/1/members/me", (err, data) ->
#  	if err throw err
#  	console.log data
#
# URL arguments are passed in as an object.
# t.get "/1/members/me", { cards: "open" }, (err, data) ->
#  	if err throw err
#  	console.log data

# listID = (eventType) ->
#	if eventType is 'rehearsal'
#		REHEARSAL_LIST_ID
#	else if eventType is 'show'
#		SHOWS_LIST_ID

module.exports = (robot) ->
#	robot.on 'eventConfirmed', (ev) ->
#		
#		newCardParams = 
#			name: ev.type
#			due: ev.time.start 
#			idList: listID(ev.type)
#			urlSource: null
#						 
#		t.post "/1/cards", newCardParams, (err) ->
#			if err 
#				throw err
#