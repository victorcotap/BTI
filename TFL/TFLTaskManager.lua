_SETTINGS:SetPlayerMenuOn()
_SETTINGS:SetImperial()
_SETTINGS:SetA2G_BR()

local taskmanager = PLAYERTASKCONTROLLER:New("Dungeon Master",coalition.side.BLUE,PLAYERTASKCONTROLLER.Type.A2G)
taskmanager.verbose = true
taskmanager:SetLocale("en")
taskmanager:SetMenuName("Jessica")
taskmanager:EnableTaskInfoMenu()
taskmanager:SetAllowFlashDirection(true)
taskmanager:EnableMarkerOps("TASK")
-- taskmanager:SetupIntel("Aerial")
taskmanager:SetTargetRadius(100)
taskmanager:SetTaskWhiteList({AUFTRAG.Type.CAS, AUFTRAG.Type.BAI, AUFTRAG.Type.BOMBING, AUFTRAG.Type.BOMBRUNWAY, AUFTRAG.Type.SEAD, AUFTRAG.Type.PRECISIONBOMBING})

taskmanager:AddTarget(ZONE:New("Tata"))
taskmanager:AddTarget(ZONE:New("Toto"))

function taskmanager:OnAfterTaskAdded(From,Event,To,Task)
  env.info("Task created")
  local task = Task -- Ops.PlayerTask#PLAYERTASK
  local target = task:GetTarget()
  local taskDescription = string.format("ID #%03d | Type: %s | Player Count: %d",task.PlayerTaskNr,task.Type, task:CountClients())
  local targetDescription = string.format(" %s | Count %d | Life %d | Damage %d", target:GetName(), target:CountTargets(), target:GetLife(), target:GetDamage())
  env.info("TFL: Task Created " .. taskDescription)
  env.info("TFL: Target name " .. targetDescription)
  task:MarkTargetOnF10Map(taskDescription .. "\n" .. targetDescription, coalition.side.BLUE, true)
end

function taskmanager:OnAfterTaskCancelled(From, Event, To, Task)
  local task = Task -- Ops.PlayerTask#PLAYERTASK
  env.info(string.format("TFL: Task Cancelled ID #%03d | Type: %s | Threat: %d",task.PlayerTaskNr,task.Type,task.Target:GetThreatLevelMax()))
  env.info("TFL: Task cancelled")
end

function taskmanager:OnAfterTaskSuccess(From, Event, To, Task)
  local task = Task -- Ops.PlayerTask#PLAYERTASK
  env.info(string.format("TFL: Task Succeeded ID #%03d | Type: %s | Threat: %d",task.PlayerTaskNr,task.Type,task.Target:GetThreatLevelMax()))
end

function taskmanager:OnAfterTaskFailed(From, Event, To, Task)
  local task = Task -- Ops.PlayerTask#PLAYERTASK
  env.info(string.format("TFL: Task Failed ID #%03d | Type: %s | Threat: %d",task.PlayerTaskNr,task.Type,task.Target:GetThreatLevelMax()))
end

env.info("TFL: Task Manager finished")