_ = require 'underscore'

class Routes
	@wildcardRegex:	/:(.*?)\((.*?)\)/
	defaultType: 'json'

	constructor: (routes) ->
		@routes = routes
	
	cleanResource: (resource) ->
		if resource.substr(0,1) == '/' then resource = resource.substr(1)
		resource.replace /(\/+)/, '/'
	
	route: (resourceString) ->
		resourceParts = @cleanResource(resourceString).split "/"
		if resourceParts.length >= 1 && isNaN(resourceParts[0]) != true
			resourceFileType = null
			versionString = resourceParts.shift()
			versionNumber = parseFloat(versionString, 10)
			resourceString = resourceParts.slice(1).join "/"
			resourceFileCheck	= resourceString.split "."
			if resourceFileCheck.length > 1
				resourceFileType = resourceFileCheck.pop()
				resourceString = resourceFileCheck.join "."
				resourceParts = resourceString.split "/"
			for route in @routes
				# check if version numbers match
				if route.version == versionNumber
					# check file type match
					route.regex ?= {}
					routeObject = { version: route.version, params: {}, routeParams: {}, controller: route.controller, action: route.action || null }
					routeResource = route.resource
					routeResourceFileCheck = routeResource.split "."
					routeFileType = null
					if routeResourceFileCheck.length > 1
						routeFileType	= routeFileType.pop()
						routeResource	= routeResourceFileCheck.join "."
					# if file types don't match then this route doesn't match
					if routeFileType != resourceFileType then continue
					routeResourceParts = routeResource.split "/"
					if routeResourceParts.length != resourceParts.length then continue
					routeMatched = true
					for part, index in routeResourceParts
						if resourceParts[index]?
							resourcePart = resourceParts[index]
							firstCharacter = part.substr 0, 1
							if firstCharacter == ":"
								key = part.substr(1)
								regexQuery = part.match(Routes.wildcardRegex)
								if regexQuery && regexQuery[1]? && regexQuery[2]?
									if !route.regex[regexQuery[2]]?
										route.regex[regexQuery[2]] = new RegExp "^#{regexQuery[2]}$"
									_reg = resourcePart.match(route.regex[regexQuery[2]])
									_results = []
									if _reg
										if _reg.length > 1
											_results.push(i) for i in _reg.splice(1)
											if _results.length == 1 then _results = _results[0]
										else
											_results = _reg[0]
											routeObject.routeParams[regexQuery[1]] = _results
									else
										routeMatched = false
								else
									routeObject.routeParams[key] = resourcePart
							else if part == '[controller]'
								routeObject.controller = resourcePart
							else if part == '[action]'
								routeObject.action = resourcePart
							else if part != resourcePart
								try
									if !route.regex[part]?
										route.regex[part] = new RegExp "^#{part}$"
									exec = route.regex[part].exec resourcePart
									if exec == null
										routeMatched = false
									else
										_results = []
										_results.push(i) for i in exec.splice(1)
										if _results.length == 1 then _results = _results[0]
										routeObject.routeParams[paramIndex++] = _results
								catch e
									routeMatched = false
						else
							routeMatched = false
							break
					
					if routeMatched
						if route.params
							routeObject.params = _.extend routeObject.params, route.params
						return routeObject
			false
		else
			false

module.exports = Routes