mongoose = require 'mongoose'

class Model
  @schema: {}
  @models: {}
  @ObjectId: mongoose.Schema.ObjectId

  constructor: ->
    if !Model.models[@name]?
      schema = new mongoose.Schema(@constructor.schema)

      for key, value of @constructor
        if key not in ['schema', 'models', '__super__']
          schema.statics[key] = value

      for key, value of @constructor.prototype
        if key not in ['constructor']
         schema.methods[key] = value

      @Model.models[@name] = mongoose.model(@constructor.name, schema)

    return new Model.models[@name]

  @key: (key, type) ->
    @schema[key] = type