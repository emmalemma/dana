events = require 'events'

EventEmitter = events.EventEmitter

module.exports = class Dana extends EventEmitter
	constructor:(obj...)->
		@load(obj...)
	
	load:(@obj...)->
		dana = @
		
		queue = 0
		check =->
			if --queue == 0
				dana.resolve()
				dana.handler dana.obj
		
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
		Muse.log 'scanned dana as',@obj
		unless queue
			@resolve()
			@handler @obj
	
	handler:(obj)->
		@emit 'success', obj...
		@do = @_do
		@on = @_on
		
	do:(fn)->
		d = new Dana
		@on 'success', (args...)->
			ee = fn(args...)
			d.load ee
		d
	
	resolve:->	
		if @filter
			try
				@obj = [@filter.apply(@obj[0], @obj)] if @filter	
			catch e
				Muse.log 'Error in Dana filtering:'
				throw e
	
	_do:(fn)->	
		d = new Dana fn(@obj...)
		d
		
	_on:(name, fn)->
		if name is 'success'
			fn(@obj...)
		
	dana:(fn)->
		d = new Dana @
		d.filter = fn
		d
		
	@wrap:(fn)->
		(args...)->
			d = new Dana args...
			d.do fn
			
		