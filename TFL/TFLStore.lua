-- Fill configuration information below --

local configuration = {
  ["Name"] = "Some Name",
  ["MaxConcurrentMissions"] = 4,
  ZonesBtoR = { -- Grouped by levels
    {"StagingZoneB"},
    {"ConflictZoneA", "ConflictZoneB", "ConflictZoneC"},
    {"ConflictZoneD", "ConflictZoneE"},
    {"ConflictZoneF", "ConflictZoneG", "ConflictZoneH"},
    {"StagingZoneR"},
  },
  ["RedBase"] = "REDBorderZone",
  ["RedAssets"] = {
      { "Gepard", 20, 2},
      { "BMP-3", 20, 4},
  },
  ["BlueBase"] = "BLUEBorderZone",
  ["BlueAssets"] = {
    { "Gepard", 20},
    { "Challenger2", 20},
  }
}

-- Do not modify after this line --

TFLStore = {
  name = configuration.Name,
  maxConcurrentMissions = configuration.MaxConcurrentMissions,
  redBase = {
    zone = ZONE:New(configuration.RedBase),
    name = "Red Base",
    lineDrawID = nil,
    textBoxID = nil,
    state = 0,
  },
  blueBase = {
    zone = ZONE:New(configuration.BlueBase),
    name = "Blue Base",
    lineDrawID = nil,
    textBoxID = nil,
    state = 0,
  },
  zones = {},
  missions = {},
  redAssets = {},
  redMissions = 0,
  blueAssets = {},
  blueMissions = 0,
}

local Mission = {
  departureZone = nil,
  destinationZone = nil,
  description = nil,
  side = nil,
  group = nil,
  lineDrawID = nil,
  textBoxID = nil,
}

for i,zones in ipairs(configuration.ZonesBtoR) do
  local levelZones = {
    level = i,
    conflictZones = {}
  }
  for i,zone in ipairs(zones) do
    table.insert(levelZones.conflictZones, {
      zone = ZONE:New(zone),
      name = zone,
      lineDrawID = nil,
      textBoxID = nil,
      state = 0,
    })
  end
  table.insert(TFLStore.zones, levelZones)
end


local function createGroup(coalitionNumber, groupData)
  local groupAmount = TFL.ternary(groupData[3] ~= nil, groupData[3], 1)
  local groupCoalition = TFL.ternary(coalitionNumber == 1, "R", "B")
  local groupCountry = TFL.ternary(coalitionNumber == 1, country.id.CJTF_RED, country.id.CJTF_BLUE)
  local units = {}
  for i = 1, groupAmount, 1 do
    units[i] = {
      name = groupCoalition .. " " .. groupData[1] .. tostring(i),
      type = groupData[1],
      x = 0,
      y = 0,
      playerCanDrive = true,
    }
  end

  local groupTable = {
    name = groupCoalition .. " " .. groupData[1],
    task = "Ground Nothing",
    units= units,
    lateActivation = true,
  }

  coalition.addGroup(groupCountry, Group.Category.GROUND, groupTable)
  GROUP:NewTemplate(groupTable, coalitionNumber, Group.Category.GROUND, groupCountry)

  return groupTable
end

for i,v in ipairs(configuration.BlueAssets) do
  local groupTable = createGroup(2, v)

  table.insert(TFLStore.blueAssets, {
    spawn = SPAWN:New(groupTable.name),
    amount = v[2],
    groupBy = TFL.ternary(v[3] ~= nil, v[3], 1),
  })
end
for i,v in ipairs(configuration.RedAssets) do
  local groupTable = createGroup(1, v)

  table.insert(TFLStore.redAssets, {
    spawn = SPAWN:New(groupTable.name),
    amount = v[2],
  })
end
-- printTable(TFLStore.BlueAssets)
-- printTable(TFLStore.RedAssets)
