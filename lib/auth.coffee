class Auth
	@mechanisms: []

	constructor: (params) ->
		@_user = null
		@_mechanism	= null
	
	getMechanism:	->
		@_mechanism
	
	getUser: ->
		@_user
	
	authenticate: (options = {}, callback) ->
		if @_user?
			callback? null, @_user, @_mechanism
			return true
		
		if typeof arguments[0] == 'function'
			[options,callback] = [callback,options]
		
		if options? && options.blacklist?
			delete mechanisms[name] for name in options.blacklist
		
		run = (i) =>
			if Auth.mechanisms[i]?
				mechanism	= new Auth.mechanisms[i](@options)
				mechanism.authenticate (err, user) =>
					if !err && user
						@_mechanism	= mechanism
						@_user = user
						callback? null, user, mechanism
					else
						run i+1
			else
				callback? null, false
		run(0)

	addMechanism: (handler) ->
		Auth.mechanisms.push handler

module.exports = Auth