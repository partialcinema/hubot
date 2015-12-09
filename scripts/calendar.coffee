stringify = require "json-stringify-safe"
gcal = require "google-calendar"
moment = require "moment"

accessToken = null # will 401 the first time, and refresh the token
refreshToken = process.env.GOOGLE_CALENDAR_REFRESH_TOKEN

calendar = new gcal.GoogleCalendar(accessToken)
calendarIDs = 
	rehearsals:'scromh7crg9cm0u695pumsrb4o@group.calendar.google.com'
	shows:'m0crma3ead736lct9r0f88s1sk@group.calendar.google.com'
	other:'ghptaulpabvqsefm19cfhokh54@group.calendar.google.com'


createEvent = (type, parameters, callback) ->
	calendarID = calendarIDs[type]
	calendar.events.insert calendarID, parameters, callback

refreshIfUnauthorized = (err, data) ->
	if err.errors.code is 401 # Will throw error once at the beginning of a session in order to refresh the token
		#refresh access token
		#try again
	else if err
		console.log err
	else
		console.log "Event Created in Google Calendar: #{stringify data}" 

explodeIfUnauthorized = (err, data) ->
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

		createEvent ev.type, parameters, () ->


		
			





# gcal.resource.method ( required_param1, required_param2, optional, callback )
# gcal.events.insert
# gcal.events.quickAdd

# PC Rehearsals: scromh7crg9cm0u695pumsrb4o@group.calendar.google.com
# PC Shows: m0crma3ead736lct9r0f88s1sk@group.calendar.google.com
# PC Other: ghptaulpabvqsefm19cfhokh54@group.calendar.google.com

# access token: ya29.RAL_M_-GHq020PfI3k-Q4Lt0VABtdAofukeBzhVyqG99pHDj3QTO87S6tT7sA_cAwazm
# refresh token: 1/HQv3x7z_dx8QGLPUx-o1_BI8vsfjzafZsQdVoOCaejc