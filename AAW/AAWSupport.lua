HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )

SupportHandler = EVENTHANDLER:New()

local SpawnsTableConcurrent = {}
local ZeusWaypointData = {}
local ZeusTaskData = {}
local ZeusSpawnedAssets = {}


--Utils----------------------------------------------------------------------------
function _split(str, sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
        table.insert(result, each)
    end

    return result
end

local function ternary ( cond , T , F )
    if cond then return T else return F end
end


-- Spawns -----------------------------------------------------------------------
-- jtacName = 'BLUE Request jtac'

-- artySpawn = SPAWN:New('BLUE Support arty')
-- tankSpawn = SPAWN:New('BLUE Support tank')
-- servicesSpawn = SPAWN:New('BLUE Support services')
-- apcSpawn = SPAWN:New('BLUE Support apc')
-- samSpawn = SPAWN:New('BLUE Support sam')
-- infantrySpawn = SPAWN:New('BLUE Support infantry')
-- transportSpawn = SPAWN:New('BLUE Support transport')
-- jtacSpawn = SPAWN:NewWithAlias('BLUE Support jtac', jtacName)
-- sfacSpawn = SPAWN:NewWithAlias('BLUE FAC SFAC', 'BLUE FAC SFAC')
-- GFAC = nil
-- AFAC = nil
-- JFAC = nil
-- function spawnRecon(something)
--     if AFAC ~= nil and AFAC:IsAlive() and AFAC:InAir() then
--         env.info("BTI: Forbidding AFAC spawn because alive and well")
--     else
--         AFAC = SPAWN:New('BLUE FAC AFAC'):Spawn()
--     end

--     if JFAC ~= nil and JFAC:IsAlive() and JFAC:InAir() then
--         env.info("BTI: Forbidding AFAC spawn because alive and well")
--     else
--         JFAC = SPAWN:New('BLUE FAC JFAC'):Spawn()
--     end
--     ctld.JTACAutoLase(JFAC:GetName(), 1688, true,"all", 4)
--     ctld.JTACAutoLase(AFAC:GetName(), 1687, true,"all", 3)
-- end
-- SCHEDULER:New(nil, supportServicesRespawnHelp, {"dfsf"}, 5300, 6000)
-- SCHEDULER:New(nil, spawnRecon, {"dfsdf"}, 12, 6000)


-- KC130Tanker = nil
KC135MPRS = nil
-- S3Tanker = nil
E2EWR = nil
function spawnServices(something)
    env.info('BTI Carrier spawn function activated')
    CommandCenter:MessageTypeToCoalition( string.format("AWACS and Tanker are now respawning. Next respawn in 2 hours"), MESSAGE.Type.Information )
    E2EWR = SPAWN:New('BLUE C EWR E3'):Spawn()
    -- KC130Tanker = SPAWN:New('BLUE REFUK KC130'):Spawn()
    KC135MPRS = SPAWN:New('BLUE C REFUK 135'):Spawn()
    KC135Boom = SPAWN:New('BLUE C REFUS 135'):Spawn()
    -- S3Tanker = SPAWN:New('BLUE C REFUK KC130 Navy'):Spawn()
end

SCHEDULER:New(nil, spawnServices, {"sdfsdfd"}, 15, 7200)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function SUPPORTWipeSpawnedAssets()
    for i = 1, #ZeusSpawnedAssets do
        local spawnedGroup = ZeusSpawnedAssets[i]
        spawnedGroup:Destroy(false)
        ZeusSpawnedAssets[i] = nil
    end
end

function SUPPORTWipeLastAsset()
    local spawnedGroup = ZeusSpawnedAssets[#ZeusSpawnedAssets]
    spawnedGroup:Destroy(false)
    ZeusSpawnedAssets[#ZeusSpawnedAssets] = nil
end

function SUPPORTResetTankerAWACSTask()
    local awacsTask = E2EWR:EnRouteTaskAWACS()
    local awacsEPLRS = E2EWR:TaskEPLRS(true)
    local awacsRouteTask = E2EWR:TaskOrbitCircleAtVec2(E2EWR:GetUnit(1):GetCoordinate(), E2EWR:GetUnit(1):GetAltitude(), UTILS.KnotsToMps(307))
    E2EWR:SetTask(awacsTask, 2)
    E2EWR:PushTask(awacsEPLRS)
    E2EWR:PushTask(awacsRouteTask, 4)

    local tanker135MPRSTask = KC135MPRS:EnRouteTaskTanker()
    local tankerRouteTask = tanker:TaskOrbitCircleAtVec2(KC135MPRS:GetUnit(1):GetCoordinate(), KC135MPRS:GetUnit(1):GetAltitude(), UTILS.KnotsToMps(307))
    KC135MPRS:SetTask(tankerRouteTask, 2)
    KC135MPRS:PushTask(tanker135MPRSTask, 2)

    local tanker135BoomTask = KC130Tanker:EnRouteTaskTanker()
    local tankerRouteTask = tanker:TaskOrbitCircleAtVec2(KC130Tanker:GetUnit(1):GetCoordinate(), KC130Tanker:GetUnit(1):GetAltitude(), UTILS.KnotsToMps(307))
    KC130Tanker:SetTask(tankerRouteTask, 2)
    KC130Tanker:PushTask(tanker135BoomTask, 2)
end

function SUPPORTSpawnSFAC(zone)
    sfacSpawn:OnSpawnGroup(
        function(jtacSpawnGroup)
            jtacSpawnGroup:ClearTasks()
            local routeTask = jtacSpawnGroup:TaskOrbitCircleAtVec2( zone:GetCoordinate():GetVec2(), UTILS.FeetToMeters(10000),  UTILS.KnotsToMps(110) )
            jtacSpawnGroup:SetTask(routeTask, 2)
            env.info(string.format( "BTI: Trying to create autolase jtac for %s",jtacSpawnGroup:GetName()))
            ctld.JTACAutoLase(jtacSpawnGroup:GetName(), 1685, false, "all")
        end
    )

    local randomSpawnCoord = zone:GetCoordinate():GetRandomVec2InRadius( 2000, 4500 )
    local supportGroup = sfacSpawn:SpawnFromVec2(randomSpawnCoord)
    CommandCenter:MessageTypeToCoalition( string.format("%s Airborn JTAC now deployed after Side Missions have been completed", supportGroup:GetName()), MESSAGE.Type.Information )
end

--------------------------------------------------------------------------------
local destroyZoneCount = 0
function handleExfillRequest(text, baseCoord)

    local destroyZoneName = string.format("destroy %d", destroyZoneCount)
    local zoneRadiusToDestroy = ZONE_RADIUS:New(destroyZoneName, baseCoord:GetVec2(), 80)
    destroyZoneCount = destroyZoneCount + 1
    local function destroyUnit(zoneUnit)
        env.info(string.format("BTI: Found unit in zone %s", destroyZoneName))
        env.info(string.format("BTI: Salvaging command received, executing"))
        zoneUnit:Destroy()
        return true
    end
    zoneRadiusToDestroy:SearchZone(destroyUnit, Object.Category.UNIT)
    CommandCenter:MessageTypeToCoalition( string.format("Exfill complete!"), MESSAGE.Type.Information )
end

function handleSupportRequest(text, coord)

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
-- -z f13;-altitude 12000;-waypoint something
-- -z f13;-altitude 12000;-task cap
-- -z t90;-amount 5
-- -z t89

function handleZeusRequest(text, baseCoord)

    local arguments = _split(text, ";")
    env.info("BTI: arguments " .. UTILS.OneLineSerialize(arguments))

    -- parse the command string
    local spawnString = ""
    local spawnAmount = 1
    local spawnAltitude = 3000
    local spawnTask = ""
    local spawnCluster = ""
    for _,argument in pairs(arguments) do
        local argumentValues = _split(argument, " ")
        env.info("BTI: argumentValue " .. UTILS.OneLineSerialize(arguments))
        local command = argumentValues[1]
        local value = argumentValues[2]

        if command:find("-z") then
            spawnString = value
        elseif command:find("-amount") or command:find("-n")  then
            spawnAmount = tonumber(value)
        elseif command:find("-altitude") or command:find("-a") then
            spawnAltitude = UTILS.FeetToMeters(tonumber(value))
        elseif command:find("-task") or command:find("-t") then
            spawnTask = value
        elseif command:find("-cluster") then
            spawnCluster = value
        end
    end

    -- fetch spawn from table
    local spawnData = ZeusTable[spawnString]
    if (spawnData == nil) then
        env.info("BTI: Couldn't find group in Zeus Data, bailing out")
        return
    end
    local spawnSecondaryData = ZeusWaypointData[spawnString]
    local spawnTaskingData = ZeusTaskData[spawnString]
    local spawnType = spawnData["type"]

    -- prepare asset spawn
    local spawn = SpawnsTableConcurrent[spawnString]
    if spawn == nil then
        local newSpawn = SPAWN:New(spawnString)
        SpawnsTableConcurrent[spawnString] = newSpawn
        spawn = newSpawn
    end

    -- task spawned asset
    spawn:OnSpawnGroup(
        function(spawnedGroup)
            if spawnType == "air" then
                if spawnTaskingData ~= nil then
                    env.info("BTI: SpawnTaskingData " .. UTILS.OneLineSerialize(spawnTaskingData))
                    local engageTargets = ternary(spawnTaskingData["engage"] == "a", { "Air" }, { "Planes", "Battle airplanes", })
                    local enrouteEngageZoneTask = spawnedGroup:EnRouteTaskEngageTargetsInZone(
                        spawnTaskingData["coord"]:GetVec2(),
                        spawnTaskingData["radius"],
                        engageTargets,
                        1
                    )
                    trigger.action.removeMark(spawnTaskingData["mark"])
                    spawnedGroup:SetTask(enrouteEngageZoneTask, 2)
                elseif spawnTask == "cap" then
                    local enrouteTask = spawnedGroup:EnRouteTaskEngageTargets( 70000, { "Air" }, 1 )
                    spawnedGroup:SetTask(enrouteTask, 2)
                elseif spawnTask == "jtac" then
                    ctld.JTACAutoLase(spawnedGroup:GetName(), 1686, true, "all", 2)
                elseif spawnTask == "tanker" then
                    local tankerTask = spawnedGroup:EnRouteTaskTanker()
                    spawnedGroup:SetTask(tankerTask)
                end


                local finalCoord = baseCoord
                local finalAltitude = spawnAltitude
                local finalSpeed = UTILS.KnotsToMps(350)
                if spawnSecondaryData ~= nil then
                    finalCoord = spawnSecondaryData["coord"]
                    finalAltitude = spawnSecondaryData["altitude"]
                    finalSpeed = spawnSecondaryData["speed"]
                    trigger.action.removeMark(spawnSecondaryData["mark"])
                end
                local orbitTask = spawnedGroup:TaskOrbitCircleAtVec2( finalCoord:GetVec2(), finalAltitude, finalSpeed)
                spawnedGroup:PushTask(orbitTask, 4)

            elseif spawnType == "ground" then
                -- route so they get in formation and start their AI
                if spawnTask == "jtac" then
                    ctld.JTACAutoLase(spawnedGroup:GetName(), 1686, true, "all", 2)
                elseif spawnTask == "arty" then
                    local arty = ARTY:New(GROUP:FindByName(spawnedGroup:GetName()))
                    arty:SetMarkAssignmentsOn()
                    arty:SetIlluminationShells(100, 2)
                    arty:SetSmokeShells(100)
                    arty:SetTacNukeShells(100, 0.1)
                    if spawnCluster ~= nil then
                        arty:AddToCluster(spawnCluster)
                    end
                    arty:Start()
                end
                spawnedGroup:RouteToVec2(baseCoord:GetRandomVec2InRadius( 20, 5 ), 5)
            end
            table.insert( ZeusSpawnedAssets, spawnedGroup )
        end
    )

    -- Spawn asset
    env.info("BTI: spawn coord" .. UTILS.OneLineSerialize(baseCoord:GetRandomVec2InRadius(100, 300)))
    for i = 1, spawnAmount do
        spawn:SpawnFromVec2(baseCoord:GetRandomVec2InRadius( 100, 300 ), spawnAltitude, spawnAltitude)
    end

    -- Remove Zeus Data and mark for secondary
    ZeusWaypointData[spawnString] = nil
    ZeusTaskData[spawnString] = nil
    if text:find("-x") then
        CommandCenter:MessageToAll( string.format("Requested asset %s times %d spawned", spawnString, spawnAmount))
        -- CommandCenter:MessageTypeToCoalition( string.format("Requested asset %s times %d spawned", spawnString, spawnAmount), MESSAGE.Type.Information )
        -- CommandCenter:MessageTypeToCoalition( string.format("Requested asset something times %d spawned", spawnAmount), MESSAGE.Type.Information )
    end
end


function handleSecondaryRequest(arguments, baseCoord, markID)
    local spawnID = ""
    local waypointAltitude = UTILS.FeetToMeters(10000)
    local zoneRadius = UTILS.NMToMeters(10)
    local waypointSpeed = UTILS.KnotsToMps(350)
    local engageTarget = "a"
    local type = ""
    env.info("BTI: stop0 " .. UTILS.OneLineSerialize(arguments))

    for _,argument in pairs(arguments) do
        local argumentValues = _split(argument, " ")
        local command = argumentValues[1]
        local value = argumentValues[2]

        env.info("BTI: stop1 " .. UTILS.OneLineSerialize(argumentValues))
        if command:find("-waypoint") or command:find("-engageZone") then
            spawnID = value
            env.info("BTI: stop1.5")
            if command:find("-waypoint") then
                type = "waypoint"
            elseif command:find("-engageZone") then
                type = "engageZone"
            end
        elseif command:find("-altitude") or command:find("-a") then
            waypointAltitude = UTILS.FeetToMeters(tonumber(value))
        elseif command:find("-radius") or command:find("-r") then
            zoneRadius = UTILS.NMToMeters(tonumber(value))
        elseif command:find("-speed") or command:find("-s") then
            waypointSpeed = UTILS.KnotsToMps(tonumber(value))
        elseif command:find("-targets") or command:find("-t") then
            engageTarget = value
        end
    end

    env.info("BTI: stop2")
    if type:find("waypoint") then
        ZeusWaypointData[spawnID] = {
            ["coord"] = baseCoord,
            ["altitude"] = waypointAltitude,
            ["speed"] = waypointSpeed,
            ["mark"] = markID
        }
        env.info("BTI: SpawnWaypointData " .. UTILS.OneLineSerialize(ZeusWaypointData[spawnID]))
    elseif type:find("engageZone") then
        ZeusTaskData[spawnID] = {
            ["coord"] = baseCoord,
            ["radius"] = zoneRadius,
            ["engage"] = engageTarget,
            ["mark"] = markID
        }
        env.info("BTI: SpawnTaskingData " .. UTILS.OneLineSerialize(ZeusTaskData[spawnID]))
    end
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function handleCommandRequest(text, baseCoord)
    if text:find("awacs") then
        E2EWR = SPAWN:New('BLUE C EWR E2'):Spawn()
    elseif text:find("smoke") then
        if text:find("green") then
            baseCoord:SmokeGreen()
        elseif text:find("orange") then
            baseCoord:SmokeOrange()
        elseif text:find("blue") then
            baseCoord:SmokeBlue()
        elseif text:find("red") then
            baseCoord:SmokeRed()
        else
            baseCoord:SmokeWhite()
        end
    elseif text:find("flare") then
        if text:find("green") then
            for i=10,1,-1 do baseCoord:FlareGreen() end
        elseif text:find("yellow") then
            for i=10,1,-1 do baseCoord:FlareYellow() end
        elseif text:find("red") then
            for i=10,1,-1 do baseCoord:FlareRed() end
        else
            for i=10,1,-1 do baseCoord:FlareWhite() end
        end
    end
end

function handleDebugRequest(text, baseCoord)
    if text:find("fire") then
        if text:find("big") then
            baseCoord:BigSmokeAndFireLarge()
        elseif text:find("medium") then
            baseCoord:BigSmokeAndFireMedium()
        elseif text:find("inferno") then
            baseCoord:BigSmokeAndFireHuge(1)
        else
            baseCoord:BigSmokeAndFireSmall()
        end
    end
end

local function handleWeatherRequest(text, baseCoord)
    local currentPressure = baseCoord:GetPressure(0)
    local currentTemperature = baseCoord:GetTemperature()
    local currentWindDirection, currentWindStrengh = baseCoord:GetWind()
    local weatherString = string.format("Requested weather: Wind from %d@%.1fkts, QNH %.2f, Temperature %d", currentWindDirection, UTILS.MpsToKnots(currentWindStrengh), currentPressure * 0.0295299830714, currentTemperature)
    CommandCenter:MessageTypeToCoalition(weatherString, MESSAGE.Type.Information)
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
function markRemoved(Event)
    if Event.text~=nil and Event.text:lower():find("-") then
        -- local text = Event.text:lower()
        local text = Event.text
        local vec3 = {y=Event.pos.y, x=Event.pos.x, z=Event.pos.z}
        local baseCoord = COORDINATE:NewFromVec3(vec3)
        baseCoord.y = baseCoord:GetLandHeight()

        if text:find("-fac") then
            handleFACRequest(text, baseCoord)
        elseif text:find("-tanker") then
            handleTankerRequest(text, baseCoord)
        elseif text:find("-support") then
            handleSupportRequest(text, baseCoord)
        elseif text:find("-destroyy") then
            handleExfillRequest(text, baseCoord)
        elseif text:find("-command") then
            handleCommandRequest(text, baseCoord)
        elseif text:find("-debug") then
            handleDebugRequest(text, baseCoord)
        elseif text:find("-weather") then
            handleWeatherRequest(text, baseCoord)
        elseif text:find("-z") then
            handleZeusRequest(text, baseCoord)
        end
    end
end

function markChanged(Event)
    if Event.text~=nil and Event.text:lower():find("-") then
        -- local text = Event.text:lower()
        local text = Event.text
        -- local vec3 = {y=Event.pos.y, x=Event.pos.z, z=Event.pos.x} --old
        local vec3 = {y=Event.pos.y, x=Event.pos.x, z=Event.pos.z} --new

        local baseCoord = COORDINATE:NewFromVec3(vec3)
        baseCoord.y = baseCoord:GetLandHeight()

        local arguments = _split(text, ";")
        handleSecondaryRequest(arguments, baseCoord, Event.idx)
    end
end

function SupportHandler:onEvent(Event)
    if Event.id == world.event.S_EVENT_MARK_ADDED then
        env.info(string.format("BTI: Support got event ADDED id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
    elseif Event.id == world.event.S_EVENT_MARK_CHANGE then
        env.info(string.format("BTI: Support got event CHANGE id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
        markChanged(Event)
    elseif Event.id == world.event.S_EVENT_MARK_REMOVED then
        env.info(string.format("BTI: Support got event REMOVED id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
        markRemoved(Event)
    end
end

world.addEventHandler(SupportHandler)

env.info('BTI: Beyond Support is online')
