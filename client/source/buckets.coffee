Backbone = require 'backbone'
Cocktail = require 'cocktail'

Backbone.$ = $
Cocktail.patch Backbone

Chaplin = require 'chaplin'

User = require 'models/user'
Layout = require 'views/layout'
Handlebars = require 'hbsfy/runtime'
routes = require 'routes'
mediator = require 'mediator'

_ = require 'underscore'

module.exports = class BucketsApp extends Chaplin.Application
  title: 'Buckets'
  initialize: (@options = {}) ->
    @initRouter routes, root: "/#{@options.adminSegment}/"
    
    @initDispatcher
      controllerPath: 'client/source/controllers/'
      controllerSuffix: '_controller.coffee'

    mediator.options = @options
    mediator.user = new User @options.user if @options.user
    mediator.plugins = {}

    _.each @options.bootPlugins, (plugin) ->
      mediator.loadPlugin plugin.slug if plugin.slug

    mediator.layout = new Layout
      title: 'Buckets'
      titleTemplate: (data) ->
        str = ''
        str += "#{data.subtitle} · " if data.subtitle
        str += data.title

    # Startup
    @initComposer()
    @start()
    Object.freeze? @

  plugin: (key, plugin) ->
    plugin.handlebars = Handlebars
    mediator.plugins[key] = plugin

  @View = require 'lib/view'
  @_ = _
  @mediator = mediator
