
# /*
#   vin
# */
# Author: yuhan.wyh<yuhan.wyh@alibaba-inc.com>
# Create: Fri Jul 31 2015 03:36:46 GMT+0800 (CST)
# 

"use strict"

thunkify = require 'thunkify'
Request  = require 'request'
cheerio  = require 'cheerio'
urlLib   = require 'url'
yaml     = require 'yamljs'
path     = require 'path'
config   = yaml.load path.join __dirname, '../../etc/config.default.yaml'
bmwCfg   = yaml.load path.join __dirname, '../../etc/bmw.yaml'

class Vin

  constructor : ( @options ) ->

  getVin : ->
    request = thunkify Request
    ( req, res, next ) =>
      url = urlLib.format
        protocol : 'http'
        hostname : 'www.bmwvin.com'
        query    : req.body

      resData = yield request url

      [ trash, body ] = resData
      $ = cheerio.load body
      vinData = @decodeRes $, body
      res.end JSON.stringify vinData

  decodeRes : ( $, body ) ->
    $tables = $( '#content > table' ).not '.table1'
    resData = {}
    if 0 is $tables.length
      if 0 <= body.indexOf 'Wrong captcha code. Try again.'
        return {
          wrong : true
          msg   : '验证码填写有误, 请重新填写.'
        }
      else if 0 <= body.indexOf 'An error occured. Maybe wrong VIN or our service is temporarily unavailable.'
        return {
          wrong : true
          msg   : '车架号有误, 或者服务器发生了一个错误, 请核对后重试'
        }
    else
      for table, i in $tables
        $table = $tables.eq i
        $trs   = $ 'tr', $table
        itemInfo = $trs.eq( 0 ).find( 'td' ).eq( 1 ).text()
        resData[ itemInfo ] = []
        for tr, j in $trs
          continue if 0 is j
          $tr  = $trs.eq j
          continue if 2 is $tr.find( 'td' ).length
          id   = $tr.find( 'td' ).eq( 1 ).text().trim()
          name = $tr.find( 'td' ).eq( 2 ).text().trim()
          cnId   = null
          cnName = null
          unless '' in [ id, name ]
            if 'Vehicle information' is itemInfo
              cnId   = bmwCfg.VehicleId[ id ]
            else
              cnName = bmwCfg.No[ id ]
            cnName ?= name
            cnId   ?= id

            resData[ itemInfo ].push { id : cnId, name : cnName }

            if 'VIN long' is id.trim()
              factory = name[ 10 ]
              facName = ''
              if factory in [ 'A', 'F', 'K' ]
                facName = '德国慕尼黑'
              else if factory in [ 'E', 'J', 'P' ]
                facName = '德国雷根斯堡'
              else if factory in [ 'B', 'C', 'D', 'G' ]
                facName = '德国丁格林'
              else if factory in [ 'L' ]
                facName = '美国斯巴腾堡'
              else if factory in [ 'N' ]
                facName = '南非罗斯林'
              else if factory in [ 'W' ]
                facName = '奥地利Graz'
              resData[ itemInfo ].push {
                id   : '组装工厂'
                name : facName
              }

    resData

  getChallenge : ->
    request = thunkify Request
    ( req, res, next ) =>
      resData = yield request 'http://45.78.19.7:4239/?redirectUrl=http://www.google.com/recaptcha/api/challenge?k=6Ldlev8SAAAAAF4fPVvI5c4IPSfhuDZp6_HR-APV'
      [ trash, body ] = resData
      body = body.replace( 'http://www.google.com/recaptcha/api/', "#{config.domain}/google/" );
      res.end body

  redirectGoogle : ->
    ( req, res, next ) =>
      { url } = req
      url = url.replace "/google/", ''
      redirectUrl = encodeURIComponent  "http://www.google.com/recaptcha/api/#{url}"
      url = "http://45.78.19.7:4239/?redirectUrl=#{redirectUrl}"
      Request( url ).pipe res

module.exports = ( options ) ->
  new Vin options
