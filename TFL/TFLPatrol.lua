env.info("TFL: We patrolling ?")

-- Spawns Lib
local fighterHardSpawn = SPAWN:New("REDMirage")
local fighterEasySpawn = SPAWN:New("REDC101")

local deployedTable = {
  fightersGroups = { },
  singlePatrolGroup = nil
}

function triggerFighters(spawn)

    -- dynamic tasking to coord
  -- spawn:OnSpawnGroup(
  --   function(spawnGroup)
  --       spawnGroup:ClearTasks()
  --       local enrouteTask = spawnGroup:EnRouteTaskEngageTargets( 70000, { "Air" }, 1 )
  --       spawnGroup:SetTask(enrouteTask, 2)
  --       local orbitTask = spawnGroup:TaskOrbitCircleAtVec2( coord:GetVec2(), UTILS.FeetToMeters(22000), UTILS.KnotsToMps(350))
  --       spawnGroup:PushTask(orbitTask, 4)
  --   end
  -- )
  local fighterGroup = spawn:Spawn()
  function fighterGroup:OnEventLand(eventData)
    if fighterGroup.GroupName == eventData.IniGroupName then
      deployedTable.singlePatrolGroup = nil
      fighterGroup:Destroy()
    end
  end
  fighterGroup:HandleEvent(EVENTS.Land)
  return fighterGroup
end

function patrolLoop()
  -- check for alive patrol
  local patrolGroup = deployedTable.singlePatrolGroup
  if patrolGroup ~= nil then
    if patrolGroup:IsAlive() == false then
      env.info("TFL: Patrol group detected alive false, deleting")
      deployedTable.singlePatrolGroup = nil
    else
      return -- Group is alive
    end
  end

  -- check for random patrol trigger
  local random = math.random(1, 10)
  local spawnedGroup = nil
  if random % 2 == 0 then
    spawnedGroup = triggerFighters(fighterHardSpawn)
  elseif random % 2 > 0 then
    spawnedGroup =  triggerFighters(fighterEasySpawn)
  end
  env.info("TFL: Spawning group from random " .. tostring(random))

  -- record spawn
  deployedTable.singlePatrolGroup = spawnedGroup
  table.insert(deployedTable.fightersGroups, spawnedGroup)
end

mist.scheduleFunction(patrolLoop, {},  timer.getTime() + 1, 10)

env.info("TFL: We patrolling sir!")