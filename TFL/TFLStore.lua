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
      { "Atkasia", 20},
      { "BMP3", 20},
  },
  ["BlueBase"] = "BLUEBorderZone",
  ["BlueAssets"] = {
    { "Paladin", 20},
    { "M270", 20},
    { "Truck", 20},
    { "Leclerc", 20},
    { "TPz", 20},
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

for i,v in ipairs(configuration.BlueAssets) do
  table.insert(TFLStore.blueAssets, {
    ["spawn"] = SPAWN:New(v[1]),
    ["amount"] = v[2],
  })
end
for i,v in ipairs(configuration.RedAssets) do
  table.insert(TFLStore.redAssets, {
    ["spawn"] = SPAWN:New(v[1]),
    ["amount"] = v[2],
  })
end
-- printTable(TFLStore.BlueAssets)
-- printTable(TFLStore.RedAssets)
