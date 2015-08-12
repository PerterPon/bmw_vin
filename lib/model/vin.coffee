
# /*
#   vin
# */
# Author: PerterPon<PerterPon@gmail.com>
# Create: Fri Aug 07 2015 07:31:07 GMT+0800 (CST)
# 

"use strict"

db = require( '../core/db' )()

ADD_VIN  = """
INSERT INTO vin
  ( vin_code, wrong )
VALUE
  ( ?, ? );
"""

class Vin

  addVin : ( vin, wrong ) ->
    yield db.query ADD_VIN, [ vin, wrong ]

module.exports = ->
  new Vin
