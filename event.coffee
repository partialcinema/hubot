chrono = require('chrono-node')
moment = require('moment')

class Event
  constructor: (request) ->
    @time = parseTime request.text
    @type = parseType request.channel.name, request.text
    @valid = !!(@time and @type)
    @description = if @valid then describe(@) else null
    @channel = request.channel

  parseType = (channelName, text) ->
    matchesRehearsal = text.match /rehearsal/i
    matchesShow = text.match /show/i

    eventType = if matchesRehearsal and !matchesShow
      'rehearsal'
    else if matchesShow and !matchesRehearsal
      'show'
    else if channelName is '#shows' or channelName is '#booking'
      'show'
    else if channelName is '#rehearsal'
      'rehearsal' 
    else
      null
    eventType

  parseTime = (text) ->
    eventTime = chrono.parse(text)[0]
    unless eventTime?
      return null
    startTime = eventTime.start.date()
    endTime = eventTime.end?.date?() || moment(startTime).add(3, 'hours').toDate()
    start: startTime, end: endTime

  describe = (event) ->
    eventPhrase = if event.type is 'rehearsal' then 'rehearsal' else 'a show'
    startPhrase = moment(event.time.start).calendar()
    endPhrase = moment(event.time.end).calendar()
    "#{eventPhrase} from #{startPhrase} to #{endPhrase}"

module.exports = Event
