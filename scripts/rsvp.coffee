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
Event = require('../event')

# if running in a production environment,
# listen for 5 reactions to confirm an
# event. Otherwise, only listen for 1.
if process.env.NODE_ENV is 'production'
  TEAM_SIZE = 5
else
  TEAM_SIZE = 1

module.exports = (robot) ->
  robot.hear /rsvp/i, (res) ->
    request =
      channel:
        id: res.message.rawMessage.channel
        name: res.message.room
      text: res.message.rawText
    robot.emit 'rsvpRequested', request

  robot.on 'rsvpRequested', (request) ->
    envelope = room: request.channel.id
    event = new Event(request)
    unless event.type?
      robot.send envelope, "Not sure if you meant rehearsal or show."
    else unless event.time?
      robot.send envelope, "Not sure when that event is supposed to be."
    else
      robot.send envelope, "@channel: RSVP for #{event.description}"

  robot.on 'reaction', (reaction) ->
    gotMessage = (message) ->
      if isConfirmedRSVP message
        event = new Event(channel: reaction.channel, text: message.text)
        if event.valid
          envelope = room: reaction.channel.id
          robot.send envelope, "Confirmed #{event.description}"
          robot.emit('eventConfirmed', event)
    # find out how many reactions the message has
    getSlackMessage reaction.channel, reaction.message.item.ts, gotMessage

  isConfirmedRSVP = (message) ->
    unless message.reactions?
      return false
    usersThatReacted = []
    for reaction in message.reactions
      for user in reaction.users
        usersThatReacted.push user unless user in usersThatReacted
    isConfirmed = usersThatReacted.length is TEAM_SIZE
    isRSVP = message.text.match /rsvp/i
    isConfirmed and isRSVP

  getSlackMessage = (channel, messageTimeStamp, gotMessage) ->
    apiRequestComplete = (data) ->
      message = data.messages[0]
      gotMessage message
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

  makeSlackApiRequest = (apiMethod, queryParams, apiRequestComplete) ->
    slackApiToken = process.env.SLACK_API_TOKEN
    url = "https://slack.com/api/#{apiMethod}?token=#{slackApiToken}"
    for own key of queryParams
      value = queryParams[key]
      url += "&#{key}=#{value}"
    robot.http(url).header('Accept', 'application/json').get() (err, res, body) ->
      if err
        robot.emit 'error', new Error(err)
      else
        data = JSON.parse body
        apiRequestComplete data
