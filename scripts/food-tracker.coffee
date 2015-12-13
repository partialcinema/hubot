# Ian's individual project - Mostly experimental for now.
# Thomas - I'll come to you when I feel like I have something I want to implement or get feedback on.
# https://github.com/PhobosRising/node-nextplayer
stringify = require "json-stringify-safe"


default_cooks = ['thomas', 'ian', 'jeff', 'adriana', 'dane']
cooks = default_cooks

mealCycle =  
	cooks: default_cooks
	
	resetTo: (starting_point) -> #resets the list to default order, starting on whoever
		this.cooks = default_cooks
		start = default_cooks.indexOf(starting_point)
		this.mealMade() for num in [1..start]
		return @cooks

	whosCooking: () -> # returns the next cook on the list
		console.log this.cooks[0]

	mealMade: () -> # Rotates to the next cook on the list
		cooks.push(cooks.shift())
		return cooks

	swapCooks: (cook_1, cook_2) -> # swaps 2 cooks

	onCalendarEvent: () ->
		mealMade()

#####################################

mealCycle.resetTo('ian')
mealCycle.whosCooking()

mealCycle.mealMade()
mealCycle.whosCooking()

mealCycle.mealMade()
mealCycle.whosCooking()

mealCycle.mealMade()
mealCycle.whosCooking()

mealCycle.mealMade()
mealCycle.whosCooking()

mealCycle.mealMade()
mealCycle.whosCooking()

mealCycle.resetTo('thomas')
mealCycle.whosCooking()

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