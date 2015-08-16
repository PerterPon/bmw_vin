
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
    ( code, en_name, vin )
  VALUES
    ?;
"""

GET_CAHCE =
  """
  SELECT
    code,
    en_name
  FROM
    result
  WHERE
    vin = ?;
  """

class Result

  addResult : ( result ) ->
    yield db.query ADD_RESULT, [ result ]

  getCache : ( vin ) ->
    yield db.query GET_CAHCE, [ vin ]

module.exports = ->
  new Result
