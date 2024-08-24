_SETTINGS:SetPlayerMenuOn()
_SETTINGS:SetImperial()
_SETTINGS:SetA2G_BR()

local OFFSETDIRECTION = {
  NORTH = "N",
  EAST = "E",
  SOUTH = "S",
  WEST = "W"
}

local markHandler = EVENTHANDLER:New()
local taskStore = {}
local taskmanager = PLAYERTASKCONTROLLER:New("Dungeon Master", coalition.side.BLUE, PLAYERTASKCONTROLLER.Type.A2G)
taskmanager.verbose = true
taskmanager:SetLocale("en")
taskmanager:SetMenuName("Moose is broken")
taskmanager:EnableTaskInfoMenu()
taskmanager:SetMenuOptions(false, 9, 30)
taskmanager:SetAllowFlashDirection(true)
-- taskmanager:EnableMarkerOps("TASK")
taskmanager:SetTargetRadius(200)
taskmanager:SetClusterRadius(0.2)
taskmanager:SetTaskWhiteList(
  {
    AUFTRAG.Type.CAS,
    AUFTRAG.Type.BAI,
    AUFTRAG.Type.BOMBING,
    AUFTRAG.Type.BOMBRUNWAY,
    AUFTRAG.Type.SEAD,
    AUFTRAG.Type.PRECISIONBOMBING
  }
)
-- Set up using SRS for messaging
local hereSRSPath = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
local hereSRSPort = 5002
-- local hereSRSGoogle = "C:\\Program Files\\DCS-SimpleRadio-Standalone\\yourkey.json"
taskmanager:SetSRS({130,255},{radio.modulation.AM,radio.modulation.AM},hereSRSPath,"female") --,"en-GB",hereSRSPort,"Microsoft Hazel Desktop",0.7,hereSRSGoogle)
-- Controller will announce itself under these broadcast frequencies, handy to use cold-start frequencies here of your aircraft
taskmanager:SetSRSBroadcast({127.5,305},{radio.modulation.AM,radio.modulation.AM})
taskmanager:SetTransmitOnlyWithPlayers(false)

-- taskmanager:AddTarget(ZONE:New("Titi"))

function taskmanager:OnAfterTaskAdded(From, Event, To, Task)
  env.info("Task created")
  local task = Task -- Ops.PlayerTask#PLAYERTASK
  taskStore[task.PlayerTaskNr] = {
    task = task,
    players = {},
    rectId = nil,
    arrowId = nil,
    titleId = nil,
    playersTextId = nil,
    offsetCornerA = nil,
    offsetCornerC = nil,
    redOffsetCornerPoint = nil,
    greenOffsetCornerPoint = nil,
    completedLineA = nil,
    completedLineB = nil,
    firstLine = nil,
    greenButton = nil,
    redButton = nil,
    completed = false,
    credits = task:GetTarget():GetLife()
  }
  drawTaskOnMap(task)
  function task:OnAfterClientAdded(From, Event, To, Client)
    env.info(
      "TFL: Task " .. task.PlayerTaskNr .. "got new client " .. Client:GetPlayer() .. " and ucid " .. Client:GetUCID()
    )
    taskStore[task.PlayerTaskNr].players[Client:GetUCID()] = Client
    taskStore[task.PlayerTaskNr].completed = false
    drawUpdatableTextForTask(task)
  end
  function task:OnAfterClientRemoved(From, Event, To, Client)
    -- CLIENTGETPlayer doesn't work
    env.info("TFL: Task " .. task.PlayerTaskNr .. " had someone quit " .. Client:GetUCID())
    taskStore[task.PlayerTaskNr].players[Client:GetUCID()] = nil
    drawUpdatableTextForTask(task)
  end
end

function taskmanager:OnAfterTaskCancelled(From, Event, To, Task)
  local task = Task -- Ops.PlayerTask#PLAYERTASK
  clearTaskFromMap(task.PlayerTaskNr)

  taskStore[task.PlayerTaskNr] = nil
  env.info(
    string.format(
      "TFL: Task Cancelled ID #%03d | Type: %s | Threat: %d",
      task.PlayerTaskNr,
      task.Type,
      task.Target:GetThreatLevelMax()
    )
  )
  env.info("TFL: Task cancelled")
end

function taskmanager:OnAfterTaskSuccess(From, Event, To, Task)
  local task = Task -- Ops.PlayerTask#PLAYERTASK

  taskStore[task.PlayerTaskNr].comnpleted = true
  local cornerA = taskStore[task.PlayerTaskNr].offsetCornerA
  local cornerB = taskStore[task.PlayerTaskNr].offsetCornerB
  local cornerC = taskStore[task.PlayerTaskNr].offsetCornerC
  local cornerD = taskStore[task.PlayerTaskNr].offsetCornerD

  taskStore[task.PlayerTaskNr].completedLineA = cornerA:LineToAll(cornerC, coalition.side.BLUE, TFL.color.white, 0.9, 4)
  taskStore[task.PlayerTaskNr].completedLineB = cornerB:LineToAll(cornerD, coalition.side.BLUE, TFL.color.white, 0.9, 4)

  local log = { name = "Some Players", credits = taskStore[task.PlayerTaskNr].credits, reason = task.PlayerTaskNr .." completed", date = os.date("*t")}
  creditBalance("ttiGuild", taskStore[task.PlayerTaskNr].credits, log)

  env.info(
    string.format(
      "TFL: Task Succeeded ID #%03d | Type: %s | Threat: %d",
      task.PlayerTaskNr,
      task.Type,
      task.Target:GetThreatLevelMax()
    )
  )
end

function taskmanager:OnAfterTaskFailed(From, Event, To, Task)
  local task = Task -- Ops.PlayerTask#PLAYERTASK
  taskStore[task.PlayerTaskNr] = nil
  clearTaskFromMap(task.PlayerTaskNr)

  env.info(
    string.format(
      "TFL: Task Failed ID #%03d | Type: %s | Threat: %d",
      task.PlayerTaskNr,
      task.Type,
      task.Target:GetThreatLevelMax()
    )
  )
end


function drawTaskOnMap(task)
  env.info("TFL: Trying to draw task")
  local constantOffset = 200
  local id = task.PlayerTaskNr
  local coord = task:GetTarget():GetCoordinate()
  if task.Type == AUFTRAG.Type.CAS or task.Type == AUFTRAG.Type.BAI then
    drawRectArrowFromPointOffset(id, coord, constantOffset, OFFSETDIRECTION.NORTH, TFL.color.purple)
  elseif
    task.Type == AUFTRAG.Type.BOMBING or task.Type == AUFTRAG.Type.BOMBRUNWAY or
      task.Type == AUFTRAG.Type.PRECISIONBOMBING
   then
    drawRectArrowFromPointOffset(id, coord, constantOffset, OFFSETDIRECTION.EAST, TFL.color.turquoise)
  elseif task.Type == AUFTRAG.Type.SEAD then
    drawRectArrowFromPointOffset(id, coord, constantOffset, OFFSETDIRECTION.SOUTH, TFL.color.blue)
  else
    drawRectArrowFromPointOffset(id, coord, constantOffset, OFFSETDIRECTION.WEST, TFL.color.black)
  end
  drawUpdatableTextForTask(task)
end

function drawRectArrowFromPointOffset(id, coord, size, offsetDirection, color)
  local offsetAngle
  local offsetReverseAngle
  if offsetDirection == OFFSETDIRECTION.NORTH then
    offsetAngle = 0
    offsetReverseAngle = 180
  elseif offsetDirection == OFFSETDIRECTION.EAST then
    offsetAngle = 090
    offsetReverseAngle = 270
  elseif offsetDirection == OFFSETDIRECTION.SOUTH then
    offsetAngle = 180
    offsetReverseAngle = 360
  elseif offsetDirection == OFFSETDIRECTION.WEST then
    offsetAngle = 270
    offsetAngle = 090
  end

  -- calculate offset center
  local buttonOffsetDistance = size * 0.05
  local buttonHeightDistance = size * 0.2
  local offsetCenter = coord:Translate(size * 3, offsetAngle)
  local offsetCornerA = offsetCenter:Translate(size, 315)
  local offsetCornerB = offsetCenter:Translate(size, 225)
  local offsetCornerC = offsetCenter:Translate(size, 135)
  local offsetCornerD = offsetCenter:Translate(size, 045)
  local arrowCenter = offsetCenter:Translate(size * 0.75, offsetReverseAngle)
  local arrowPoint = arrowCenter:Translate(size * 0.75 * 2, offsetReverseAngle)
  local greenOffsetCornerPoint = offsetCornerB:Translate(buttonOffsetDistance, 045)
  local greenOffsetTopPoint = greenOffsetCornerPoint:Translate(buttonHeightDistance, 0)
  local greenEndTopPoint = greenOffsetTopPoint:Translate((size / 2) - buttonOffsetDistance, 090)
  local redOffsetCornerPoint = offsetCornerC:Translate(buttonOffsetDistance, 315)
  local redOffsetTopPoint = redOffsetCornerPoint:Translate(buttonHeightDistance, 0)
  local redEndTopPoint = redOffsetTopPoint:Translate((size / 2) - buttonOffsetDistance, 270)
  local joinPoint = greenOffsetTopPoint:Translate(buttonOffsetDistance, 0)
  local leavePoint = redEndTopPoint:Translate(buttonOffsetDistance, 0)

  taskStore[id].rectId = offsetCornerA:RectToAll(offsetCornerC, coalition.side.BLUE, color, 0.7, color, 0.2, 7)
  -- taskStore[id].arrowId = arrowCenter:ArrowToAll(arrowPoint, coalition.side.BLUE, color, 0.7, color, 0.2, 1)
  taskStore[id].lineArrowId = arrowCenter:LineToAll(arrowPoint, coalition.side.BLUE, color, 0.9, 5)
  taskStore[id].redButton = redOffsetCornerPoint:RectToAll(redEndTopPoint, coalition.side.BLUE, TFL.color.red, 0.7, TFL.color.red, 0.4, 5)
  taskStore[id].greenButton = greenOffsetCornerPoint:RectToAll(greenEndTopPoint, coalition.side.BLUE, TFL.color.green, 0.7, TFL.color.green, 0.4, 4)
  taskStore[id].joinTitleId = joinPoint:TextToAll("Join", coalition.side.BLUE, TFL.color.black, 0.8, nil, 0.0, 10)
  taskStore[id].leaveTitleId = leavePoint:TextToAll("Leave", coalition.side.BLUE, TFL.color.black, 0.8, nil, 0.0, 10)

  taskStore[id].offsetCornerA = offsetCornerA
  taskStore[id].offsetCornerB = offsetCornerB
  taskStore[id].offsetCornerD = offsetCornerD
  taskStore[id].offsetCornerC = offsetCornerC
  taskStore[id].redOffsetCornerPoint = redOffsetCornerPoint
  taskStore[id].greenOffsetCornerPoint = greenOffsetCornerPoint
end

function drawUpdatableTextForTask(task)
  local id = task.PlayerTaskNr
  if taskStore[id] == nil or taskStore[id].offsetCornerA == nil then
    return
  end
  if taskStore[id].titleId ~= nil then
    trigger.action.removeMark(taskStore[id].titleId)
  end

  local target = task:GetTarget()
  local players = taskStore[id].players
  local targetDescription =
    string.format(
    "Unit Count %d\nTotal Enemy HP %d",
    target:CountTargets(),
    target:GetLife()
  )
  local text = task.Type .. " " .. task.PlayerTaskNr .. "\n" .. targetDescription .. "\n"
  local playersText = "Assigned Pilots:\n"
  for k, v in pairs(players) do
    if v ~= nil then
      playersText = playersText .. v:GetPlayer() .. "\n"
    end
  end
  text = text .. "\n" .. playersText
  local firstLine = taskStore[id].offsetCornerA:Translate(25, 135)
  taskStore[id].titleId = firstLine:TextToAll(text, coalition.side.BLUE, TFL.color.black, 0.8, nil, 0.0, 10)
end



function clearTaskFromMap(taskId)
  trigger.action.removeMark(taskStore[taskId].titleId)
  trigger.action.removeMark(taskStore[taskId].joinTitleId)
  trigger.action.removeMark(taskStore[taskId].leaveTitleId)
  trigger.action.removeMark(taskStore[taskId].rectId)
  trigger.action.removeMark(taskStore[taskId].greenButton)
  trigger.action.removeMark(taskStore[taskId].redButton)
  trigger.action.removeMark(taskStore[taskId].lineArrowId)
  if taskStore[taskId].completedLineA then
    trigger.action.removeMark(taskStore[taskId].completedLineA)
  end
  if taskStore[taskId].completedLineB then
    trigger.action.removeMark(taskStore[taskId].completedLineB)
  end
end

local function sanitizeTaskPlayerList()
  for id, task in pairs(taskStore) do
    for i, client in ipairs(task.players) do
      if client:IsAlive() == nil then
        table.remove(task.players, i)
        drawUpdatableTextForTask(task)
      end
    end
  end
end

function markHandler:onEvent(Event)
  if Event.id == world.event.S_EVENT_MARK_REMOVED then
    local vec3 = {y = Event.pos.y, x = Event.pos.x, z = Event.pos.z}
    local coord = COORDINATE:NewFromVec3(vec3)
    coord.y = coord:GetLandHeight()

    -- -scan radius=1000
    if Event.text ~= nil and Event.text:lower():find("-scan") then
      -- fields to fill
      local zoneRadius = 750
      local shouldScan = true

      -- command parsing
      local arguments = TFL.split(Event.text, " ")
      for _, argument in pairs(arguments) do
        local argumentValues = TFL.split(argument, "=")
        local command = argumentValues[1]
        local value = argumentValues[2]

        if command == "radius" and value ~= nil then
          zoneRadius = tonumber(value)
        end
      end

      -- execution
      if shouldScan then
        env.info("TFL: Trying to scan new zone")
        local zoneToScan = ZONE_RADIUS:New(Event.id, coord:GetVec2(), zoneRadius)
        taskmanager:AddTarget(zoneToScan)
        -- clearLoading()
        zoneToScan:DrawZone(coalition.side.BLUE, TFL.color.black, 0.4, TFL.color.white, 0.4, 3, true)
        local textToClear = coord:TextToAll("Scanning\nPlease wait", coalition.side.BLUE, TFL.color.black, 0.8, nil, 0.0, 16)
        zoneToScan:UndrawZone(60)
        mist.scheduleFunction(clearMark, {textToClear},  timer.getTime() + 60)
      end
    elseif Event.text ~= nil and Event.text:lower():find("-click") then
      -- RE-ENABLE THIS ONCE SUPPORT WORK IS DONE
      local client = CLIENT:FindByPlayerName(Event.initiator:getPlayerName())
      env.info("TFL: player " .. UTILS.OneLineSerialize(client))
      for k, store in pairs(taskStore) do
        if coord:IsInRadius(store.greenOffsetCornerPoint, 200) then
          env.info("TFL: adding to task")
          taskmanager:_JoinTask(store.task, true, client:GetGroup(), client)
          return true
        elseif coord:IsInRadius(store.redOffsetCornerPoint, 200) then
          env.info("TFL: removing from task")
          taskmanager:_AbortTask(client:GetGroup(), client)
          return true
        end
      end
    end
  end
end

function clearMark(markId)
  if markId ~= nil then
    trigger.action.removeMark(markId)
  end
end

world.addEventHandler(markHandler)
SCHEDULER:New(nil, sanitizeTaskPlayerList, {}, 10, 60)

env.info("TFL: Task Manager finished")
