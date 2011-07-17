events = require 'events'

EventEmitter = events.EventEmitter

module.exports = class Dana extends EventEmitter
	constructor:(obj...)->
		if obj.length
			@load(obj...)
		@prev = null
		@die ->
	
	load:(@obj...)->
		dana = @
		
		queue = 1
		check =->
			if --queue == 0
				dana.resolve()
		
		scan=(ob)->
			if typeof ob is 'object'
				for i of ob
					if typeof ob[i]?.on is 'function'
						do (i)->
							queue++
							ob[i].on 'error', (err)->
								dana.emit 'error', err
							ob[i].on 'success', (out)->
								ob[i] = out
								check()
					else
						scan ob[i]
		
		scan @obj
		check()
		@
		
	do:(fn)->
		d = new Dana
		@on 'success', (args...)->
			ee = fn(args...)
			d.load ee
		d.prev = @
		d
		
	die:(fn)->
		@on 'error', fn or (err)->
								Muse.log err
								throw new Error err
		@
			
	
	resolve:->	
		if @filter
			try
				@resolved = [@filter.apply(@obj[0], @obj)] if @filter
			catch e
				Muse.log 'Error in Dana filtering:'
				throw e
		else
			@resolved = @obj
		
		@emit 'success', @resolved...
		
		@do = @do_resolved
		@on = @on_resolved
	
	do_resolved:(fn)->	
		d = new Dana fn(@resolved...)
		d
		
	on_resolved:(name, fn)->
		if name is 'success'
			fn(@resolved...)
		
	dana:(fn)->
		d = new Dana @
		d.filter = fn
		d
		
	@wrap:(fn)->
		(args...)->
			d = new Dana(args...)
			d.do fn
		
	@::__defineGetter__ 'or', ->@prev
	@::__defineGetter__ 'and', ->@prev