env.info("TFL: Local Storage here, give us your bits")

if JSONLib == nil then
  JSONLib = dofile("C:\\BTI\\Json.lua")
end

local persistenceMaster = { }
local persistenceMasterPath = "C:\\BTI\\Tracking\\TFLPersistence.json"

function LOCALStore(key, table)
  persistenceMaster[key] = table
end

function LOCALGet(key)
  return persistenceMaster[key]
end

local function saveMaster()
  local newEncodedBuffer = JSONLib.encode(persistenceMaster)
  saveFile(persistenceMasterPath, newEncodedBuffer)
end

local function loadMaster()
  local savedEncodedBuffer = loadFile(persistenceMasterPath)
  if savedEncodedBuffer ~= nil then
    local savedMaster = JSONLib.decode(savedEncodedBuffer)
    persistenceMaster = savedMaster
  end
end

loadMaster()
mist.scheduleFunction(saveMaster, {},  timer.getTime() + 10, 10)