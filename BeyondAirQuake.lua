HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )


--------------------------------------------------------------------
fighterHardSpawn = SPAWN:New("RED J11")
fighterMediumSpawn = SPAWN:New("RED F14")
fighterEasySpawn = SPAWN:New('RED Mig21')
casHardSpawn = SPAWN:New('RED Su34')
casMediumSpawn = SPAWN:New('RED Su25TM')
casEasySpawn = SPAWN:New('Red Mi28')

local zoneFightersCounter = 0
local fighterTrack = {}
local casTrack = {}
-- local fighterResources = BeyondPersistedStore['']
--------------------------------------------------------------------

function triggerFighters(spawn, coord)
    spawn:OnSpawnGroup(
        function(spawnGroup)
            spawnGroup:ClearTasks()
            env.info(string.format("BTI: Sending fighter group %d to zone ", zoneFightersCounter))
            local enrouteTask = spawnGroup:EnRouteTaskEngageTargets( 70000, { "Air" }, 1 )
            spawnGroup:SetTask(enrouteTask, 2)
            local routeTask = spawnGroup:TaskRouteToVec2( coord:GetVec2(), UTILS.KnotsToMps(400), "cone" )
            spawnGroup:PushTask(routeTask, 4)
        end 
    )
    spawn:Spawn()
end

function triggerCAS(spawn, coord)
    spawn:OnSpawnGroup(
        function(spawnGroup)
            env.info(string.format("BTI: Sending cas group to zone "))
            spawnGroup:ClearTasks()
            local casTask = spawnGroup:EnRouteTaskEngageTargets( 20000, { "All" }, 1 )
            spawnGroup:SetTask(casTask, 2)
            local orbitTask = spawnGroup:TaskOrbitCircleAtVec2( coord:GetVec2(), UTILS.FeetToMeters(8000), UTILS.KnotsToMps(2700))
            spawnGroup:PushTask(orbitTask, 4)
        end
    )
    spawn:Spawn()
end

function deployFighters(spawn, coord)
    spawn:OnSpawnGroup(
        function(spawnGroup)
            spawnGroup:ClearTasks()
            env.info(string.format("BTI: Deploying fighters at requested zone"))

            local orbitTask = spawnGroup:TaskOrbitCircleAtVec2( coord:GetVec2(), UTILS.FeetToMeters(18000) , UTILS.KnotsToMps(400))
            -- spawnGroup:SetTask(orbitTask)
            local enrouteTask = spawnGroup:EnRouteTaskEngageTargets( 70000, { "Air" }, 1 )
            -- spawnGroup:PushTask(enrouteTask)
            local combo = spawnGroup:TaskCombo({ orbitTask, enrouteTask }, 4)
            spawnGroup:SetTask(combo)
        end
    )
    spawn:SpawnFromVec2(coord:GetVec2(), UTILS.FeetToMeters(5000), UTILS.FeetToMeters(25000))
end
-------------------------------------------------------------------------------

function AirQuakeZoneCounterCAS(attackedZone)
    local zoneName = attackedZone.ZoneName

    env.info(string.format('BTI: Evaluating AirQuake CAS Zone %s RedZonesCounter %d, BlueZonesCounter %d, zoneFightersCounter %d', zoneName, RedZonesCounter, BlueZonesCounter, zoneFightersCounter))

    if casTrack[zoneName] then
        return
    end

    local switch = math.random(1,3)
    local spawn = nil
    if switch == 1 then
        spawn = casEasySpawn
    elseif switch == 2 then
        spawn = casMediumSpawn
    else
        spawn = casHardSpawn
    end

    triggerCAS(spawn, attackedZone:GetCoordinate())
    CommandCenter:MessageTypeToCoalition(string.format("The enemy is sending Close Air Support to defend its attacked zone"), MESSAGE.Type.Information)

end

function AirQuakeZoneAttacked(attackedZone)
    -- local maxFighterCap = RedZonesCounter - BlueZonesCounter
    local maxFighterCap = 19

    local zoneName = attackedZone.ZoneName

    env.info(string.format('BTI: Evaluating AirQuake Zone %s RedZonesCounter %d, BlueZonesCounter %d, zoneFightersCounter %d', zoneName, RedZonesCounter, BlueZonesCounter, zoneFightersCounter))
    if fighterTrack[zoneName] then
        env.info(string.format('BTI: Forbidding air quake for zone %s', zoneName))
        return
    end


    local spawn = nil
    local switch = math.random(1,3)
    -- if RedZonesCounter > BlueZonesCounter then
    if switch == 1 then
        spawn = fighterMediumSpawn
    elseif switch == 2 then
        spawn = fighterEasySpawn
    else
        spawn = fighterHardSpawn
    end

    triggerFighters(spawn, attackedZone:GetCoordinate())
    CommandCenter:MessageTypeToCoalition(string.format("The enemy is sending QRF to defend its zone"), MESSAGE.Type.Information)

    zoneFightersCounter = zoneFightersCounter + 1
    fighterTrack[zoneName] = true
    
end

function AirQuakePermanentTrigger(something)
    local spawn = nil

    local switch = math.random(1,3)
    if switch == 1 then
        spawn = fighterMediumSpawn
    elseif switch == 2 then
        spawn = fighterEasySpawn
    else
        spawn = fighterHardSpawn
    end
    
    triggerFighters(spawn, HQ:GetCoordinate())
    CommandCenter:MessageTypeToCoalition(string.format("The enemy is sending a random patrol"), MESSAGE.Type.Information)

    zoneFightersCounter = zoneFightersCounter + 1
end

function AirQuakePermanentRandomizer(something)
    local timeToRandom = 0
    local switch = math.random(1,4)

    if switch == 1 then
        timeToRandom = 900
    elseif switch == 2 then
        timeToRandom = 1800
    elseif switch == 3 then
        timeToRandom = 2700
    else
        timeToRandom = 3600
    end
    env.info(string.format('BTI: Air Quake time to random %d', timeToRandom))
    CommandCenter:MessageTypeToCoalition(string.format("Rolling dices on enemy patrol CAP"), MESSAGE.Type.Information)
    SCHEDULER:New(nil, AirQuakePermanentTrigger, {"Something"}, timeToRandom)
end

SCHEDULER:New(nil, AirQuakePermanentRandomizer, {"something"}, 60, 3600)
env.info('BTI: Air Quake battle is ready')
