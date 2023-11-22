env.info("TFL: Local Storage here, give us your bits")

if JSONLib == nil then
  JSONLib = dofile("C:\\BTI\\Json.lua")
end

local persistenceMaster = {
  fleetMaster = {}
}
local persistenceMasterPath = "C:\\BTI\\Tracking\\TFLPersistence.json"

function LOCALStore(key, table)
  persistenceMaster[key] = table
end

local function saveMaster()
  local newEncodedBuffer = JSONLib.encode(persistenceMaster)
  saveFile(persistenceMasterPath, newEncodedBuffer)
end


mist.scheduleFunction()