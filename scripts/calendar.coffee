# Description:
#   Handles interaction with Google Calendar API.
# Dependencies:
#   
# Configuration:
#   
# Commands:
#   
# Author:
#	C. Thomas Bailey
#	Ian Edwards

google = require "googleapis"
googleAuth = require "../google-auth.coffee"
calendar = google.calendar version: 'v3', auth: googleAuth
moment = require "moment"
stringify = require "json-stringify-safe"

calendarIds = 
	rehearsal:'scromh7crg9cm0u695pumsrb4o@group.calendar.google.com'
	show:'m0crma3ead736lct9r0f88s1sk@group.calendar.google.com'
	other:'ghptaulpabvqsefm19cfhokh54@group.calendar.google.com'

createEvent = (type, parameters, callback) ->
	parameters.calendarId = calendarIds[type]
	calendar.events.insert parameters, callback

explodeIfError = (err, data) ->
	if err
		throw new Error(err)

module.exports = (robot) ->
	robot.on 'eventConfirmed', (ev) ->
		parameters = 
			resource:
				summary: ev.type
				location: '214 Eaglewood Ct.'
				start:
					dateTime: moment.utc(ev.time.start).toISOString()
				end:
					dateTime: moment.utc(ev.time.end).toISOString()
		createEvent ev.type, parameters, explodeIfError