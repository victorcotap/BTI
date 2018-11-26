
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
groundSideArmorSpawn = SPAWN:New('RED G Armor Defense')
groundSideArtySpawn = SPAWN:New('RED G Arty Defense')
groundSideSAMSpawn = SPAWN:New('RED G SAM Defense')
groundSideInfantrySpawn = SPAWN:New('RED G Infantry Defense')
groundSidePatrolDefenseSpawn = SPAWN:New('RED G Patrol Defense')

local groundSideRandomSpawns = {groundSideArmorSpawn, groundSideArtySpawn, groundSideInfantrySpawn, groundSideSAMSpawn}
local zoneFightersCounter = 0
local zoneGroundCounter = 0

-- Global ----------------------------------------------------------
FighterTrack = {}
CASTrack = {}
GroundTrack = {}
QUAKEZonesAO = "Zones"
QUAKEHeloConvoys = "HeloConvoys"
QUAKEFighters = "Air"
QUAKECAS = "CAS"
QUAKE = {
    [QUAKEZonesAO] = {},
    [QUAKEHeloConvoys] = {},
    [QUAKEFighters] = {},
    [QUAKECAS] = {},
}

-- Global sanitizer -------------------------------------------------
---------------------------------------------------------------------
function QuakeEngine(something)
    env.info("BTI: Sanitizing the universe")
    -- Convoys
    local convoys = QUAKE[QUAKEHeloConvoys]
    for i = 1, #convoys do
        local supply = convoys[i]["Supply"]
        local escort = convoys[i]["Escort"]
        if supply:IsAlive() and supply:AllOnGround() then
            supply:Destroy()
            escort:Destroy()
            table.remove(convoys, i)
        end
    end

    local CASGroups = QUAKE[QUAKECAS]
    for i = 1, #CASGroups do
        local CASGroup = CASGroups[i]["CASGroup"]
        if CASGroup:IsAlive() == false then
            table.remove(CASGroups, i)
        end
    end
    local FightersGroups = QUAKE[QUAKEFighters]
    for i = 1, #FightersGroups do
        local fightersGroup = FightersGroups[i]["FightersGroup"]
        if fightersGroup:IsAlive() == false or fightersGroup:InAir() == false then
            table.remove(FightersGroups, i)
        end
    end

    for zoneName, zoneAO in pairs(QUAKE[QUAKEZonesAO]) do
        local ZonesSideMissions = zoneAO["SideMissions"]
        for i = 1, #ZonesSideMissions do
            local group = ZonesSideMissions[i]["Group"]
            local finished = ZonesSideMissions[i]["Finished"]
            
            -- env.info(string.format("BTI: %s sideMission after marker refresh alive %s %s",zoneName, tostring(group:IsAlive()), UTILS.OneLineSerialize(ZonesSideMissions[i])))
            if group:IsAlive() == nil and finished == false then
                env.info(string.format( "BTI: Should remove one side mission for %s", zoneName))
                ZonesSideMissions[i]["Finished"] = true
                local sideMissionsLeft = PERSISTENCERemoveSideMission(zoneName)
                if sideMissionsLeft == 0 then
                    SUPPORTSpawnSFAC(ZONE:FindByName(zoneName))
                end
                CommandCenter:MessageTypeToCoalition( string.format("Congratulations, you have successfully cleared side mission %s-%d. Progress will be persisted!", zoneName, i), MESSAGE.Type.Information )
                trigger.action.removeMark(ZonesSideMissions[i]["Mark"])
            elseif group:IsAlive() == true and finished == false then
                QuakeZoneSideMissionMarkerRefresh(zoneName, ZonesSideMissions[i])
            end
        end
        local zoneConvoyGroup = zoneAO["Convoy"]["Group"]
        if zoneConvoyGroup ~= nil and zoneConvoyGroup:IsAlive() == false then
            zoneAO["Convoy"]["Finished"] = true
        end
    end
end

-- Trigger ----------------------------------------------------------
---------------------------------------------------------------------
function triggerFighters(spawn, coord)
    spawn:OnSpawnGroup(
        function(spawnGroup)
            spawnGroup:ClearTasks()
            env.info(string.format("BTI: Sending fighter group %d to zone ", zoneFightersCounter))
            local enrouteTask = spawnGroup:EnRouteTaskEngageTargets( 70000, { "Air" }, 1 )
            spawnGroup:SetTask(enrouteTask, 2)
            local orbitTask = spawnGroup:TaskOrbitCircleAtVec2( coord:GetVec2(), UTILS.FeetToMeters(22000), UTILS.KnotsToMps(350))
            spawnGroup:PushTask(orbitTask, 4)
        end 
    )
    local fighterGroup = spawn:Spawn()
    return fighterGroup
end

function triggerCAS(spawn, coord)
    spawn:OnSpawnGroup(
        function(spawnGroup)
            env.info(string.format("BTI: Sending cas group to zone "))
            spawnGroup:ClearTasks()
            local casTask = spawnGroup:EnRouteTaskEngageTargets( 20000, { "All" }, 1 )
            spawnGroup:SetTask(casTask, 2)
            local orbitTask = spawnGroup:TaskOrbitCircleAtVec2( coord:GetVec2(), UTILS.FeetToMeters(8000), UTILS.KnotsToMps(270))
            spawnGroup:PushTask(orbitTask, 4)
        end
    )
    local casGroup = spawn:Spawn()
    return casGroup
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
            -- ^ very costly
        end
    )

    local groundSpawn = spawn:SpawnFromVec2(newCoord:GetVec2())
    return groundSpawn
end

function triggerGroundZoneSideMissionPatrol(spawn, fromCoord, toCoord, r) --r = repeat
    env.info("BTI: Deploying Side Mission Convoy for zone ")

    spawn:OnSpawnGroup(
        function ( spawnGroup )
            spawnGroup:ClearTasks()
            env.info(string.format("BTI: Routing Ground Side Mission Convoy"))
            -- local routeTask = spawnGroup:TaskRouteToVec2(coord:GetVec2(), UTILS.KnotsToMps(50))
            -- spawnGroup:SetTask(routeTask, 15);
            spawnGroup:RouteGroundTo( toCoord, UTILS.KnotsToMps(50), Formation, DelaySeconds )
            -- ^ very costly
        end
    )

    local groundSpawn = spawn:SpawnFromVec2(fromCoord:GetVec2())
    return groundSpawn
end

-----------------------------------------------------------------------------------------------------
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
    local escortGroup = spawnEscort:SpawnFromVec2(startCoord:GetVec2())

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

    return supplyGroup, escortGroup
end

------------------------------------------------------------------------------------------------------
local function triggerGroundZoneSideMission(coord, spawn)
    local randomSpawnCoord = coord:GetRandomVec2InRadius( 17000, 12000 )
    local spawnGroup = spawn:SpawnFromVec2(randomSpawnCoord)
    return spawnGroup
end

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
function AirQuakeZoneCounterCAS(attackedZone)
    local zoneName = attackedZone.ZoneName

    env.info(string.format('BTI: Evaluating AirQuake CAS Zone %s RedZonesCounter %d, BlueZonesCounter %d, zoneFightersCounter %d', zoneName, RedZonesCounter, BlueZonesCounter, zoneFightersCounter))

    if CASTrack[zoneName] then
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

    local CASGroup = triggerCAS(spawn, attackedZone:GetCoordinate())
    local cas = QUAKE[QUAKECAS]
    cas[#cas] = {
        ["Zone"] = zoneName,
        ["CASGroup"] = CASGroup
    }
    CASTrack[zoneName] = true
    CommandCenter:MessageTypeToCoalition(string.format("The enemy is sending Close Air Support to defend its attacked zone"), MESSAGE.Type.Information)

end

function AirQuakeZoneAttacked(attackedZone)
    -- local maxFighterCap = RedZonesCounter - BlueZonesCounter
    local maxFighterCap = 19

    local zoneName = attackedZone.ZoneName

    env.info(string.format('BTI: Evaluating AirQuake Zone %s RedZonesCounter %d, BlueZonesCounter %d, zoneFightersCounter %d', zoneName, RedZonesCounter, BlueZonesCounter, zoneFightersCounter))
    if FighterTrack[zoneName] then
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

    local fighterGroup = triggerFighters(spawn, attackedZone:GetCoordinate())
    local figthersGroups = QUAKE[QUAKEFighters]
    figthersGroups[#figthersGroups] = {
        ["Zone"] = zoneName,
        ["FightersGroup"] = fighterGroup
    }
    CommandCenter:MessageTypeToCoalition(string.format("The enemy is sending QRF to defend its zone"), MESSAGE.Type.Information)

    zoneFightersCounter = zoneFightersCounter + 1
    FighterTrack[zoneName] = true
    
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
----------------------------------------------------------------------------------------
function GroundQuakeZoneCaptured(attackedZone)
    local zoneName = attackedZone.ZoneName

    env.info(string.format('BTI: Evaluating GroundQuake Zone %s zoneGroundCounter %d', zoneName, zoneGroundCounter))

    if GroundTrack[zoneName] then
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
    GroundTrack[zoneName] = true
end

-- Helo Convoys --------------------------------------------------------------------------
function GroundQuakeSupplyTrigger(something)
    env.info(string.format("BTI: Ground Quake Supply picker count name %d", #SelectedZonesCoalition))
    env.info(string.format("BTI: SelectedZonesCoalition %s", UTILS.OneLineSerialize(SelectedZonesCoalition)))

    local fromZoneCoalition = nil
    for i = 1, 5 do
        local fromZoneSwitch = math.random(1, #SelectedZonesCoalition)
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
    local supply, escort = triggerHeloSAMSupply(fromCoord, toCoord)
    
    local convoys = QUAKE[QUAKEHeloConvoys]
    convoys[#convoys + 1] = {
        ["From"] = fromZoneCoalition:GetZoneName(),
        ["To"] = toZoneCoalition:GetZoneName(),
        ["Timer"] = os.time(),
        ["Supply"] = supply,
        ["Escort"] = escort
    }
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
-- SCHEDULER:New(nil, GroundQuakeSupplyTrigger, {"Something"}, 100)


--Zone Side Mission ---------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

local function QuakeZoneRandomSideMissionPatrol(zoneAO, zoneSideMissions)
    local fromConvoySwitch = math.random(1, #zoneSideMissions)
    local fromCoord = zoneSideMissions[fromConvoySwitch]["Group"]:GetCoordinate()

    for i = 1, 4 do
        local toConvoySwitch = math.random(1, #zoneSideMissions)
        env.info(string.format("BTI: coonvoy selected selected zone side mission %s for %d", toConvoySwitch, fromConvoySwitch))
        if fromConvoySwitch == toConvoySwitch then
            env.info(string.format("BTI: Found the same destination as start, ignoring "))
        else
            local toCoord = zoneSideMissions[toConvoySwitch]["Group"]:GetCoordinate()
            local convoyGroup = triggerGroundZoneSideMissionPatrol(groundSidePatrolDefenseSpawn, fromCoord, toCoord, true) --repeat
            zoneAO["Convoy"] = {
                ["Group"] = convoyGroup,
                ["Finished"] = false
            }
            break
        end
    end

    return zoneSideMissions
end

function QuakeZoneSideMissionMarkerRefresh(zoneName, zoneSideMission)
    local previousMarkId = zoneSideMission["Mark"]
    local coord = zoneSideMission["Group"]:GetCoordinate()
    local index = tostring(zoneSideMission["Index"])
    if previousMarkId ~= nil then
        coord:RemoveMark(previousMarkId)
    end

    local newMarkId = coord:MarkToCoalitionBlue(("Mission " .. zoneName .. " " .. tostring(index)))
    zoneSideMission["Mark"] = newMarkId
    return newMarkId
end

function QUAKEZoneAOCreate(zonePersisted, zoneName)
    QUAKE[QUAKEZonesAO][zoneName] = {
        ["SideMissionsCount"] = zonePersisted["SideMissions"],
        ["SideMissions"] = {},
        ["Convoy"] = {}
    }
end

function QUAKEZoneSideRandomMissions(zoneName)
    local zone = ZONE:New(zoneName)
    local coord = zone:GetCoordinate()
    local zoneAO = QUAKE[QUAKEZonesAO][zoneName]
    local zoneSideMissions = {}
    
    env.info(string.format( "BTI: Generating %d side missions for %s",zoneAO["SideMissionsCount"], zoneName))
    for i = 1, zoneAO["SideMissionsCount"] do
        local switch = math.random( 1, #groundSideRandomSpawns)
        local spawn = groundSideRandomSpawns[switch]
        local sideMissionGroup = triggerGroundZoneSideMission(coord, spawn)
        zoneSideMissions[#zoneSideMissions + 1] = {
            ["Type"] = switch,
            ["Group"] = sideMissionGroup,
            ["Finished"] = false,
            ["Index"] = i
        }
    end
    
    if #zoneSideMissions > 0 then
        zoneSideMissions = QuakeZoneRandomSideMissionPatrol(zoneAO, zoneSideMissions)
    else
        SUPPORTSpawnSFAC(ZONE:FindByName(zoneName))
    end

    zoneAO["SideMissions"] = zoneSideMissions
end

--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
SCHEDULER:New(nil, QuakeEngine, {"something"}, 30, 90)
