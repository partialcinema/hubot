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

soonest = (momentX, momentY) ->
  if momentX.isBefore momentY
    momentX
  else
    momentY

module.exports = (robot) ->
  class RSVP 
    constructor: (eventType, @request, startTime, endTime) ->
      @state = 'pending'
      @reactions = []

      # if no end time, default to three hours after start time
      endTime ||= moment(startTime).add(3, 'hours').toDate()

      @event = 
        type: eventType
        start: startTime
        end: endTime

      # automatically cancel this RSVP if it is not confirmed
      # in one week or by the start of the event, whichever is sooner
      startingMoment = moment(startTime)
      oneWeekFromNow = moment().add(1, 'weeks')
      now = moment()
      timeTilCancellation = soonest(startingMoment, oneWeekFromNow).subtract(now).milliseconds()
      emitCanceled = () => robot.emit 'rsvpCanceled', @
      timeoutID = setTimeout emitCanceled, timeTilCancellation
      @cancel = () => 
        clearTimeout(timeoutID)
        @state = 'canceled'

  parseEventType = (request) ->
    isRehearsal = request.text.match /rehearsal/i
    isShow = request.text.match /show/i

    eventType = if isRehearsal and !isShow
      'rehearsal'
    else if isShow and !isRehearsal
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
  
  requestRSVP = (channelId, rsvp) ->
    eventPhrase = if rsvp.event.type is 'rehearsal' then 'rehearsal' else 'a show'
    start = moment(rsvp.event.start).calendar()
    end = moment(rsvp.event.end).calendar()
    robot.send room: rsvp.request.channel.id, "@channel: RSVP for #{eventPhrase} from #{start} to #{end}"

  robot.hear /rsvp/i, (res) ->
    request =
      channel:  
        id: res.message.rawMessage.channel 
        name: res.message.room 
      text: res.message.rawText
    robot.emit 'rsvpRequested', request

  robot.on 'rsvpRequested', (request) ->
    envelope = room: request.channel.id
    eventTime = chrono.parse(request.text)[0]
    eventType = parseEventType request
    rsvp = new RSVP(eventType, request, eventTime.start.date(), eventTime.end?.date?())
    requestRSVP(request.channel.id, rsvp)

  robot.on 'reaction', (reaction) -> 
    envelope = room: reaction.channel.id
    robot.send envelope, "reaction: #{stringify(reaction)}"
  
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
