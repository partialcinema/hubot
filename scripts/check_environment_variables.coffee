REQUIRED_ENV_VARS = ['HUBOT_SLACK_TOKEN', 'SLACK_API_TOKEN', 'GOOGLE_CALENDAR_REFRESH_TOKEN']

module.exports = (robot) ->
  missingVariables = REQUIRED_ENV_VARS.filter (variable) -> !process.env.hasOwnProperty variable
  if missingVariables.length > 0
    throw new Error("H.E.L.P.eR. needs these environment variables, but they weren't set: #{missingVariables}")
