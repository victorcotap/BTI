HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )


--------------------------------------------------------------------
fighterHardSpawn = SPAWN:New("RED J11")
fighterMediumSpawn = SPAWN:New("RED F14")
fighterEasySpawn = SPAWN:New('RED Mig21')



local zoneFightersCounter = 0
local fighterTrack = {}
-- local fighterResources = BeyondPersistedStore['']
--------------------------------------------------------------------

function triggerFighters(spawn, coord)
    spawn:OnSpawnGroup(
        function(spawnGroup)
            env.info(string.format("BTI: Sending fighter group %d to zone ", zoneFightersCounter))
            local routeTask = spawnGroup:TaskRouteToVec2( coord:GetVec2(), UTILS.KnotsToMps(600), "cone" )
            spawnGroup:SetTask(routeTask)
            local enrouteTask = spawnGroup:EnRouteTaskEngageTargets( 60000, { "Planes", "Battle airplanes" }, 1 )
            spawnGroup:PushTask(enrouteTask)
        end 
    )

    spawn:Spawn()
end

function deployFighters(spawn, coord)
    spawn:OnSpawnGroup(
        function(spawnGroup)
            env.info(string.format("BTI: Deploying fighters at requested zone"))
            local orbitTask = spawnGroup:TaskOrbitCircleAtVec2( coord:GetVec2(), UTILS.FeetToMeters(18000) , UTILS.KnotsToMps(400))
            spawnGroup:SetTask(orbitTask)
            local enrouteTask = spawnGroup:EnRouteTaskEngageTargets( 60000, { "Planes", "Battle airplanes" }, 1 )
            spawnGroup:PushTask(enrouteTask)
        end
    )

    spawn:SpawnFromVec2(coord:GetVec2(), UTILS.FeetToMeters(5000), UTILS.FeetToMeters(25000))
end
-------------------------------------------------------------------------------

function AirQuakeZoneAttacked(attackedZone)
    -- local maxFighterCap = RedZonesCounter - BlueZonesCounter
    local maxFighterCap = 19

    local zoneName = attackedZone.ZoneName

    env.info(string.format('BTI: Evaluating AirQuake Zone %s RedZonesCounter %d, BlueZonesCounter %d, zoneFightersCounter %d', zoneName, RedZonesCounter, BlueZonesCounter, zoneFightersCounter))
    if fighterTrack[zoneName] then
        env.info(string.format('BTI: Forbidding air quake for zone %s', zoneName))
        return
    end

    if zoneFightersCounter < maxFighterCap then
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

        zoneFightersCounter = zoneFightersCounter + 1
        fighterTrack[zoneName] = true
    else
        env.info('BTI: No furball bozos available')
    end
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
    zoneFightersCounter = zoneFightersCounter + 1
end

function AirQuakePermanentRandomizer(something)
    local timeToRandom = 0
    local switch = math.random(1,3)

    if switch == 1 then
        timeToRandom = 1200
    elseif switch == 2 then
        timeToRandom = 2400
    else
        timeToRandom = 3600
    end
    env.info(string.format('BTI: Air Quake time to random %d', timeToRandom))
    SCHEDULER:New(nil, AirQuakePermanentTrigger, {"Something"}, timeToRandom)
end

SCHEDULER:New(nil, AirQuakePermanentRandomizer, {"something"}, 60, 3600)
env.info('BTI: Air Quake battle is ready')
