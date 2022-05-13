local function triggerMission(argument)

  local side = argument.side
  local baseZone = argument.base
  local store = argument.store

  local destination = TFLFindEmptyContestedZone(store.zones, side)
  local warehouse = TFL.ternary(side == 1, store.redAssets, store.blueAssets)
  local color = TFL.ternary(side == 1, TFL.color.red, TFL.color.blue)
  local groupType = TFLGenerateMissionGroup(warehouse)

  if groupType then
    local group = groupType.spawn:SpawnInZone(baseZone.zone, true)
    group:RouteGroundOnRoad(destination.zone:GetCoordinate(), 35)
    local missionTextCoordinate = TFLMiddleCoordinate(baseZone.zone:GetCoordinate(), destination.zone:GetCoordinate())
    local lineDrawID = baseZone.zone:GetCoordinate():LineToAll(destination.zone:GetCoordinate(), side, color, 0.8, 4, true)
    local textBoxID = missionTextCoordinate:TextToAll("Sending Assets" , side, TFL.color.white, 1, color, 0.3, 14)
    local mission = {
      departureZone = baseZone,
      destinationZone = destination,
      description = "We going boyz",
      side = side,
      group = group,
      lineDrawID = lineDrawID,
      textBoxID = textBoxID,
      active = true,
    }
    table.insert(store.missions, mission)
  else return end -- Fail mission trigger and try again next loop
end

local function missionLoop(store)
  for i, v in ipairs(store.missions) do
    if v.group:IsInZone(v.destinationZone.zone) or v.group:IsAlive() == nil then
      COORDINATE:RemoveMark(v.lineDrawID)
      COORDINATE:RemoveMark(v.textBoxID)
      table.remove(store.missions, i)
    end
  end
end


local function scanIntel(store)
  for i, level in pairs(store.zones) do
    for i, v in pairs(level.conflictZones) do
      v.zone:Scan(Object.Category.UNIT)
      if v.zone:IsNoneInZone() then
        --Empty
        v.state = 0
      elseif v.zone:IsAllInZoneOfCoalition(1) then
        --Red
        v.state = 1
        store.redScore = store.redScore + 1
      elseif v.zone:IsAllInZoneOfCoalition(2) then
        --Blue
        v.state = 2
        store.blueScore = store.blueScore + 1
      else
        --Both
        v.state = -1
      end
    end
  end
  env.info(string.format("TFL Score Red %d Blue %d", store.redScore, store.blueScore))
end

local function removeInitial(store)
  COORDINATE:RemoveMark(store.redBase.zone.DrawID)
  COORDINATE:RemoveMark(store.blueBase.zone.DrawID)
  for k, v in pairs(store.missions) do
    COORDINATE:RemoveMark(v.lineDrawID)
    COORDINATE:RemoveMark(v.textBoxID)
  end
end

local function paintIntel(store)
  for i, level in pairs(store.zones) do
    for i, v in pairs(level.conflictZones) do
      if v.zone.DrawID then
         COORDINATE:RemoveMark(v.zone.DrawID)
      end if v.textBoxID then
         COORDINATE:RemoveMark(v.textBoxID)
      end
      v.zone:DrawZone(-1, TFL.color.black, 0.8, TFLZoneStateColor(v.state), 0.2, 5, true)
      local zoneRadius = v.zone:GetRadius()
      v.textBoxID = v.zone:GetCoordinate():Translate(zoneRadius * 1.5, 315):TextToAll(TFLZoneStateText(v.state, v.name) ,-1, TFL.color.white, 1, TFLZoneStateColor(v.state), 0.3, 11)
    end
  end
end

function gameLoop(store)
  env.info("Running GameLoop")
  scanIntel(store)
  missionLoop(store)
  paintIntel(store)

  local blueMissions = TFL.filter(store.missions, function(e) return e.side == 2 end)
  local redMissions = TFL.filter(store.missions, function(e) return e.side == 1 end)
  if TFL.tableLength(redMissions) <= store.maxConcurrentMissions then
    timer.scheduleFunction(triggerMission, {side = 1, base = store.redBase, store = store}, timer.getTime() + 1)
  end if TFL.tableLength(blueMissions) <= store.maxConcurrentMissions then
    timer.scheduleFunction(triggerMission, {side = 2, base = store.blueBase, store = store}, timer.getTime() + 1)
  end

  timer.scheduleFunction(gameLoop, store, timer.getTime() + 30)
end


function TFLStartGame(store)
  --Draw Bases
  if store.blueBaseDrawID then COORDINATE:RemoveMark(store.blueBaseDrawID.DrawID) end
  if store.redBaseDrawID then COORDINATE:RemoveMark(store.redBaseDrawID.DrawID) end
  store.blueBaseDrawID = store.blueBase.zone:DrawZone(-1, TFL.color.black, 0.8, TFL.color.blue, 0.4, 4, true)
  store.redBaseDrawID = store.redBase.zone:DrawZone(-1, TFL.color.black, 0.8, TFL.color.red, 0.4, 4, true)

  --Draw Frontlines
  for i, level in pairs(store.zones) do
    local previousZone = nil
    for i, v in pairs(level.conflictZones) do
      if previousZone ~= nil then
        v.lineDrawID = v.zone:GetCoordinate():LineToAll(previousZone.zone:GetCoordinate(), -1, TFL.color.white, 1.0, 2, true)
      end
      previousZone = v
    end
  end

  --Draw Progression
  local previousZone = store.blueBase
  for i, level in pairs(store.zones) do
    local closestZone = nil
    local closestDistance = 1000000000000
    for i, v in pairs(level.conflictZones) do
      local distance = previousZone.zone:GetCoordinate():Get2DDistance(v.zone:GetCoordinate())
      if distance < closestDistance then
        closestDistance = distance
        closestZone = v
      end
    end

    previousZone.lineDrawID = previousZone.zone:GetCoordinate():LineToAll(closestZone.zone:GetCoordinate(), -1, TFL.color.green, 1.0, 6, true)
    previousZone = closestZone
  end
  previousZone.zone:GetCoordinate():LineToAll(store.redBase.zone:GetCoordinate(), -1, TFL.color.green, 1.0, 6, true)

  gameLoop(store)
end
