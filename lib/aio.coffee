
# /*
#   aio
# */
# Author: yuhan.wyh<yuhan.wyh@alibaba-inc.com>
# Create: Fri Jul 31 2015 02:37:33 GMT+0800 (CST)
# 

"use strict"

require 'response-patch'

path   = require 'path'
yaml   = require 'yamljs'
Cover  = require 'node-cover'
Router = require 'cover-router'
wmCube = require 'middleware-cube'
Vin    = require './controller/vin'
bodyParser = require 'body-parser'
config     = yaml.load path.join __dirname, '../etc/config.default.yaml'
DB         = require( './core/db' )()

class Aio

  constructor : ->
    @initDb()
    @init()

  initDb : ->
    DB.init config.mysql

  init : ->
    @app = Cover()
    @useMiddleware()

    { port } = config
    @app.listen port, ->
      console.log "server listening: #{port}"

  useMiddleware : ->
    { app } = @

    vin = new Vin
    # favicon
    app.use Router.all '/favicon.ico', ( req, res, next ) ->
      res.end ''

    # fake
    app.use Router.all '/google/*', vin.redirectGoogle()

    # middleware cube
    cubeWm = wmCube
      dir    : './res'
      maxAge : 2592000000
      cached : path.join __dirname, '../res'
    app.use Router.all '/', cubeWm.middleware()

    # body parser
    app.use bodyParser.urlencoded extended : false
    app.use bodyParser.json()

    # error hander
    app.use ( req, res, next ) ->
      try
        res.req = req
        yield next
      catch e
        { message, stack } = e
        console.log message, stack
        res.end message

    # vin
    app.use Router.post '/vin',       vin.getVin()
    app.use Router.post '/cache',     vin.getCache()
    app.use Router.get  '/challenge', vin.getChallenge()

module.exports = Aio
