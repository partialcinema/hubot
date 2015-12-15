# Ian's individual project - Mostly experimental for now.
# Thomas - I'll come to you when I feel like I have something I want to implement or get feedback on.
# https://github.com/PhobosRising/node-nextplayer

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
	onCalendarEvent: () ->
		mealMade()


module.exports = null
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

Perhaps this module should assign cooks to calendar
events rather than just holding onto a list. Then we could
ask H.E.L.P.eR who's cooking on december 25th, and it could spit
out a name.

It would have to be able to rewrite cook values on calendar events
to facilitate swapping and changes.

Other idea: separate calendar events for cooking? Each rehearsal RSVP
could also automatically create a cooking event on the rehearsal calendar.
That way, H.E.L.P.eR could just move around those events when a change 
needs to be made, without messing with the rehearsal dates themselves.
###