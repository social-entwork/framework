Model = require '../lib/model'

class ParamHandler
	constructor: (params) ->
		@params = params
		
	has: (key) ->
		if key.indexOf(".") > -1
			cur = @params
			for val in key.split(".")
				cur = cur[val]
				if typeof cur[val] == "undefined"
					return false
			return true
		else
			return typeof @params[key] != "undefined"
	
	get: (key) ->
		if key.indexOf(".") > -1
			cur = @params
			for val in key.split(".")
				cur = cur[val]
				if !cur?
					break
			return new Param(cur)
		else
			return new Param(@params[ key] )
		
class Param
	constructor: (param) ->
		@param = param
		
	as: (type, _default) ->
		if typeof type == "string" then type = type.toLowerCase()
		switch type
			when Object, "object"
				if typeof @param == "object"
					return @param
				else
					return {}
			
			when Boolean, "boolean"
				if typeof @param == "boolean"
					@param
				else if @param == "true" || @param == "1"
					true
				else if @param == "false" || @param == "0"
					false
				else if typeof _default != "undefined"
					_default
				else
					false
					
			when Number, "number"
				if typeof @param == "number"
					return @param					
				else
					float = parseFloat @param
					if !isNaN(float) && isFinite(@param)
						return float
					else if typeof _default != "undefined"
						return _default
					else
						return 0
						
			when String, "string"
				if typeof @param.toString == "function"
					@param.toString()
				else
					""
			
			when Array, "array"
				if typeof @param == "object" && Array.isArray @param
					return @param
				else if typeof @param == "string"
					return @param.split ','
				else
					return []
			
			when "objectid"
				if @param && @param.length? && @param.length == 24
					try					
						return Model.objectId @param
					catch e
						return false
				else
					return false
			
			when "raw"
				return @param

			else
				if typeof type == "function" && type.name == "ObjectID"
					if @param && @param.length? && @param.length == 24
						try
							return type(@param)
						catch e
							return false
					else
						return false
				else
					return null
	
	isNull: -> @param == null ||@param == "null"|| @param == "nil"
	
	isEmpty: -> @param == "" ||@param == false|| @isNull()

	toString: ->
		if typeof @param == "undefined"
			null
		else
			String.prototype.toString.apply @, arguments
			
module.exports = ParamHandler