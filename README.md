#Dana#
*In Buddhism, Dāna (as in 'Donna') refers to the pure act of giving, expecting nothing in return.*

###asynchronous flow control you don't have to think about###

## The Dana Object ##

A Dana object is just an Event Emitter with a few helper methods added.

### new Dana ###
`constructor:(obj...)->`
The Dana constructor deep-scans its arguments for event emitters. If it finds any, it waits until all have fired success before firing success itself.

	people = new Dana Person.get('John Smith'), Person.get('Mary Smith')
	people.on 'success', (john, mary)-> #john and mary have loaded in this code

### .do ###
`.do( callback )`
The `.do` method is a helper alias for `.on 'success'`. It additionally encapsulates the callback in Dana, and returns the result. This enables Dana to be chained:

	people = new Dana Person.get('John Smith'), Person.get('Mary Smith')
	people.do(procreate)
	.do (progeny)-> #progeny is available to this code

Note that this code will execute the same way whether `procreate` returns an Event Emitter or an immediate result.

### .die ###
`.die( callback )`
Likewise, `.die` is a convenience method for `.on 'error'`.

	people = new Dana Person.get('John Smith'), Person.get('Mary Smith')
	people.do procreate
	people.die (error)->Muse.log 'Failed to load a parent.'
	
### .prev ###
`.prev`
Since `.do` returns the Dana for the passed-in callback, methods chain forward serially, rather than in parallel. To make parallel chains possible, each Dana stores its parent Dana under `.prev`. (`.or` and `.and` are provided for sugar).

	people = new Dana Person.get('John Smith'), Person.get('Mary Smith')
	people.do(procreate)
	.prev.do(masticate)
	# You can also use `.and` or `.or` if that seems more appropriate
	.and.do(arbitrate)
	.or.die(conflagrate)
	# Watch out— this error will trip if `people` experiences an error,
	# not `arbitrate` as you might guess

### .dana ###
`.dana( filter )`
The magic method. `.dana` simply returns a Dana which waits for its parent to fire success, and then fires success itself with the results of applying its filter function to its parent's resolution. That sounds a little unwieldy, but all it means is we can treat Dana as if they have already resolved with regards to other Dana.

	people = new Dana Person.get('John Smith'), Person.get('Mary Smith')
	sex = people.dana (john, mary)->mary.sex
	
	# Sex will resolve to 'female'... So we can pass it into another call
	# (Assuming that Person.new is Dana-wrapped)
	
	baby = Person.new(sex: sex)
	baby.do (baby)-> # `baby` (of appropriate sex) is available
	
## Oh, the possibilities! ##

Using Dana, we can forget about flow control completely, simply treat all of our async calls as having resolved, and let the events sort the whole thing out.

Let's say we're rendering a page for a concert somewhere. Using the gig id, we need to retrieve resources for the band, the venue, and the account associated with the band.

Don't think about the flow control at all; just ask for what we want.

	new Dana
		show: show = Show.get(show_id) 
		band: band = Band.get(show.dana -> @id)
		venue: venue = Venue.get(show.dana -> @venue)
		account: Account.get(band.dana -> @account)
	.do (details)->
		template.render details
	.or.die (err)->console.log 'Error loading details:', err
