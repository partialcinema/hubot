google = require "googleapis"
calendar = google.calendar 'v3'
moment = require "moment"
stringify = require "json-stringify-safe"

CLIENT_ID = '650934664824-9jkko6s2klfnsncep2h1bbl9n01fepju.apps.googleusercontent.com'
CLIENT_SECRET = 'mPReJ6Hv-oJ3gcvDL2v2d6iY'

OAuth2 = google.auth.OAuth2
oauth2Client = new OAuth2 CLIENT_ID, CLIENT_SECRET, 'http://dev.partialcinema.com/google/auth'

accessToken = null # will 401 the first time, and refresh the token
refreshToken = process.env.GOOGLE_CALENDAR_REFRESH_TOKEN

oauth2Client.setCredentials
  access_token: accessToken
  refresh_token: refreshToken

calendarIds = 
	rehearsals:'scromh7crg9cm0u695pumsrb4o@group.calendar.google.com'
	shows:'m0crma3ead736lct9r0f88s1sk@group.calendar.google.com'
	other:'ghptaulpabvqsefm19cfhokh54@group.calendar.google.com'

createEvent = (type, parameters, callback) ->
	parameters.calendarId = calendarIds[type]
	calendar.events.insert parameters, callback

refreshIfUnauthorized = (type, parameters) ->
	(err, data) ->
#		if err.errors.code is 401 # Will throw error once at the beginning of a session in order to refresh the token
#			#refresh google access token
#			createEvent type, parameters, explodeIfError
#		else
#			explodeIfError err, data
		console.log stringify err
		console.log stringify data

explodeIfError = (err, data) ->
	if err
		throw new Error(err)
	else
		console.log "Event Created in Google Calendar: #{stringify data}" 

module.exports = (robot) ->
	robot.on 'eventConfirmed', (ev) ->
		parameters = 
			summary: ev.type
			location: '214 Eaglewood Ct.'
			start:
				dateTime: moment(ev.time.start).toISOString()
			end:
				dateTime: moment(ev.time.end).toISOString()
			auth: oauth2Client

		createEvent ev.type, parameters, refreshIfUnauthorized(ev.type, parameters)


# client ID: 650934664824-9jkko6s2klfnsncep2h1bbl9n01fepju.apps.googleusercontent.com
# client secret: mPReJ6Hv-oJ3gcvDL2v2d6iY