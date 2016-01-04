# Description:
#   Tracks cooking responsibilities for use with Google Calendar.
#
# Dependencies:
#   Not much
#
# Configuration:
#	I dunno yet.
#
# Commands:
# 	.resetTo		Restarts the list in default order at the name passed
# 	.whosCooking	Spits out the name of the first person on the list
# 	.mealMade		Cycles the list (i.e. moves list[0] to the end)
# 	.swapCooks		Swaps two names
#
# Author:
#	Ian Edwards
#

# stringify = require "json-stringify-safe"

capitalize = (word) ->
  word.charAt(0).toUpperCase() + word.slice 1

default_cooks = ['thomas', 'ian', 'jeff', 'adriana', 'dane']
# cooks = default_cooks

class MealCycle
	constructor: () ->
		@cooks = default_cooks

	resetTo: (starting_point) -> #resets the list to default order, starting on whoever
		@cooks = default_cooks
		start = default_cooks.indexOf(starting_point)
		@mealMade() for num in [1..start]
		return @cooks

	whosCooking: () -> # returns the next cook on the list
		console.log "It is #{capitalize @cooks[0]}'s turn to cook." #debugging only. We'll return the value to H.E.L.P.eR in the final version.
		return "It is #{capitalize @cooks[0]}'s turn to cook."

	mealMade: () -> # Rotates to the next cook on the list
		@cooks.push(@cooks.shift())
		return @cooks

	swapCooks: (cook_1, cook_2) -> # swaps 2 cooks
		if cook_1 in cooks and cook_2 in cooks
			i1 = @cooks.indexOf(cook_1)
			i2 = @cooks.indexOf(cook_2)
			[@cooks[i1], @cooks[i2]] = [cook_2, cook_1]
		else
			console.log 'Check the names and try again.'

#	onCalendarEvent: () ->
#		mealMade()


module.exports = (robot) ->
	robot.hear /dinner/i, (res) ->
		command =
			channel:
				id: res.message.rawMessage.channel
        name: res.message.room
			type:

		robot.emit

	robot.on 'cookCommand', (request, command, message) ->
	    envelope = room: request.channel.id

	    robot.send envelope, command
		robot.emit command.message

#####################################
#mealCycle = new MealCycle()

#mealCycle.whosCooking()

#mealCycle.mealMade()
#mealCycle.mealMade()
#mealCycle.mealMade()

#mealCycle.whosCooking()

#mealCycle.swapCooks('dane', 'ian')



### Model View Controller:
3 parts:
	Model - internal state of the application
		internal logic, i.e. list, etc.

		model 2 things:
			meal cycle
			tie that to google calendar on the fly

	View - displays to user
		calendar in this case
	controller - logic that connects the two
		updates calendar to match the model

###


###
Other implementation ideas:
  Assign next cook to description on rehearsal confirmation by default
    extra command to omit food for a particular rehearsal
    Call mealMade at the END of the rehearsal period
  swapCooks, whosCooking, and resetTo can be called using /dinner

  Other idea: separate calendar events for cooking?
    That way, H.E.L.P.eR could just move around those events when a change
    needs to be made, without messing with the rehearsal dates themselves.
###
