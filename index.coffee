{EventEmitter} = require 'events'
_ = require 'underscore'

Http = require './lib/http'
Auth = require './lib/auth'

class App extends EventEmitter
  constructor: (options) ->
    @options = _.defaults options,
      port: 80
      domain: 'app.dev'
      env: 'dev'

    @options.session = _.defaults @options.session || {}, { secret: 'secret_token', key: 'app.id' }
    @initAuthentication()
    @initSessions()
    @initHttp()
    # @initSocket()

  initAuthentication: ->
    @authentication = new Auth()

  initSessions: ->
    @session =
      key: @options.session.key
      secret: @options.session.secret
    
    if @options.services.redis?
      @session.store = new connectRedis(client: @options.services.redis)
      
  initHttp: ->
    @http = new Http(app: @)
  
  initSocket: ->
    @socket = new Socket(app: @)
  
  start: (cb) ->
    @emit 'listen'
    @http.server.listen @options.port, =>
      if @socket? then @socket.listen()
      @emit 'listening', true
      cb?()

  serialize: ->
    app: @
    authentication: @authentication  

module.exports = App