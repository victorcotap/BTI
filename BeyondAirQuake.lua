HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )


--------------------------------------------------------------------
fighterMediumSpawn = SPAWN:New("RED F14")
fighterHardSpawn = SPAWN:New('RED J11')


local fighterCounter = 0
-- local fighterResources = BeyondPersistedStore['']
--------------------------------------------------------------------

function triggerFighters(spawn, coord)
    spawn:OnSpawnGroup(
        function(spawnGroup)
            env.info(string.format("BTI: Sending fighter group %d to zone ", fighterCounter))
            spawnGroup:TaskRouteToVec2( coord:GetVec2(), UTILS.KnotsToMps(600), "cone" )
            local enrouteTask = spawnGroup:EnRouteTaskEngageTargets( 50000, { "Planes", "Battle airplanes" }, 1 )
            spawnGroup:SetTask(enrouteTask)
        end 
    )

    spawn:Spawn()
end

function AirQuakeZoneAttacked(attackedZone)
    local maxFighterCap = RedZonesCounter - BlueZonesCounter
    env.info('BTI: Evaluating AirQuake')
    if fighterCounter < maxFighterCap then
        local spawn = nil
        if RedZonesCounter > BlueZonesCounter then
            spawn = fighterMediumSpawn
        else
            spawn = fighterHardSpawn
        end

        triggerFighters(spawn, attackedZone:GetCoordinate())

        fighterCounter = fighterCounter + 1
    else
        env.info()
    end
end
