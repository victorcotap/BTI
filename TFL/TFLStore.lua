-- Fill configuration information below --

local configuration = {
  ["Name"] = "Some Name",
  ["MaxConcurrentMissions"] = 3,
  ZonesBtoR = {
    -- Grouped by levels
    {"StagingZoneB"},
    {"ConflictZoneA", "ConflictZoneB", "ConflictZoneC"},
    {"ConflictZoneD", "ConflictZoneE"},
    {"ConflictZoneF", "ConflictZoneG", "ConflictZoneH"},
    {"StagingZoneR"}
  },
  ["RedBase"] = "REDBorderZone",
  ["RedAssets"] = {
    {"HL_DSHK", 30, 1},
    {"BTR-80", 30, 1},
    {"T-80UD", 30, 1}
  },
  ["BlueBase"] = "BLUEBorderZone",
  ["BlueAssets"] = {
    {"HL_DSHK", 30, 1},
    {"LAV-25", 30, 1},
    {"Challenger2", 30, 1}
  }
}

local nicosia = {
  ["Name"] = "Nicosia",
  ["MaxConcurrentMissions"] = 2,
  ZonesBtoR = {
    -- Grouped by levels
    {"Staging South West", "Staging South", "Staging South East"},
    {"Nicosia West Circle", "Cathedral", "Nicosia East Circle"},
    {"Staging West", "Staging North", "Staging East"}
  },
  ["RedBase"] = "Nicosia Red Base",
  ["RedAssets"] = {
    {"BTR-80", 30, 2},
    {"HL_DSHK", 30, 1},
    {"Challenger", 30, 2},
  },
  ["BlueBase"] = "Nicosia Blue Base",
  ["BlueAssets"] = {
    {"LAV-25", 30, 2},
    {"HL_DSHK", 30, 2},
    {"Leclerc", 30, 2},
  }
}

local ercan = {
  ["Name"] = "Ercan",
  ["MaxConcurrentMissions"] = 2,
  ZonesBtoR = {
    -- Grouped by levels
    {"East Hangar", "East Checkpoint"},
    {"Fuel Depot", "Control Tower", "Warehouse"},
    {"West Checkpoint", "South Hangar"},
  },
  ["RedBase"] = "Ercan Red Base",
  ["RedAssets"] = {
    {"HL_DSHK", 30, 2},
    {"BTR-80", 30, 1},
    {"T-80UD", 30, 1},
  },
  ["BlueBase"] = "Ercan Blue Base",
  ["BlueAssets"] = {
    {"LAV-25", 30, 2},
    {"HL_DSHK", 30, 2},
    {"Leclerc", 30, 2},
  }
}

-- See Initialization at the bottom of this file --
-- Do not modify after this line --

local function createGroup(coalitionNumber, groupData, battlefieldName)
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
      playerCanDrive = true
    }
  end

  local groupTable = {
    name = groupCoalition .. " " .. groupData[1] .. " " .. battlefieldName,
    task = "Ground Nothing",
    units = units,
    lateActivation = true
  }

  coalition.addGroup(groupCountry, Group.Category.GROUND, groupTable)
  GROUP:NewTemplate(groupTable, coalitionNumber, Group.Category.GROUND, groupCountry)

  return groupTable
end

local prepareGroup = function(side, configAssets, storeAssets, battlefieldName)
  for i, v in ipairs(configAssets) do
    local groupTable = createGroup(side, v, battlefieldName)

    table.insert(
      storeAssets,
      {
        spawn = SPAWN:New(groupTable.name):InitRandomizePosition(),
        amount = v[2],
        groupBy = TFL.ternary(v[3] ~= nil, v[3], 1)
      }
    )
  end
end

local function prepareStore(configuration)
  local TFLStore = {
    name = configuration.Name,
    maxConcurrentMissions = configuration.MaxConcurrentMissions,
    redBase = {
      zone = ZONE:New(configuration.RedBase),
      name = "Red Base",
      lineDrawID = nil,
      textBoxID = nil,
      state = 0
    },
    blueBase = {
      zone = ZONE:New(configuration.BlueBase),
      name = "Blue Base",
      lineDrawID = nil,
      textBoxID = nil,
      state = 0
    },
    zones = {},
    missions = {},
    redAssets = {},
    redMissions = 0,
    redScore = 0,
    blueAssets = {},
    blueMissions = 0,
    blueScore = 0
  }

  local Mission = {
    departureZone = nil,
    destinationZone = nil,
    description = nil,
    side = nil,
    group = nil,
    lineDrawID = nil,
    textBoxID = nil,
    active = false
  }

  for i, zones in ipairs(configuration.ZonesBtoR) do
    local levelZones = {
      level = i,
      conflictZones = {}
    }
    for i, zone in ipairs(zones) do
      table.insert(
        levelZones.conflictZones,
        {
          zone = ZONE:New(zone),
          name = zone,
          lineDrawID = nil,
          textBoxID = nil,
          state = 0
        }
      )
    end
    table.insert(TFLStore.zones, levelZones)
  end

  prepareGroup(2, configuration.BlueAssets, TFLStore.blueAssets, configuration.Name)
  prepareGroup(1, configuration.RedAssets, TFLStore.redAssets, configuration.Name)

  return TFLStore
end

-- Initialize stores and trigger game loop below
local firstBattleStore = prepareStore(nicosia)
TFLStartGame(firstBattleStore)
local secondBattleStore = prepareStore(ercan)
TFLStartGame(secondBattleStore)
