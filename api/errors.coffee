class Errors
	@unknownError: -> "An unknown error occured."
	@invalidRequest: -> "Invalid request."
	@authenticationFailure: -> "Could not authenticate you."
	@unauthorized: -> "You do not have permission to access this resource."
	@notFound: (string = "resource") -> "The #{string} requested could not be found."
	@invalidVerb: (verb) -> if typeof verb == "string" then "This resource does not respond to \"#{verb.toUpperCase()}\" requests." else @invalidRequest()

	@invalidParameter: (param) ->
		params = @parseParameters.apply @, arguments
		return "Invalid #{params.param} parameter#{if params.plural then "s" else ""} provided."		
	
	@parseParameters: (params) ->
		if typeof params == "string"
			params = [arguments...]
		plural = false
		len = params.length
		str = ""
					
		if len > 1 then plural = true
					
		for p, i in params
			if i == 0
				str += "\"#{p}\""
			else if i == (len - 1)
				str += " and \"#{p}\""
			else
				str += ", \"#{p}\""
		return { param: str, plural: plural }
		
	@missingParameter: (param) ->
		params = @parseParameters.apply @, arguments
		return "Missing required parameter#{if params.plural then "s" else ""} #{params.param}."
		
module.exports = Errors