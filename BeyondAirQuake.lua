HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )


--------------------------------------------------------------------
fighterMediumSpawn = SPAWN:New("RED F14")
fighterEasySpawn = SPAWN:New('RED Mig21')


local fighterCounter = 0
local fighterTrack = {}
-- local fighterResources = BeyondPersistedStore['']
--------------------------------------------------------------------

function triggerFighters(spawn, coord)
    spawn:OnSpawnGroup(
        function(spawnGroup)
            env.info(string.format("BTI: Sending fighter group %d to zone ", fighterCounter))
            spawnGroup:TaskRouteToVec2( coord:GetVec2(), UTILS.KnotsToMps(600), "cone" )
            local enrouteTask = spawnGroup:EnRouteTaskEngageTargets( 60000, { "Planes", "Battle airplanes" }, 1 )
            spawnGroup:SetTask(enrouteTask)
        end 
    )

    spawn:Spawn()
end

function AirQuakeZoneAttacked(attackedZone)
    local maxFighterCap = RedZonesCounter - BlueZonesCounter
    local zoneName = attackedZone.ZoneName

    env.info('BTI: Evaluating AirQuake')
    if fighterTrack[zoneName] then
        env.info(string.format('BTI: Forbidding air quake for zone %s', zoneName))
        return
    end

    if fighterCounter < maxFighterCap then
        local spawn = nil
        if RedZonesCounter > BlueZonesCounter then
            spawn = fighterMediumSpawn
        else
            spawn = fighterEasySpawn
        end

        triggerFighters(spawn, attackedZone:GetCoordinate())

        fighterCounter = fighterCounter + 1
        fighterTrack[zoneName] = true
    else
        env.info()
    end
end
