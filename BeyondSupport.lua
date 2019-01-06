HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )

SupportHandler = EVENTHANDLER:New()


-----Cooldowns and helpers -------------------------------------------------------
SUPPORT_COOLDOWN = 600
FAC_COOLDOWN = 300
TANKER_COOLDOWN = 1200
EXFILL_COOLDOWN = 1200

supportTimer = 0
facTimer = 0
tankerTimer = 0
exfillTimer = 0

local function supportCooldownHelp(something)
    CommandCenter:MessageTypeToCoalition( string.format("Support asset delivery is now available again. Use the following marker commands:\n-support arty\n-support tank\n-support repair\n-support sam\n-support apc\n-support infantry\n-support jtac"), MESSAGE.Type.Information )
end

local function facCooldownHelp(something)
    CommandCenter:MessageTypeToCoalition( string.format("FAC tasking is now available again. Use the following marker commands:\n-fac afac route\n-fac jfac route"), MESSAGE.Type.Information )
end

local function tankerCooldownHelp(something)
    CommandCenter:MessageTypeToCoalition( string.format("Tanker routing is now available again. Use the following marker commands:\n-tanker s3 route\n-tanker kc130 route\n-tanker kc135 route"), MESSAGE.Type.Information )
end

local function exfillCooldownHelp(something)
    CommandCenter:MessageTypeToCoalition( string.format("Exfill capability is now available again. Use the following marker commands:\n-exfill salvage\n-exfill destroy"), MESSAGE.Type.Information )
end

local function supportServicesRespawnHelp(something)
    CommandCenter:MessageTypeToCoalition( string.format("AFAC drones will respawn in 5 minutes!"), MESSAGE.Type.Information )
end

-- Spawns -----------------------------------------------------------------------
jtacName = 'BLUE Request jtac'

artySpawn = SPAWN:New('BLUE Support arty')
tankSpawn = SPAWN:New('BLUE Support tank')
servicesSpawn = SPAWN:New('BLUE Support services')
apcSpawn = SPAWN:New('BLUE Support apc')
samSpawn = SPAWN:New('BLUE Support sam')
infantrySpawn = SPAWN:New('BLUE Support infantry')
transportSpawn = SPAWN:New('BLUE Support transport')
jtacSpawn = SPAWN:NewWithAlias('BLUE Support jtac', jtacName)
sfacSpawn = SPAWN:NewWithAlias('BLUE FAC SFAC', 'BLUE FAC SFAC')
GFAC = nil
AFAC = nil
JFAC = nil
function spawnRecon(something)
    if AFAC ~= nil and AFAC:IsAlive() and AFAC:InAir() then
        env.info("BTI: Forbidding AFAC spawn because alive and well")
    else
        AFAC = SPAWN:New('BLUE FAC AFAC'):Spawn()
    end

    if JFAC ~= nil and JFAC:IsAlive() and JFAC:InAir() then
        env.info("BTI: Forbidding AFAC spawn because alive and well")
    else
        JFAC = SPAWN:New('BLUE FAC JFAC'):Spawn()
    end
    ctld.JTACAutoLase(JFAC:GetName(), 1688, true,"all", 4)
    ctld.JTACAutoLase(AFAC:GetName(), 1687, true,"all", 3)
end
SCHEDULER:New(nil, supportServicesRespawnHelp, {"dfsf"}, 5300, 6000)
SCHEDULER:New(nil, spawnRecon, {"dfsdf"}, 12, 6000)


KC130Tanker = nil
KC135Tanker = nil
S3Tanker = nil
E2EWR = nil
function spawnServices(something)
    env.info('BTI Carrier spawn function activated')
    CommandCenter:MessageTypeToCoalition( string.format("AWACS and Tanker are now respawning. Next respawn in 2 hours"), MESSAGE.Type.Information )
    E2EWR = SPAWN:New('BLUE C EWR E2'):Spawn()
    KC130Tanker = SPAWN:New('BLUE REFUK KC130'):Spawn()
    KC135Tanker = SPAWN:New('BLUE REFUK KC135'):Spawn()
    S3Tanker = SPAWN:New('BLUE C REFUK KC130 Navy'):Spawn()
end

SCHEDULER:New(nil, spawnServices, {"sdfsdfd"}, 60, 7200)

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

---------------------------------------------------------------------------
function handleFACRequest(text, coord)
    local currentTime = os.time()
    local cooldown = currentTime - facTimer
    if cooldown < FAC_COOLDOWN then
        CommandCenter:MessageTypeToCoalition(string.format("FAC Requests are not available at this time.\nPlayer FAC requests will be available again in %d minutes", (FAC_COOLDOWN - cooldown) / 60), MESSAGE.Type.Information)
        return
    end

    local fac = nil
    local name = nil
    if text:find("afac") then
        fac = AFAC
    elseif text:find("jfac") then
        fac = JFAC
    end

    if text:find("route") then
        fac:ClearTasks()
        local routeTask = fac:TaskOrbitCircleAtVec2( coord:GetVec2(), UTILS.FeetToMeters(10000),  UTILS.KnotsToMps(110) )
        fac:SetTask(routeTask, 2)
        CommandCenter:MessageTypeToCoalition( string.format("%s FAC is re-routed to the requested destination.\n%d minutes cooldown starting now", fac:GetName(), FAC_COOLDOWN / 60), MESSAGE.Type.Information )
        -- local facTask = fac:EnRouteTaskFAC( 10000, 2 )
        -- fac:PushTask(facTask)
        facTimer = currentTime
        SCHEDULER:New(nil, facCooldownHelp, {"sdfsdfd"}, FAC_COOLDOWN)
    end
end

function handleTankerRequest(text, coord)
    local currentTime = os.time()
    local cooldown = currentTime - tankerTimer
    if cooldown < TANKER_COOLDOWN then
        CommandCenter:MessageTypeToCoalition(string.format("Tanker Requests are not available at this time.\nRequests will be available again in %d minutes", (TANKER_COOLDOWN - cooldown) / 60), MESSAGE.Type.Information)
        return
    end

    if text:find("route") then
        local tanker = nil
        local altitude = nil
        local speed = nil
        if text:find("130") then
            tanker = KC130Tanker
            altitude = UTILS.FeetToMeters(12000)
            speed = UTILS.KnotsToMps(290)
        elseif text:find("navy") then
            tanker = S3Tanker
            altitude = UTILS.FeetToMeters(9000)
            speed = UTILS.KnotsToMps(280)
        elseif text:find("135") then
            tanker = KC135Tanker
            altitude = UTILS.FeetToMeters(19000)
            speed = UTILS.KnotsToMps(330)
        end

        tanker:ClearTasks()
        local routeTask = tanker:TaskOrbitCircleAtVec2( coord:GetVec2(), altitude,  speed )
        tanker:SetTask(routeTask, 2)
        local tankerTask = tanker:EnRouteTaskTanker()
        tanker:PushTask(tankerTask, 4)
        CommandCenter:MessageTypeToCoalition( string.format("%s Tanker is re-routed to the player requested destination.\n%d minutes cooldown starting now", tanker:GetName(), TANKER_COOLDOWN / 60), MESSAGE.Type.Information )
        tankerTimer = currentTime
        SCHEDULER:New(nil, tankerCooldownHelp, {"sdfsdfd"}, TANKER_COOLDOWN)
    end
end

-------------------------------------------------------------------------------
function handleSupportRequest(text, coord)
    local currentTime = os.time()
    local cooldown = currentTime - supportTimer
    if cooldown < SUPPORT_COOLDOWN then
        CommandCenter:MessageTypeToCoalition(string.format("Support requests are not available at this time.\nRequests will be available again  in %d minutes", (SUPPORT_COOLDOWN - cooldown) / 60), MESSAGE.Type.Information)
        return
    end

    local supportSpawn = nil
    if text:find("artillery") then
        supportSpawn = artySpawn
    elseif text:find("tank") then
        supportSpawn = tankSpawn
    elseif text:find("services") then
        supportSpawn = servicesSpawn
    elseif text:find("jtac") then
        supportSpawn = jtacSpawn
    elseif text:find("apc") then
        supportSpawn = apcSpawn
    elseif text:find("sam") then
        supportSpawn = samSpawn
    elseif text:find("infantry") then
        supportSpawn = infantrySpawn
    end

    local spawnGroup = transportSpawn:Spawn()
    spawnGroup:TaskRouteToVec2( coord:GetVec2(), UTILS.KnotsToMps(550), "vee" )
    local distance = coord:Get2DDistance(HQ:GetCoordinate())
    function spawnAsset(text)
        if spawnGroup:IsAlive() then
            if text:find("jtac") then
                supportSpawn:OnSpawnGroup(
                    function(jtacSpawnGroup)
                        env.info(string.format( "BTI: Trying to create autolase jtac for %s",jtacSpawnGroup:GetName()))
                        ctld.JTACAutoLase(jtacSpawnGroup:GetName(), 1686, true, "all", 2)
                    end
                )
            end
            local supportGroup = supportSpawn:SpawnFromCoordinate(coord)
            supportGroup:RouteToVec2(coord:GetRandomVec2InRadius( 20, 5 ), 5)
            CommandCenter:MessageTypeToCoalition( string.format("%s Support asset has arrived to the player requested destination.", supportGroup:GetName()), MESSAGE.Type.Information )
        else
            CommandCenter:MessageTypeToCoalition( string.format("%s has been killed. No support asset for you!", spawnGroup:GetName()), MESSAGE.Type.Information )
        end
    end
    local travelTime = distance / UTILS.KnotsToMps(375) + 60
    env.info(string.format('BTI: New Asset request. distance %d, travel time %d', distance, travelTime))
    SCHEDULER:New(nil, spawnAsset, {text}, travelTime)

    CommandCenter:MessageTypeToCoalition( string.format("%s is enroute to the player requested destination\nETE is %d minutes.\n%d minutes cooldown starting now", spawnGroup:GetName(), travelTime / 60, SUPPORT_COOLDOWN / 60), MESSAGE.Type.Information )
    supportTimer = currentTime
    SCHEDULER:New(nil, supportCooldownHelp, {text}, SUPPORT_COOLDOWN)
end

--------------------------------------------------------------------------------
local destroyZoneCount = 0
function handleExfillRequest(text, coord)
    local currentTime = os.time()
    local cooldown = currentTime - exfillTimer
    if cooldown < EXFILL_COOLDOWN then
        CommandCenter:MessageTypeToCoalition(string.format("Exfill requests are not available at this time.\nRequests will be available again  in %d minutes", (EXFILL_COOLDOWN - cooldown) / 60), MESSAGE.Type.Information)
        return
    end

    if text:find("salvage") then

    elseif text:find("destroy") then

    end

    local destroyZoneName = string.format("destroy %d", destroyZoneCount)
    local zoneRadiusToDestroy = ZONE_RADIUS:New(destroyZoneName, coord:GetVec2(), 80)
    destroyZoneCount = destroyZoneCount + 1
    local function destroyUnit(zoneUnit)
        env.info(string.format("BTI: Found unit in zone %s", destroyZoneName))
        env.info(string.format("BTI: Salvaging command received, executing"))
        zoneUnit:Destroy()
        return true
    end
    zoneRadiusToDestroy:SearchZone(destroyUnit, Object.Category.UNIT)
    CommandCenter:MessageTypeToCoalition( string.format("Exfill complete! Salvage and Destroy services are now on cooldown for %d minutes", EXFILL_COOLDOWN / 60), MESSAGE.Type.Information )
    exfillTimer = currentTime
    supportTimer = supportTimer - 300
    env.info(string.format('BTI: using salvage new timer %d', supportTimer))
    SCHEDULER:New(nil, exfillCooldownHelp, {"sdfsdfd"}, EXFILL_COOLDOWN)
end

---------------------------------------------------------------------------------

function handleCommandRequest(text, coord)
    if text:find("awacs") then
        E2EWR = SPAWN:New('BLUE C EWR E2'):Spawn()
    elseif text:find("smoke") then
        if text:find("green") then
            coord:SmokeGreen()
        elseif text:find("orange") then
            coord:SmokeOrange()
        elseif text:find("blue") then
            coord:SmokeBlue()
        elseif text:find("red") then
            coord:SmokeRed()
        else
            coord:SmokeWhite()
        end
    elseif text:find("flare") then
        if text:find("green") then
            for i=10,1,-1 do coord:FlareGreen() end
        elseif text:find("yellow") then
            for i=10,1,-1 do coord:FlareYellow() end
        elseif text:find("red") then
            for i=10,1,-1 do coord:FlareRed() end
        else
            for i=10,1,-1 do coord:FlareWhite() end
        end
    end
end

function handleDebugRequest(text, coord)
    if text:find("patrol hard") then
        triggerFighters(fighterHardSpawn, coord)
    elseif text:find("patrol medium") then
        triggerFighters(fighterMediumSpawn, coord)
    elseif text:find("patrol easy") then
        triggerFighters(fighterEasySpawn, coord)
    elseif text:find("fighters easy") then
        deployFighters(fighterEasySpawn, coord)
    elseif text:find("fighters medium") then
        deployFighters(fighterMediumSpawn, coord)
    elseif text:find("fighters hard") then
        deployFighters(fighterHardSpawn, coord)
    elseif text:find("cas easy") then
        triggerCAS(casEasySpawn, coord)
    elseif text:find("cas medium") then
        triggerCAS(casMediumSpawn, coord)
    elseif text:find("cas hard") then
        triggerCAS(casHardSpawn, coord)
    elseif text:find("helos apache") then
        deployApache({"something"})
    elseif text:find("fire") then
        if text:find("big") then
            coord:BigSmokeAndFireLarge()
        elseif text:find("medium") then
            coord:BigSmokeAndFireMedium()
        elseif text:find("inferno") then
            coord:BigSmokeAndFireHuge(1)
        else
            coord:BigSmokeAndFireSmall()
        end
    elseif text:find("ground") then
        if text:find("tank") then
            local supportSpawn = tankSpawn
            local supportGroup = supportSpawn:SpawnFromCoordinate(coord)
            supportGroup:RouteToVec2(coord:GetRandomVec2InRadius( 20, 5 ), 5)
        end
        if text:find("apc") then
            local supportSpawn = apcSpawn
            local supportGroup = supportSpawn:SpawnFromCoordinate(coord)
            supportGroup:RouteToVec2(coord:GetRandomVec2InRadius( 20, 5 ), 5)
        end
    elseif text:find("dump") then
        if text:find("zone") then
            for i = 1, #SelectedZonesCoalition do
                env.info(string.format("BTI: DUMP ZONE %s", UTILS.OneLineSerialize(SelectedZonesCoalition[i])))
            end
        elseif text:find("blabla") then
        end
    end
end

local function handleWeatherRequest(text, coord)
    local currentPressure = coord:GetPressure(0)
    local currentTemperature = coord:GetTemperature()
    local currentWindDirection, currentWindStrengh = coord:GetWind()
    local weatherString = string.format("Requested weather: Wind from %d@%.1fkts, QNH %.2f, Temperature %d", currentWindDirection, UTILS.MpsToKnots(currentWindStrengh), currentPressure * 0.0295299830714, currentTemperature)
    CommandCenter:MessageTypeToCoalition(weatherString, MESSAGE.Type.Information)
end

---------------------------------------------------------------------------------
function markRemoved(Event)
    if Event.text~=nil and Event.text:lower():find("-") then 
        local text = Event.text:lower()
        local vec3 = {y=Event.pos.y, x=Event.pos.z, z=Event.pos.x}
        local coord = COORDINATE:NewFromVec3(vec3)
        coord.y = coord:GetLandHeight()

        if Event.text:lower():find("-fac") then
            handleFACRequest(text, coord)
        elseif Event.text:lower():find("-tanker") then
            handleTankerRequest(text, coord)
        elseif Event.text:lower():find("-support") then
            handleSupportRequest(text, coord)
        elseif Event.text:lower():find("-exfill") then
            handleExfillRequest(text, coord)
        elseif Event.text:lower():find("-command") then
            handleCommandRequest(text, coord)
        elseif Event.text:lower():find("-debug") then
            handleDebugRequest(text, coord)
        elseif Event.text:lower():find("-weather") then
            handleWeatherRequest(text, coord)
        end
    end
end

function SupportHandler:onEvent(Event)
    if Event.id == world.event.S_EVENT_MARK_ADDED then
        -- env.info(string.format("BTI: Support got event ADDED id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
    elseif Event.id == world.event.S_EVENT_MARK_CHANGE then
        -- env.info(string.format("BTI: Support got event CHANGE id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
    elseif Event.id == world.event.S_EVENT_MARK_REMOVED then
        -- env.info(string.format("BTI: Support got event REMOVED id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
        markRemoved(Event)
    end
end

world.addEventHandler(SupportHandler)

env.info('BTI: Beyond Support is online')
