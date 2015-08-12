
# /*
#   result
# */
# Author: yuhan.wyh<yuhan.wyh@alibaba-inc.com>
# Create: Fri Aug 07 2015 18:23:47 GMT+0800 (CST)
# 

"use strict"

db = require( '../core/db' )()

ADD_RESULT  = """
  INSERT INTO result
    ( code, en_name )
  VALUES
    ?;
"""

class Result

  addResult : ( result ) ->
    yield db.query ADD_RESULT, [ result ]

module.exports = ->
  new Result
