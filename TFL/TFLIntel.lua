env.info("TFL: Intel with nerdy glasses here")

local markHandler = EVENTHANDLER:New()

local function scanZoneAndDrawIntel(zone)
  local ZoneCoord = zone:GetCoordinate()
  local ZoneRadius = zone:GetRadius()
  local foundCoordinateArray = {}

  env.info("TFL: Scanning zone radius " .. tostring(ZoneRadius))
  local function EvaluateZone(ZoneDCSUnit)
    local name = ZoneDCSUnit:getName()
    local life = ZoneDCSUnit:getLife()
    local category = ZoneDCSUnit:getCategory()
    local unitCoalition = ZoneDCSUnit:getCoalition()

    if category == Object.Category.UNIT and unitCoalition == coalition.side.RED then
      local ZoneUnit = UNIT:FindByName(name)
      if ZoneUnit ~= nil then
        -- env.info("TFL: Scanning unit " .. ZoneUnit:GetName())
        local coordinate = ZoneUnit:GetCoordinate()
        coordinate:CircleToAll(20, coalition.side.BLUE, TFL.color.red, 1.0, TFL.color.magenta, 1.0, 0, true)
        table.insert(foundCoordinateArray, coordinate)
      end
    elseif category == Object.Category.STATIC then
      local ZoneStatic = STATIC:FindByName(name)
      if ZoneStatic ~= nil then
        -- env.info("TFL: Scanning static " .. ZoneStatic:GetName())
        local coordinate = ZoneStatic:GetCoordinate()
        coordinate:CircleToAll(60, coalition.side.BLUE, TFL.color.red, 1.0, TFL.color.turquoise, 1.0, 0, true)
        table.insert(foundCoordinateArray, coordinate)
      end
    end
    return true
  end

  local SphereSearch = {
    id = world.VolumeType.SPHERE,
      params = {
      point = zone:GetVec3(),
      radius = ZoneRadius,
      }
    }

  world.searchObjects({Object.Category.UNIT, Object.Category.STATIC}, SphereSearch, EvaluateZone )

  -- env.info("TFL: Found array count " .. tostring(#foundCoordinateArray) .. UTILS.OneLineSerialize(foundCoordinateArray))
  local coordVec2Array = {}
    for i, v in ipairs(foundCoordinateArray) do
      table.insert(coordVec2Array, {x = v.x, y= v.z})
    end
  local polygonArray = TFLNewConvexHull(coordVec2Array)
  -- env.info("TFL: Intel polygon array " .. tostring(#polygonArray) .. "count " .. UTILS.OneLineSerialize(polygonArray))
  if #polygonArray > 1 then
    local coordPolygonArray = {}
    for i, v in ipairs(polygonArray) do
      table.insert(coordPolygonArray, COORDINATE:NewFromVec2(polygonArray[i]))
    end
    local firstCoord = coordPolygonArray[1]
    local markId = firstCoord:MarkupToAllFreeForm(coordPolygonArray, coalition.side.BLUE, TFL.color.red, 1.0, TFL.color.orange, 0.0, 5)
  end
end

-- -intel action=scan radius=10000
-- event functions
function markHandler:onEvent(Event)
  if Event.id == world.event.S_EVENT_MARK_REMOVED then
    -- env.info(string.format("TFL: Fleet Support REMOVED id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
    if Event.text~=nil and Event.text:lower():find("-intel") then
      -- coordinate parsing
      local vec3 = {y=Event.pos.y, x=Event.pos.x, z=Event.pos.z}
      local coord = COORDINATE:NewFromVec3(vec3)
      coord.y = coord:GetLandHeight()

      -- fields to fill
      local zoneRadius = 10000
      local shouldIntelDrawScan = false


      -- command parsing
      local arguments = TFL.split(Event.text, " ")
      for _,argument in pairs(arguments) do
        local argumentValues = TFL.split(argument, "=")
        local command = argumentValues[1]
        local value = argumentValues[2]

        if command == "action" and value == "scan" then
          shouldIntelDrawScan = true
        elseif command == "radius" and value ~= nil then
          zoneRadius = tonumber(value)
        end
      end

      -- execution
      if shouldIntelDrawScan then
        local zoneToScan = ZONE_RADIUS:New(Event.id, coord:GetVec2(), zoneRadius)
        scanZoneAndDrawIntel(zoneToScan)
      end
    end
  end
end

world.addEventHandler(markHandler)

local function testIntel()
  scanZoneAndDrawIntel(ZONE:FindByName("IntelZone"))
  scanZoneAndDrawIntel(ZONE:FindByName("IntelZone-1"))
  scanZoneAndDrawIntel(ZONE:FindByName("IntelZone-2"))
  scanZoneAndDrawIntel(ZONE:FindByName("IntelZone-3"))
  scanZoneAndDrawIntel(ZONE:FindByName("IntelZone-4"))
end
mist.scheduleFunction(testIntel, {},  timer.getTime() + 1)

env.info("TFL: Intel nerd finished")
