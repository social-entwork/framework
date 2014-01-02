Request = require '../request'
_ = require 'underscore'

class Http extends Request
  resource: ''
  method: ''
  params: null
  cookies: null
  headers: null
  response: null
  status: 200

  initialize: ->
    url = @options.httpRequest.url
    appPath = @options.app.options.path

    if appPath?
      if url[0...appPath.length] == appPath
        url = url[appPath.length...url.length]

    params = _.extend {}, @options.httpRequest.query, @options.httpRequest.params

    @resource = url
    @method = if @options.app.options.env == 'dev' && params['-X']? then params['-X'] else @options.httpRequest.method
    @params = params
    @request =
      cookies: @options.httpRequest.cookies
      headers: @options.httpRequest.header

  toResourceOptions: ->
    options = super
    options.cookies = @request.cookies
    options.headers = @request.headers
    options

module.exports = Http