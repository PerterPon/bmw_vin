
# /*
#   missing
# */
# Author: yuhan.wyh<yuhan.wyh@alibaba-inc.com>
# Create: Sat Aug 08 2015 07:24:02 GMT+0800 (CST)
# 

"use strict"

db = require( '../core/db' )()

ADD_MISSING = """
  INSERT INTO 
    missing( code, name )
  VALUES
    ?;
"""

class Misssing

  addMissing : ( results ) ->
    yield db.query ADD_MISSING, [ results ]

module.exports = ->
  new Misssing
