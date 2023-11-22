env.info("TFL: Fleet management here")
-- FILL INFORMATION BELOW

local LHAGroupName = "LHA-1"

-- DO NOT MODIFY BELOW

local persistenceMasterPath = "C:\\BTI\\Tracking\\FleetPersistence.json"

-- Constants
local trackFleetGroup = nil
local fleetMaster = {
  LHACoord = {
    vec2 = nil,
    vec3 = nil
  }
}

-- functions
local function trackSaveFleet(group)
  if trackFleetGroup ~= nil then
    local coord = trackFleetGroup:GetCoordinate()
    fleetMaster.LHACoord = {
      vec2 = coord:GetVec2(),
      vec3 = coord:GetVec3()
    }
  end
  local newEncodedBuffer = JSONLib.encode(fleetMaster)
  saveFile(persistenceMasterPath, newEncodedBuffer)
  env.info("TFL: saved Fleet")
end

-- initializer
local savedFleetBuffer = loadFile(persistenceMasterPath)
if savedFleetBuffer ~= nil and trackFleetGroup == nil then
  local savedFleetMaster = JSONLib.decode(savedFleetBuffer)
  if savedFleetMaster ~= nil then
    fleetMaster = savedFleetMaster
  end
end
local LHA = SPAWN:New(LHAGroupName):Spawn()
if fleetMaster.LHACoord ~= nil and fleetMaster.LHACoord.vec3 then
  mist.teleportToPoint({
    groupName = LHAGroupName,
    point = fleetMaster.LHACoord.vec3,
    action = "teleport"
  })
  LHA:Destroy()
  trackFleetGroup = GROUP:FindByName(LHAGroupName)
end
SCHEDULER:New(nil, trackSaveFleet, {trackFleetGroup}, 12, 120)
