http = require 'http'
_ = require 'underscore'
koa = require 'koa'
sessions = require 'koa-session'
parse = require 'co-body'
Api = require './api'
Q = require 'Q'

class Http
  constructor: (@params) ->
    @app = params.app
    @initRoutes()
    @initKoa()
    @initServer()

  initRoutes: ->
    @routes = new Api.Routes(@app.options.routes)

  initSessions: ->
    @koa.keys = [@app.session.secret]
    @koa.use(sessions(domain: @app.options.domain))

  initKoa: ->
    @koa = koa()
    @koa.app = @app
    @koa.routes = @routes
    @initSessions()
    @initBodyParser()
    @listenForApiRequests()

  initBodyParser: ->
    @koa.use (next) ->
      if @method == 'POST'
        @params = yield parse @
      else
        @params = {}
      yield next

  listenForApiRequests: ->
    @koa.use @handleApiRequest

  handleApiRequest: (next) ->
    options = _.extend {
      routes: @app.routes
      httpRequest: @
    }, @app.app.serialize()
    request = new Api.Request.Http options
    fakePromise = ->
      deferred = Q.defer()
      request.execute (response) ->
        deferred.resolve(response)
      deferred.promise
    response = yield fakePromise()
    @status = response.response.status
    @set header, value for header, value of response.headers
    @body = response.response
    console.log @
    yield next
    
  initServer: ->
    @server = http.createServer(@koa.callback())
            
module.exports = Http