# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

# To use the robot's 'reaction' event, you have to modify hubot-slack/src/slack.coffee
# 
# First, add an event listener on the node-slack-client 'raw_message' event
# @client.on 'raw_message', @.reaction
#
# Then define a reaction listener
# reaction: (msg) =>
#   if msg.type == "reaction_removed" or msg.type == "reaction_added"
#     user = @robot.brain.userForId msg.user
#     channel = @client.getChannelGroupOrDMByID msg.item.channel if msg.item.channel
#     reaction = message: msg, user: user, channel: channel
#     @robot.emit 'reaction', reaction

stringify = require('json-stringify-safe')
chrono = require('chrono-node')
moment = require('moment')

TEAM_SIZE = 5

module.exports = (robot) ->
  parseEventType = (request) ->
    matchesRehearsal = request.text.match /rehearsal/i
    matchesShow = request.text.match /show/i

    eventType = if matchesRehearsal and !matchesShow
      'rehearsal'
    else if matchesShow and !matchesRehearsal
      'show'
    else if request.channel is '#shows' or request.channel is '#booking'
      'show'
    else if request.channel is '#rehearsal'
      'rehearsal' 
    else
      err = new Error('Unknown event type')
      err.rsvpRequest = request
      throw err
    eventType

  parseEventTime = (request) ->
    eventTime = chrono.parse(request.text)[0]
    unless eventTime?
      err = new Error('Cannot parse event time')
      err.rsvpRequest = request
      throw err
    startTime = eventTime.start.date()
    endTime = eventTime.end?.date?() || moment(startTime).add(3, 'hours').toDate()
    start: startTime, end: endTime
  
  requestRSVP = (eventType, startTime, endTime, request) ->
    eventPhrase = if eventType is 'rehearsal' then 'rehearsal' else 'a show'
    startPhrase = moment(startTime).calendar()
    endPhrase = moment(endTime).calendar()
    robot.send room: request.channel.id, "@channel: RSVP for #{eventPhrase} from #{startPhrase} to #{endPhrase}\nhttp://images.wookmark.com/142491_tumblr_ma2idwljpj1rcnp56o1_1280.png"

  robot.hear /rsvp/i, (res) ->
    request =
      channel:  
        id: res.message.rawMessage.channel 
        name: res.message.room 
      text: res.message.rawText
    robot.emit 'rsvpRequested', request

  robot.on 'rsvpRequested', (request) ->
    envelope = room: request.channel.id
    try 
      eventTime = parseEventTime request
      eventType = parseEventType request
    catch error
      if error.message is 'Unknown event type'
        robot.send envelope, "Not sure if you meant rehearsal or show."
        return
      if error.message is 'Cannot parse event time'
        robot.send envelope, "Not sure when that event is supposed to be."
        return
    requestRSVP(eventType, eventTime.start, eventTime.end)

  robot.on 'reaction', (reaction) ->  
    envelope = room: reaction.channel.id
    gotMessage = (message) ->
      if isConfirmedRSVP message
        # parse event
        robot.send envelope, "Confirmed event!"
        #robot.emit('eventConfirmed', event)
    # find out how many reactions that message has
    getSlackMessage reaction.channel, reaction.message.item.ts, gotMessage 
            
  isConfirmedRSVP = (message) ->
    usersThatReacted = []
    for reaction in message.reactions
      for user in reaction.users
        usersThatReacted.push user unless user in usersThatReacted
    isConfirmed = usersThatReacted.length is TEAM_SIZE
    isRSVP = message.text.match /rsvp/i

    isConfirmed and isRSVP

  getSlackMessage = (channel, messageTimeStamp, callback) ->
    apiRequestComplete = (data) ->
      message = data.messages[0]
      callback message
    apiMethod = if channel.is_im
      'im.history'
    else 
      'channels.history'
    params =
      channel: channel.id
      latest: messageTimeStamp
      oldest: messageTimeStamp
      inclusive: 1
    makeSlackApiRequest apiMethod, params, apiRequestComplete

  makeSlackApiRequest = (apiMethod, queryParams, callback) ->
    slackApiToken = process.env.SLACK_API_TOKEN
    url = "https://slack.com/api/#{apiMethod}?token=#{slackApiToken}"
    for own key of queryParams
      value = queryParams[key]
      url += "&#{key}=#{value}"
    robot.http(url).header('Accept', 'application/json').get() (err, res, body) ->
      if err
        throw err
      else
        data = JSON.parse body
        callback data
  
  # robot.respond /open the (.*) doors/i, (res) ->
  #   doorType = res.match[1]
  #   if doorType is "pod bay"
  #     res.reply "I'm afraid I can't let you do that."
  #   else
  #     res.reply "Opening #{doorType} doors"
  #
  # robot.hear /I like pie/i, (res) ->
  #   res.emote "makes a freshly baked pie"
  #
  # lulz = ['lol', 'rofl', 'lmao']
  #
  # robot.respond /lulz/i, (res) ->
  #   res.send res.random lulz
  #
  # robot.topic (res) ->
  #   res.send "#{res.message.text}? That's a Paddlin'"
  #
  #
  # enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
  # leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  #
  # robot.enter (res) ->
  #   res.send res.random enterReplies
  # robot.leave (res) ->
  #   res.send res.random leaveReplies
  #
  # answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  #
  # robot.respond /what is the answer to the ultimate question of life/, (res) ->
  #   unless answer?
  #     res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
  #     return
  #   res.send "#{answer}, but what is the question?"
  #
  # robot.respond /you are a little slow/, (res) ->
  #   setTimeout () ->
  #     res.send "Who you calling 'slow'?"
  #   , 60 * 1000
  #
  # annoyIntervalId = null
  #
  # robot.respond /annoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #     return
  #
  #   res.send "Hey, want to hear the most annoying sound in the world?"
  #   annoyIntervalId = setInterval () ->
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #   , 1000
  #
  # robot.respond /unannoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "GUYS, GUYS, GUYS!"
  #     clearInterval(annoyIntervalId)
  #     annoyIntervalId = null
  #   else
  #     res.send "Not annoying you right now, am I?"
  #
  #
  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   data   = JSON.parse req.body.payload
  #   secret = data.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  # robot.error (err, res) ->
  #   robot.logger.error "DOES NOT COMPUTE"
  #
  #   if res?
  #     res.reply "DOES NOT COMPUTE"
  #
  # robot.respond /have a soda/i, (res) ->
  #   # Get number of sodas had (coerced to a number).
  #   sodasHad = robot.brain.get('totalSodas') * 1 or 0
  #
  #   if sodasHad > 4
  #     res.reply "I'm too fizzy.."
  #
  #   else
  #     res.reply 'Sure!'
  #
  #     robot.brain.set 'totalSodas', sodasHad+1
  #
  # robot.respond /sleep it off/i, (res) ->
  #   robot.brain.set 'totalSodas', 0
  #   res.reply 'zzzzz'
