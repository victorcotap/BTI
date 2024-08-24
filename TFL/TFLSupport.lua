env.info("TFL: Support Bros are here buddy")

local supportStore = {
  supports = {
    {
      type = "aar",
      title = "S-3B Refueling",
      cost = 0,
      cooldown = 0,
      lastUse = nil, --timestamp integer
    },
    {
      type = "cap",
      title = "F-14-B CAP",
      cost = 200,
      cooldown = 0,
      lastUse = nil, --timestamp integer
    },
    {
      type = "bomb",
      title = "S-3B Bombing",
      cost = 100,
      cooldown = 0,
      lastUse = nil, --timestamp integer
    },
    -- {
    --   type = "sead",
    --   title = "F/A18-C SEAD",
    --   cost = 300,
    --   cooldown = 0,
    --   lastUse = nil, --timestamp integer
    -- }
  },

  supportMenu = {
    buttonCoords = {},
    supportMenuIds = {},
    coord = nil,
  },
  isSupportMenuOn = false
}

local markHandler = EVENTHANDLER:New()
local aarSpawn = SPAWN:New("S-3B-AAR")
local capSpawn = SPAWN:New("F14-CAP")
local bombSpawn = SPAWN:New("S-3B-BOMB")
local gridUnitSize = 400
local lineHeight = gridUnitSize / 4
local fontSize = 16
local menuCooldown = 30

local function clearSupportMenu()
  if supportStore.isSupportMenuOn then
    for i, markId in ipairs(supportStore.supportMenu.supportMenuIds) do
      env.info("TFL: trying to remove menu mark ", tostring(markId))
      trigger.action.removeMark(markId)
    end
  end
  supportStore.isSupportMenuOn = false
  supportStore.supportMenu.buttonCoords = {}
  supportStore.supportMenu.supportMenuIds = {}
  supportStore.supportMenu.coord = nil
end

-- Tasking
local function sendCAPAtCoordinate(coord)
  capSpawn:OnSpawnGroup(function( spawnedGroup )
    local orbitTask = spawnedGroup:TaskOrbitCircleAtVec2(coord:GetVec2(), 8000, UTILS.KnotsToMps(350))
    local engageTask = spawnedGroup:EnRouteTaskEngageTargets(150000)
    spawnedGroup:PushTask(orbitTask, 1)
    spawnedGroup:PushTask(engageTask, 2)
  end)
  capSpawn:Spawn()
end
local function sendBombAtCoordinate(coord)
  if coord == nil then
    env.info("TFL: bomb coordinate is nil, aborting")
    return
  end
  bombSpawn:OnSpawnGroup(function( spawnedGroup )
    -- local routeTask = spawnedGroup:TaskRouteToVec2(coord:GetVec2(), UTILS.KnotsToMps(280))
    local bombTask = spawnedGroup:TaskBombing( coord:GetVec2(), true, AI.Task.WeaponExpend.ALL)
    -- spawnedGroup:PushTask(routeTask, 1)
    spawnedGroup:PushTask(bombTask, 2)
  end)
  bombSpawn:Spawn()
end
local function sendAARAtCoordinate(coord)
  aarSpawn:OnSpawnGroup(function (spawnedGroup)
    local task = spawnedGroup:TaskOrbitCircleAtVec2(coord:GetVec2(), 5000, UTILS.KnotsToMps(250))
    local tankerTask = spawnedGroup:EnRouteTaskTanker()
    spawnedGroup:PushTask(task, 1)
    env.info("DEBUG yeah we tasking")
  end)
  aarSpawn:Spawn()
end

local function executeSupport(supportIndex)
  local support = supportStore.supports[supportIndex]
  local type = support.type
  local cost = support.cost
  if type == "aar" then
    if debitBalance("ttiGuild", cost, { name = "Some Player", credits = cost, reason = type, date = os.date("*t")}) == true then
      sendAARAtCoordinate(supportStore.supportMenu.coord)
    else
      trigger.action.outText("You do not have the necessary funds to perform this action", 10)
    end
  elseif type == "cap" then
    -- if check cooldown is
    if debitBalance("ttiGuild", cost, { name = "Some Player", credits = cost, reason = type, date = os.date("*t")}) == true then
      sendCAPAtCoordinate(supportStore.supportMenu.coord)
    else
      trigger.action.outText("You do not have the necessary funds to perform this action", 10)
    end
  elseif type == "sead" then
    -- sendSEADAtCoordinate(coord)
  elseif type == "bomb" then
    if debitBalance("ttiGuild", cost, { name = "Some Player", credits = cost, reason = type, date = os.date("*t")}) == true then
      sendBombAtCoordinate(supportStore.supportMenu.coord)
    else
      trigger.action.outText("You do not have the necessary funds to perform this action", 10)
    end
  end
  clearSupportMenu()
end

-- Menu drawing ## EACH LINE MUST HAVE THE SAME LENGTH OF COLUMNS FOR THE WHOLE TABLE ##
local function generateSupportLines()
  local lines = {
    {
      {text = "Type", size = 2, color = TFL.color.turquoise},
      {text = "Cost", color = TFL.color.red},
      {text = "Cooldown", color = TFL.color.yellow},
      {text = "Request", color = TFL.color.purple},
    },
  }
  for i, support in ipairs(supportStore.supports) do
    local line = {
      {text = support.title, size = 2, color = TFL.color.turquoise},
      {text = tostring(support.cost)},
      {text = tostring(support.cooldown) .. " minutes"},
      {type = "button", size = 1, color = TFL.color.grey}
    }
    table.insert(lines, line)
  end
  return lines
end

-- Map marker
function markHandler:onEvent(Event)
  if Event.id == world.event.S_EVENT_MARK_REMOVED then
    local vec3 = {y = Event.pos.y, x = Event.pos.x, z = Event.pos.z}
    local coord = COORDINATE:NewFromVec3(vec3)
    coord.y = coord:GetLandHeight()

    -- -scan radius=1000
    if Event.text ~= nil and Event.text:lower():find("-support") then
      if supportStore.isSupportMenuOn == true then
        trigger.action.outText("Someone else is already using the support menu, please wait", 10)
        return true
      end

      local supportMarkIds, buttonsCoord = TFL.drawMenu(coord, generateSupportLines(), gridUnitSize)
      supportStore.supportMenu.supportMenuIds = supportMarkIds
      supportStore.supportMenu.buttonCoords = buttonsCoord
      supportStore.supportMenu.coord = coord

      -- drawSupportMenu(coord, gridUnitSize, generateSupportLines())
      supportStore.isSupportMenuOn = true
      SCHEDULER:New(nil, clearSupportMenu, {"something"}, menuCooldown)
      trigger.action.outText("Support menu has been requested, please wait " .. tostring(menuCooldown) .. "secs to request again.", 10)
    elseif Event.text ~= nil and Event.text:lower():find("-clear") then
      clearSupportMenu()
      trigger.action.outText("Support menu is available again", 10)

    elseif Event.text ~= nil and Event.text:lower():find("-click") then
      -- local client = CLIENT:FindByPlayerName(Event.initiator:getPlayerName())
      -- env.info("TFL: player " .. UTILS.OneLineSerialize(client))
      for i, buttonCoord in ipairs(supportStore.supportMenu.buttonCoords) do
        if coord:IsInRadius(buttonCoord, lineHeight * 0.8) and supportStore.supportMenu.coord ~= nil then
          env.info("TFL: Clicked on support button " .. tostring(i))
          executeSupport(i) -- pass player name here
        end
      end
    end
  end
end

world.addEventHandler(markHandler)
env.info("TFL: Support system in place")
