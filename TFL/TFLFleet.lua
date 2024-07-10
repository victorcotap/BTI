env.info("TFL: Fleet management here")
-- FILL INFORMATION BELOW

local CVNGroupName = "CVN-G"
local LHAGroupName = "LHA-N"

-- DO NOT MODIFY BELOW
-- Constants
local trackCVNGroup = nil
local trackLHAGroup = nil
local markHandler = EVENTHANDLER:New()
local fleetMasterKey = "fleetMaster"
local isFleetMenuOn = false
local fleetMenuCoord = nil
local menuCooldown = 20
local gridUnitSize = 300

local fleetMarkIds = {}
local fleetCommandButtons = {}
local fleetCommands = {
  {
    title = "Move CVN",
    groupName = CVNGroupName,
    costPerNm = 10,
  },
  {
    title = "Move LHA",
    groupName = LHAGroupName,
    costPerNm = 5,
  },
}

-- initializer
local fleetMaster = LOCALGet(fleetMasterKey)
if fleetMaster == nil then
  fleetMaster = {
    CVNCoord = {
      vec3 = nil
    },
    LHACoord = {
      vec3 = nil
    }
  }
end
env.info("TFL: fleet master " .. UTILS.OneLineSerialize(fleetMaster))
local CVN = SPAWN:New(CVNGroupName):Spawn()
if fleetMaster.CVNCoord ~= nil and fleetMaster.CVNCoord.vec3 then
  env.info("TFL: Fleet found persisted boat, doing some magic")
  mist.teleportToPoint({
    groupName = CVNGroupName,
    point = fleetMaster.CVNCoord.vec3,
    action = "teleport"
  })
  CVN:Destroy()
end
local LHA = SPAWN:New(LHAGroupName):Spawn()
if fleetMaster.LHACoord ~= nil and fleetMaster.LHACoord.vec3 then
  env.info("TFL: Fleet found persisted boat, doing some magic")
  mist.teleportToPoint({
    groupName = LHAGroupName,
    point = fleetMaster.LHACoord.vec3,
    action = "teleport"
  })
  LHA:Destroy()
end
trackCVNGroup = GROUP:FindByName(CVNGroupName)
trackLHAGroup = GROUP:FindByName(LHAGroupName)

-- timed functions
local function trackSaveFleet(group)
  if trackCVNGroup ~= nil then
    local coord = trackCVNGroup:GetCoordinate()
    fleetMaster.CVNCoord = {
      vec3 = coord:GetVec3()
    }
  end
  if trackLHAGroup ~= nil then
    local coord = trackLHAGroup:GetCoordinate()
    fleetMaster.LHACoord = {
      vec3 = coord:GetVec3()
    }
  end
  LOCALStore(fleetMasterKey, fleetMaster)
end
SCHEDULER:New(nil, trackSaveFleet, {trackCVNGroup}, 12, 12)


-- Menu drawing
local function clearFleetMenu(markIds)
  if isFleetMenuOn then
    for i, markId in ipairs(markIds) do
      trigger.action.removeMark(markId)
    end
  end
  fleetCommandButtons = {}
  fleetMenuCoord = nil
  isFleetMenuOn = false
end

local function generateSupportLines(coord)
  local lines = {
    {
      {text = "Fleet task", size = 1, color = TFL.color.turquoise},
      {text = "Cost Per Nm", color = TFL.color.red},
      {text = "Total Cost", color = TFL.color.yellow},
      {text = "Request", color = TFL.color.purple},
    },
  }
  for i, command in ipairs(fleetCommands) do
    local fleetGroup = GROUP:FindByName(command.groupName)
    local distance = fleetGroup:GetCoordinate():Get2DDistance(coord)

    local line = {
      {text = command.title, size = 1, color = TFL.color.turquoise},
      {text = tostring(command.costPerNm)},
      {text = string.format("%.0f", distance)},
      {type = "button", size = 1, color = TFL.color.grey}
    }
    table.insert(lines, line)
  end
  return lines
end

local function executeFleetTask(index, coord)
  local command = fleetCommands[index]
  local group = GROUP:FindByName(command.groupName)
  group:TaskRouteToVec2(coord:GetVec2(), 25)
  clearFleetMenu(fleetMarkIds)
end

-- -fleet move=[groupName] speed=25
-- event functions
function markHandler:onEvent(Event)
  if Event.id == world.event.S_EVENT_MARK_REMOVED then
    local vec3 = {y=Event.pos.y, x=Event.pos.x, z=Event.pos.z}
    local coord = COORDINATE:NewFromVec3(vec3)
    coord.y = coord:GetLandHeight()

    if Event.text~=nil and Event.text:lower():find("-fleet") then
      local markIds, buttonsCoords = TFL.drawMenu(coord, generateSupportLines(coord), gridUnitSize)
      fleetMarkIds = markIds
      fleetCommandButtons = buttonsCoords
      isFleetMenuOn = true
      fleetMenuCoord = coord
      SCHEDULER:New(nil, clearFleetMenu, {fleetMarkIds}, menuCooldown)
    elseif Event.text~=nil and Event.text:lower():find("-click") then
      for i, buttonCoord in ipairs(fleetCommandButtons) do
        if coord:IsInRadius(buttonCoord, (gridUnitSize / 4) * 0.8) and fleetMenuCoord ~= nil then
          executeFleetTask(i, fleetMenuCoord)
        end
      end
    elseif Event.text~=nil and Event.text:lower():find("-move") then
      -- fields to fill
      local cvnGroupName = CVNGroupName
      local cvnSpeed = 30
      local shouldMove = false

      -- command parsing
      local arguments = TFL.split(Event.text, " ")
      for _,argument in pairs(arguments) do
        local argumentValues = TFL.split(argument, "=")
        local command = argumentValues[1]
        local value = argumentValues[2]

        if command == "move" and value ~= nil then
          cvnGroupName = value
          shouldMove = true
        elseif command == "moveCVN" then
          cvnGroupName = CVNGroupName
          shouldMove = true
        elseif command == "moveLHA" then
          cvnGroupName = LHAGroupName
          shouldMove = true
        elseif command == "speed" and value ~= nil then
          cvnSpeed = UTILS.KnotsToMps(tonumber(value))
        end
      end

      -- execution
      if shouldMove then
        local cvnGroup = GROUP:FindByName(cvnGroupName)
        cvnGroup:TaskRouteToVec2(coord:GetVec2(), cvnSpeed)
        env.info("TFL: Sending fleet to new coordinates ")
      end
    end
  end
end

world.addEventHandler(markHandler)
