env.info("TFL: Wanna invest in Wall Street brah?")

local resourceTableZoneName = "ResourceTable"
local logTableZoneName = "LogTable"
local startingBalance = 10000
local gridUnitSize = 3000
local fontSize = 16

-- DO NOT MODIFY BELOW
local resourceTableZone = ZONE:FindByName(resourceTableZoneName)
local logTableZone = ZONE:FindByName(logTableZoneName)

-- initializer
local resourceMasterKey = "resourceMaster"
local resourceGuildStore = LOCALGet(resourceMasterKey)
local resourceGuildStore = {
  ["ttiGuild"] = {
    balance = 3487,
    color = TFL.color.grey,
    log = {
      { name = "Topper", credits = 243, reason = "Task Bombing #002", date = os.date("*t")},
      { name = "JMoon", credits = -34, reason = "Moved CVN", date = os.date("*t")},
      { name = "Coletrain", credits = -134, reason = "Moved LHA", date = os.date("*t")},
      { name = "Coletrain", credits = 230, reason = "Task SEAD #003", date = os.date("*t")},
      { name = "Coleplane", credits = 230, reason = "Task SEAD #003", date = os.date("*t")},
      { name = "Sheepy", credits = 230, reason = "Task SEAD #003", date = os.date("*t")},
    },
  },
  ["oneOSeventhGuild"] = {
    balance = 2984,
    color = TFL.color.orange,
    log = {
      { name = "Pizza", credits = -150, reason = "Support F14", date = os.date("*t")},
      { name = "Whiskey", credits = 243, reason = "Task BAI #004", date = os.date("*t")}
    },
  }
}

local resourceTableStore = {
  intelMarkIds = {},
  logMarkIds = {},
  logCoord = nil
}

local function generateResourceLines()
  local lines = {
    { {text = "Guild Name", size = 1}, {text = ""}, {text = "Remaining Balance"} }
  }

  for guildName, guild in pairs(resourceGuildStore) do
    local line = {
      {text = guildName, color = guild.color},
      {text = "", color = guild.color }, --empty
      {text = tostring(guild.balance), color = guild.color},
    }
    table.insert(lines, line)
  end

  return lines
end

local function clearIntel()
  for i, markId in ipairs(resourceTableStore.intelMarkIds) do
    trigger.action.removeMark(markId)
  end
  resourceTableStore.intelMarkIds = {}
end

local function drawIntel(coord)
  local lines = generateResourceLines()
  local markIds = TFL.drawMenu(coord, lines, gridUnitSize, fontSize, true)
  resourceTableStore.intelMarkIds = markIds
end

local function drawPreviousLogs(coord)
  local lines = {
    { {text = "Time", size = 2}, {text = "Player Name"}, {text = "Credits"}, {text = "Reason"}, }
  }

  for guildName, guild in pairs(resourceGuildStore) do
    for i, logLine in ipairs(guild.log) do
      local line = {
        {size = 2, text = os.date("%A, %m %B %Y |") .. ("%02d:%02d:%02d"):format(logLine.date.hour, logLine.date.min, logLine.date.sec)},
        {text = logLine.name, color = guild.color},
        {text = tostring(logLine.credits), color = guild.color},
        {text = logLine.reason, color = guild.color},
      }
      table.insert(lines, line)
    end
  end

  -- trim log to 10 or 5 max lines

  local markIds, buttonsCoord, originPoint = TFL.drawMenu(coord, lines, gridUnitSize, fontSize, true)
  resourceTableStore.logMarkIds = markIds
  resourceTableStore.logCoord = originPoint
end

local function drawNextLog(coord, logLine)
  local lines = {
    {
      {size = 2, text = os.date("%A, %m %B %Y |") .. ("%02d:%02d:%02d"):format(logLine.date.hour, logLine.date.min, logLine.date.sec)},
      {text = logLine.name, color = TFL.color.grey},
      {text = tostring(logLine.credits), color = TFL.color.grey},
      {text = logLine.reason, color = TFL.color.grey},
    }
  }
  local markIds, buttonsCoord, originPoint = TFL.drawMenu(coord, lines, gridUnitSize, fontSize, true)
  resourceTableStore.logMarkIds = markIds
  resourceTableStore.logCoord = originPoint
end

local function intelRefreshLoop()
  clearIntel()
  drawIntel(resourceTableZone:GetCoordinate())
end

function debitBalance(guild, credits, log)
  local newTotal = resourceGuildStore[guild].balance - credits
  if newTotal > 0 then
    resourceGuildStore[guild].balance = resourceGuildStore[guild].balance - credits
    if log ~= nil then
      table.insert(resourceGuildStore[guild].log, log)
      intelRefreshLoop()
      drawNextLog(resourceTableStore.logCoord, log)
      trigger.action.outText("Someone just emptied the bank a bit more", 10)
    end
    return true
  end
  return false
end

function creditBalance(guild, credits, log)
  resourceGuildStore[guild].balance = resourceGuildStore[guild].balance + credits
  if log ~= nil then
    table.insert(resourceGuildStore[guild].log, log)
    intelRefreshLoop()
    drawNextLog(resourceTableStore.logCoord, log)
    trigger.action.outText("Someone made us some money, check the resource table", 10)
  end
end

local intelTitlePoint = resourceTableZone:GetCoordinate():Translate(gridUnitSize / 4 , 0)
intelTitlePoint:TextToAll("INTEL TABLE", coalition.side.BLUE, TFL.color.grey, 0.8, nil, 0.0, 48)
local logTitlePoint = logTableZone:GetCoordinate():Translate(gridUnitSize / 4 , 0)
logTitlePoint:TextToAll("LOG TABLE", coalition.side.BLUE, TFL.color.grey, 0.8, nil, 0.0, 48)
mist.scheduleFunction(intelRefreshLoop, {},  timer.getTime() + 1, 60)
intelRefreshLoop()
drawPreviousLogs(resourceTableStore.logCoord or logTableZone:GetCoordinate())

env.info("TFL: Annnnnnnnd it's gone brah")