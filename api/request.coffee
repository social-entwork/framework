Resource = require './resource'

class Request
  @INVALID_RESOURCE_ERROR: 'Invalid resource requested.'
  resource: ''
  method: ''
  params: null
  cookies: null
  headers: null
  response: null
  status: 200

  constructor: (options) ->
    @options = options
    @initialize?()
    @validateRequest?()

  initialize: ->
    @params = {}
    @headers = {}
    @status = parseInt(@options.defaultStatus, 10) || 200

  execute: (callback) ->
    @route = @options.routes.route @resource
    error =
      code: 404
      error: @constructor.INVALID_RESOURCE_ERROR

    if @route
      try
        resource = @getApiResource @route
        if resource
          error = null
          instance = new resource @toResourceOptions()
          instance.setCallback callback
          instance.setVerb @method
          instance.execute()
      catch e
        if e.code != 'MODULE_NOT_FOUND'         
          if @options.app.options.env == "dev"
            throw e
          error =
            code: 500
            error: "An unknown error occured"

    if error
      callback { status: error.code, response: { code: 404, error: Request.INVALID_RESOURCE_ERROR } }

  setErrorResponse: (err) ->
    @response = error: err

  getApiResource: (route) ->
    if route.action
      require "#{@options.app.options.dir}/api/#{route.version}/#{route.controller}/#{route.action}.coffee"
    else
      require "#{@options.app.options.dir}/api/#{route.version}/#{route.controller}.coffee"

  toResourceOptions: ->
    resource: @resource
    method: @method
    params: @params
    route: @route

  toJSON: ->
    status: @status
    resource: @resource
    method: @method
    params: @params
    cookies: @cookies
    headers: @headers
    response: @response
    route: @route

module.exports = Request