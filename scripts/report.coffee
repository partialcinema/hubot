# Description:
#   Exports a function that sends messages to #dev.
#   Used for reporting errors.
#
# Dependencies:
#   
# Configuration:
#   
# Commands:
#   
# Author:
#	C. Thomas Bailey
#	Ian Edwards
stringify = require 'json-stringify-safe'

module.exports = (robot) ->
  robot.error (err, response) ->
    # dev channel
    envelope: {"room":"C06BW08JU"}
    robot.send envelope, "Just got an error:\n#{stringify err}"
