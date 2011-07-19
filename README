#Dana#
*In Buddhism, Dāna (as in 'Donna') refers to the pure act of giving, expecting nothing in return.*

###Dana is asynchronous flow control you don't have to think about.###

Dana objects are event emitters which encapsulate event emitters. 

	people = new Dana Person.get('John Smith'), Person.get('Mary Smith')

When all emitters encapsulated have fired success, the Dana itself fires success with their results.

	people.do (john, mary)->console.log john.sex, mary.sex
	# (eventually) outputs: male female

Method chaining in Dana is a little different than usual; the `.do` method doesn't return its Dana, but rather a *new* Dana encapsulating the callback. Thus Dana can be easily chained:

	procreate = people.do procreate
	procreate.do (progeny)->console.log progeny.sex
	# outputs male or female with roughly equal frequency

Note that this behavior is the same whether the `procreate` function returns immediately, or returns an event emitter.

If you do want to use a more traditional chaining syntax, each Dana remembers its parent as `.prev`, with the sugary aliases `.and` and `.or`.

	people.do elope
	.or.die (error)->console.log error
	# Outputs NOT if there is an error in `elope`,
	# but if there's a problem getting John and Mary

You can add an error callback with `.die`.

The Dana constructor searches deeply for event emitters, so named arguments work too.

But the real fun comes with the convenience method `.dana`. `.dana` takes a filter function, and returns a Dana which resolves to the return value of that filter.

	people.dana (john, mary)->mary.last_name
	.do (name)->console.log name
	
	# outputs: sue

This filtered Dana can naturally be provided in Dana itself. Thus any elaborate asynchronous flow can be constructed simply by pretending all of the methods have already returned:

	shows = Shows.list_ids()
	new Dana
		show: show = Show.get(shows.dana -> @[0])
		band: band = Band.get(show.dana -> @id)
		venue: venue = Venue.get(show.dana -> @venue)
		account: Account.get(band.dana -> @account)
	.do (details)->
		template.render details
	.or.die (err)->console.log 'Error loading details:', err
	
	# Renders the template only once all of the resources have loaded.

(Naturally this presumes that the various `.get` methods are wrapped by Dana.)