
# /*
#   aio
# */
# Author: yuhan.wyh<yuhan.wyh@alibaba-inc.com>
# Create: Fri Jul 31 2015 02:37:33 GMT+0800 (CST)
# 

"use strict"

path   = require 'path'
yaml   = require 'yamljs'
Cover  = require 'node-cover'
Router = require 'cover-router'
wmCube = require 'middleware-cube'
Vin    = require './controller/vin'
bodyParser = require 'body-parser'
config     = yaml.load path.join __dirname, '../etc/config.default.yaml'

class Aio

  constructor : ->
    @init()

  init : ->
    @app = Cover()
    @useMiddleware()

    { port } = config
    @app.listen port, ->
      console.log "server listening: #{port}"

  useMiddleware : ->
    { app } = @

    # middleware cube
    cubeWm = wmCube
      dir : './res'
    app.use Router.all '/', cubeWm.middleware()

    # body parser
    app.use bodyParser.urlencoded extended : false
    app.use bodyParser.json()

    # error hander
    app.use ( req, res, next ) ->
      try
        yield next
      catch e
        { message, stack } = e
        console.log message, stack
        res.end message

    # vin
    vin = new Vin
    app.use Router.post '/vin', vin.getVin()

module.exports = Aio