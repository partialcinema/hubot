# Description:
#   Verifies environment variables on the server.
#
# Dependencies:
#
# Configuration:
#
# Commands:
#
# Author:
#	C. Thomas Bailey

REQUIRED_ENV_VARS = ['HUBOT_SLACK_TOKEN', 'SLACK_API_TOKEN']

module.exports = (robot) ->
  missingVariables = REQUIRED_ENV_VARS.filter (variable) -> !process.env.hasOwnProperty variable
  if missingVariables.length > 0
    error = new Error("H.E.L.P.eR. needs these environment variables, but they weren't set: #{missingVariables}")
    robot.emit 'error', error
