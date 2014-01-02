CommonErrors = require './errors'
ParamHandler = require './paramHandler'

class Resource
  @DEFAULT_STATUS: 200
  status: null
  response: null

  constructor: (options, callback = null) ->
    for key, value of options
      @[key] = value
    @callback = callback if callback?
    @bootstrap()
    @initialize?()

  bootstrap: ->
    @status = Resource.DEFAULT_STATUS

  setCallback: (callback) ->
    @callback = callback

  setVerb: (verb) ->
    if typeof verb == 'string'
      @verb = verb.toLowerCase()
    else
      @verb = null

  execute: ->
    console.log @verb
    if typeof @verb == 'string'
      verbCamel = @verb.substr(0, 1).toUpperCase() + @verb.substr(1).toLowerCase()
      if typeof @["execute#{verbCamel}"] == 'function'
        try
          @beforeExecute?()
          @["execute#{verbCamel}"]()
          @afterExecute?()
        catch e
          @error e.code, e.message
      else
        @error 404, CommonErrors.invalidVerb(@verb)
    else
      @error 404, CommonErrors.invalidVerb(@verb)

  set: (key, value) ->
    if typeof key == 'string' && !value?
      @response = key
    else
      @response = {} if !@response? || typeof @response != 'object'
      pairs = @_getPairs key, value
      for key, value of pairs
        @response[key] = value

  get: (key) ->
    @response[key]

  getParam: (key) ->
    if !@requestParams?
      @requestParams = new ParamHandler @params
    @requestParams.get(key)

  getRouteParam: (key) ->
    if !@routeParams?
      @routeParams = new ParamHandler @route.routeParams
    @routeParams.get(key)

  setHeader: (key, value) ->
    pairs = @_getPairs key, value
    
    for key, value of pairs
      keys = key.split('-').map (str) ->
        str.substr(0, 1).toUpperCase() + str.substr(1).toLowerCase()
      key = keys.join '-'
      @headers[key] = value
    pairs

  setStatus: (code) ->
    code = parseInt(code, 10)
    if !isNaN(code)
      @status = code
    else
      false

  redirect: (url, permanent = false) ->
    statusCode = if permanent == true then 301 else 302
    @setStatus statusCode
    @set location: url
    @header location: url
    @end()
    
  error: (key, message) ->
    unless typeof key == 'number'
      key = 500
      message = if typeof key == 'string' then key else CommonErrors.unknownError()
    if !message? || message == ''
      switch key
        when 401
          message = CommonErrors.unauthorized()
        when 404
          message = CommonErrors.notFound()
        else
          message = CommonErrors.unknownError()
    @setStatus key
    @set error: message
    @end()
  
  end: ->
    @yield()

  yield: ->
    @callback(@toJSON())

  functionize: (cb) ->
    if typeof cb != 'function'
      return ->
    else
      return cb

  _getPairs: (key, value) ->
    pairs = {}
    if !value?
      if typeof key == 'string'
        split = key.split ':'
        [key, value] = [split[0], split[1]]
        pairs[key] = value
      else
        pairs = key
    else
      pairs[key] = value
    return pairs

  toJSON: ->
    response:
      status: @status
      response: @response
    headers: @headers

module.exports = Resource