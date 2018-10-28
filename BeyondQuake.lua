
HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )


--------------------------------------------------------------------
fighterHardSpawn = SPAWN:New("RED J11")
fighterMediumSpawn = SPAWN:New("RED F14")
fighterEasySpawn = SPAWN:New('RED Mig21')
casHardSpawn = SPAWN:New('RED Su34')
casMediumSpawn = SPAWN:New('RED Su25TM')
casEasySpawn = SPAWN:New('Red Mi28')
groundArmorSpawn = SPAWN:New('RED G Armor')
groundAllAroundSpawn = SPAWN:New('RED G All Around')
groundSAMSupplySpawn = SPAWN:New('RED G Supply SAM')
heloSupplyTransportSpawn = SPAWN:New('RED H Supply Transport')
heloSupplyEscortSpawn = SPAWN:New('RED H Supply Escort')

local zoneFightersCounter = 0
local zoneGroundCounter = 0
local fighterTrack = {}
local casTrack = {}
local groundTrack = {}
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
-----------------------------------------------------------------------------------------------------

function triggerGroundTaskResponse(spawn, coord, distance, angle)
    env.info(string.format("BTI: Deploying Ground Task at requested translate %d angle %d", distance, angle))
    local newCoord = coord:Translate(UTILS.NMToMeters(16), angle)

    spawn:OnSpawnGroup(
        function ( spawnGroup )
            spawnGroup:ClearTasks()
            env.info(string.format("BTI: Deploying Ground Task Armor at requested zone"))
            -- local routeTask = spawnGroup:TaskRouteToVec2(coord:GetVec2(), UTILS.KnotsToMps(50))
            -- spawnGroup:SetTask(routeTask, 15);
            spawnGroup:RouteGroundTo( coord, UTILS.KnotsToMps(50), Formation, DelaySeconds )
        end
    )

    spawn:SpawnFromVec2(newCoord:GetVec2())
end

function triggerHeloSAMSupply(startCoord, endCoord)
    local spawnSupply = heloSupplyTransportSpawn
    local spawnEscort = heloSupplyEscortSpawn
    local distance = startCoord:Get2DDistance(endCoord)
    local travelTime = distance / UTILS.KnotsToMps(107) + 10

    local function taskFunction( spawnGroup )
        spawnGroup:ClearTasks()
        env.info(string.format("BTI: Deploying Helo Supply at requested zone"))
        local task = spawnGroup:TaskLandAtVec2(endCoord:GetVec2(), 60000, true)
        spawnGroup:SetTask(task)
    end

    spawnSupply:OnSpawnGroup(taskFunction)
    local supplyGroup = spawnSupply:SpawnFromVec2(startCoord:GetVec2())

    spawnEscort:OnSpawnGroup(taskFunction)
    spawnEscort:SpawnFromVec2(startCoord:GetVec2())

    local function spawnSAM(something)
        if supplyGroup:IsAlive() then
            local samSpawnCoord = endCoord:GetRandomVec2InRadius( 2000, 500 )
            groundSAMSupplySpawn:SpawnFromVec2(samSpawnCoord)
            CommandCenter:MessageTypeToCoalition( string.format("Enemy successfully delivered resupply convoy, watch out for reinforcements..."), MESSAGE.Type.Information )
        else
            CommandCenter:MessageTypeToCoalition( string.format("You've denied an enemy resupply convoy. Good job!"), MESSAGE.Type.Information )
        end
    end

    SCHEDULER:New(nil, spawnSAM, {"something"}, travelTime)
end

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
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
    local timeToRandomA = 0
    local timeToRandomB = 0
    local switchA = math.random(1,4)
    local switchB = math.random(1,4)

    if switchA == 1 then
        timeToRandomA = 900
    elseif switchA == 2 then
        timeToRandomA = 1800
    elseif switchA == 3 then
        timeToRandomA = 2700
    else
        timeToRandomA = 3600
    end

    if switchB == 1 then
        timeToRandomB = 900
    elseif switchB == 2 then
        timeToRandomB = 1800
    elseif switchB == 3 then
        timeToRandomB = 2700
    else
        timeToRandomB = 3600
    end

    env.info(string.format('BTI: Air Quake time to random A %d', timeToRandomA))
    env.info(string.format('BTI: Air Quake time to random B %d', timeToRandomB))
    CommandCenter:MessageTypeToCoalition(string.format("Rolling dices on enemy patrol CAP..."), MESSAGE.Type.Information)
    SCHEDULER:New(nil, AirQuakePermanentTrigger, {"Something"}, timeToRandomA)
    -- SCHEDULER:New(nil, AirQuakePermanentTrigger, {"Something"}, timeToRandomB)
end

SCHEDULER:New(nil, AirQuakePermanentRandomizer, {"something"}, 60, 3600)
env.info('BTI: Air Quake battle is ready')

----------------------------------------------------------------------------------------

function GroundQuakeZoneCaptured(attackedZone)
    local zoneName = attackedZone.ZoneName

    env.info(string.format('BTI: Evaluating GroundQuake Zone %s zoneGroundCounter %d', zoneName, zoneGroundCounter))

    if groundTrack[zoneName] then
        return
    end

    local spawn = nil
    local angle = math.random(1,360)
    local distance = math.random(10,16)
    local switch = math.random(1,2)

    if switch == 1 then
        spawn = groundAllAroundSpawn
    elseif switch == 2 then
        spawn = groundArmorSpawn
    end

    triggerGroundTaskResponse(spawn, attackedZone:GetCoordinate(), distance, angle)

    zoneGroundCounter = zoneGroundCounter + 1
    groundTrack[zoneName] = true

end

function GroundQuakeSupplyTrigger(something)
    env.info(string.format("BTI: Ground Quake Supply picker count name %d zones %d", #SelectedZonesName, #SelectedZonesCoalition))
    env.info(string.format("BTI: SelectedZonesCoalition %s", UTILS.OneLineSerialize(SelectedZonesCoalition)))

    local fromZoneCoalition = nil
    for i = 1, 5 do
        local fromZoneSwitch = math.random(1, #SelectedZonesName)
        local randomFromZoneCoalition = SelectedZonesCoalition[fromZoneSwitch]
        if randomFromZoneCoalition:GetCoalition() ~= coalition.side.BLUE then
            fromZoneCoalition = randomFromZoneCoalition
        end
    end

    
    local toZoneCoalition = nil

    for i = 1, 5 do
        local toZoneSwitch = math.random(1, #SelectedZonesCoalition)
        local randomToZoneCoalition = SelectedZonesCoalition[toZoneSwitch]
        env.info(string.format("BTI: Supply selected zone coalition %s coalition %d", randomToZoneCoalition:GetZoneName(), randomToZoneCoalition:GetCoalition()))
        if fromZoneCoalition:GetZoneName() == randomToZoneCoalition:GetZoneName() then
            env.info(string.format("BTI: Found the same destination as start, ignoring "))
        elseif fromZoneCoalition:GetCoalition() ~= coalition.side.BLUE then
            toZoneCoalition = randomToZoneCoalition
        end
    end

    local fromZone = fromZoneCoalition:GetZone()
    local fromCoord = COORDINATE:NewFromVec2(fromZone:GetRandomVec2())
    local toZone = toZoneCoalition:GetZone()
    local toCoord = COORDINATE:NewFromVec2(toZone:GetRandomVec2())

    CommandCenter:MessageTypeToCoalition(string.format("Our intel department has somne news!\nThe enemy is sending an airborn resupply convoy\nIt will depart %s and arrive at %s. Intercept !", fromZoneCoalition:GetZoneName(), toZoneCoalition:GetZoneName()), MESSAGE.Type.Information)
    triggerHeloSAMSupply(fromCoord, toCoord)
end

function GroundQuakeSupplyRandomizer(something)
    local timeToRandomA = 0
    local switchA = math.random(1,4)

    if switchA == 1 then
        timeToRandomA = 900
    elseif switchA == 2 then
        timeToRandomA = 1800
    elseif switchA == 3 then
        timeToRandomA = 2700
    else
        timeToRandomA = 3600
    end

    env.info(string.format('BTI: Ground Quake Supply time to random A %d', timeToRandomA))
    SCHEDULER:New(nil, GroundQuakeSupplyTrigger, {"Something"}, timeToRandomA)
end

SCHEDULER:New(nil, GroundQuakeSupplyRandomizer, {"something"}, 120, 3600)

--DEBUG
SCHEDULER:New(nil, GroundQuakeSupplyTrigger, {"Something"}, 120)