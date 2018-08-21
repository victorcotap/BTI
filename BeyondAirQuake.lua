HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )


--------------------------------------------------------------------
local fighterMediumSpawn = SPAWN:New("RED F14")
local fighterHardSpawn = SPAWN:New('RED J11')


local fighterCounter = 0
-- local fighterResources = BeyondPersistedStore['']
--------------------------------------------------------------------

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

        spawn:OnSpawnGroup(
            function(spawnGroup)
                env.info(string.format("BTI: Sending fighter group %d to zone ", fighterCounter))
                spawnGroup:TaskRouteToZone( attackedZone, false, UTILS.KnotsToMps(400), "vee" )
                local enrouteTask = spawnGroup:EnRouteTaskEngageTargets( 50000, { "Planes", "Battle airplanes" }, 1 )
                spawnGroup:SetTask(enrouteTask)
            end 
        )

        spawn:Spawn()
        fighterCounter = fighterCounter + 1
    else
        env.info()
    end
end
