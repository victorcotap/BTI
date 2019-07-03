env.info("BTI: Tracking here!")

-- json = require "json"
-- local json = dofile('json.lua')
env.info("BTI: After json")
UTILS.OneLineSerialize({"toto", "tata"})
-- local toto = JSONLib.decode('[1,2,3,{"x":10}]')
local toto = JSONLib.decode('{"toto" : 2, "tata": 4}')

UTILS.OneLineSerialize(toto)
env.info("BTI: env toto ", toto)
local encoded = JSONLib.encode(toto)
env.info("BTI: env encode " .. encoded)
