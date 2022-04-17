local function triggerMission(side, baseZone, store)

  -- Randomize new Mission
  -- Spawn units but randomize time (+5 minutes) at which they depart
  -- Store mission with groups table to check

  -- Rules of the gameLoop
  -- Holding conflict zones gives you point
  -- Fill up a level before moving to the next one
  -- If a level if contested (one zone held by enemy side)
    -- Always target the enemy zone
    -- Then select an empty zone

  local destination = TFLFindEmptyContestedZone(store.zones, side)

  --FIXME: Randomize asset selection ?
  local group = asset:SpawnInZone(baseZone.zone, true)
  group:RouteToVec2()

  local missionTextCoordinate = TFLMiddleCoordinate(baseZone.zone:GetCoordinate(), destination.zone:GetCoordinate())
  local lineDrawID = baseZone.zone:GetCoordinate():LineToAll(store.zones[3].conflictZones[1].zone:GetCoordinate(), -1, TFL.color.red, 0.8, 4, true)
  local textBoxID = missionTextCoordinate:TextToAll("Test Mission text" ,-1, TFL.color.white, 1, TFL.color.red, 0.3, 14)
  local mission = {
    departureZone = baseZone,
    destinationZone = destination,
    description = "We going boyz",
    side = side,
    group = group,
    lineDrawID = lineDrawID,
    textBoxID = textBoxID,
  }
  table.insert(store.missions, mission)
end

local function missionLoop(store)
  -- Check if spawned group is dead or arrived at destination
  for i, v in ipairs(store.missions) do
    if v.group:IsCompletelyInZone(v.destinationZone.zone) or v.group.IsAlive() == nil then
      --delete mission
      v.group:MessageToCoalition("We have arrived at our destination! HODDOR!", 15, v.side)
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
      elseif v.zone:IsAllInZoneOfCoalition(2) then
        --Blue
        v.state = 2
      else
        --Both
        v.state = -1
      end
    end
  end

  timer.scheduleFunction(scanIntel, store, timer.getTime() + 10)
end

local function paintInitial(store)
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
end

local function paintIntel(store)

  --Draw conflict zones
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

  --Draw missions
  local missionTextCoordinate = TFLMiddleCoordinate(store.blueBase.zone:GetCoordinate(), store.zones[2].conflictZones[2].zone:GetCoordinate())
  store.blueBase.zone:GetCoordinate():LineToAll(store.zones[2].conflictZones[2].zone:GetCoordinate(), -1, TFL.color.blue, 0.8, 4, true)
  missionTextCoordinate:TextToAll("Test Mission text" ,-1, TFL.color.white, 1, TFL.color.blue, 0.3, 14)

  missionTextCoordinate = TFLMiddleCoordinate(store.redBase.zone:GetCoordinate(), store.zones[3].conflictZones[1].zone:GetCoordinate())
  store.redBase.zone:GetCoordinate():LineToAll(store.zones[3].conflictZones[1].zone:GetCoordinate(), -1, TFL.color.red, 0.8, 4, true)
  missionTextCoordinate:TextToAll("Test Mission text" ,-1, TFL.color.white, 1, TFL.color.red, 0.3, 14)

  timer.scheduleFunction(paintIntel, store, timer.getTime() + 10)
end

local function gameLoop(store)
  env.info("Running GameLoop")
  -- Check on missions in progress
  missionLoop(store)

  -- If currentMissions < maxConcurrentMissions
  local blueMissions = TFL.filter(store.missions, function(e) return e.side == 2 end)
  local redMissions = TFL.filter(store.missions, function(e) return e.side == 1 end)
  if TFL.tableLength(redMissions) < store.maxConcurrentMissions then
    triggerMission(1, store.redBase, store)
  end
  if TFL.tableLength(blueMissions) < store.maxConcurrentMissions then
    triggerMission(2, store.blueBase, store)
  end

  -- Display Intel
  -- Color zones according to status
  -- Color lines according to missions

  timer.scheduleFunction(gameLoop, store, timer.getTime() + 30)
end

gameLoop(TFLStore)
scanIntel(TFLStore)
paintInitial(TFLStore)
paintIntel(TFLStore)
