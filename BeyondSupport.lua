HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )

SupportHandler = EVENTHANDLER:New()

-- Spawns ---------------------------------------------------
artySpawn = SPAWN:New('BLUE Support arty')
tankSpawn = SPAWN:New('BLUE Support tank')
repairSpawn = SPAWN:New('BLUE Support repair')
apcSpawn = SPAWN:New('BLUE Support apc')
samSpawn = SPAWN:New('BLUE Support sam')
GFAC = nil
AFAC = nil
JFAC = nil
function spawnRecon(something)
    AFAC = SPAWN:New('BLUE FAC AFAC'):Spawn()
    JFAC = SPAWN:New('BLUE FAC JFAC'):Spawn()
    ctld.JTACAutoLase(JFAC:GetName(), 1688, false,"all", 4)
    ctld.JTACAutoLase(AFAC:GetName(), 1687, false,"all", 3)
end
SCHEDULER:New(nil, spawnRecon, {"dfsdf"}, 2, 3600)


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
    S3Tanker = SPAWN:New('BLUE C REFUK S3B'):Spawn()
end

SCHEDULER:New(nil, spawnServices, {"sdfsdfd"}, 45, 7200)

--------------------------------------------------------------------------
local function supportCooldownHelp(something)
    CommandCenter:MessageTypeToCoalition( string.format("Support asset delivery is now available again. Use the following marker commands:\n-support arty\n-support tank\n-support repair\n-support sam\n-support apc"), MESSAGE.Type.Information )
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

---------------------------------------------------------------------------
function handleFACRequest(Event)
    local text = Event.text:lower()
    local vec3 = {y=Event.pos.y, x=Event.pos.z, z=Event.pos.x}
    local coord = COORDINATE:NewFromVec3(vec3)
    coord.y = coord:GetLandHeight()

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
        fac:SetTask(routeTask)
        CommandCenter:MessageTypeToCoalition( string.format("%s FAC is re-routed to the requested destination.\n5 minutes cooldown starting now", fac:GetName()), MESSAGE.Type.Information )
        -- local facTask = fac:EnRouteTaskFAC( 10000, 2 )
        -- fac:PushTask(facTask)
        SCHEDULER:New(nil, facCooldownHelp, {"sdfsdfd"}, 6)
    end
end

function handleTankerRequest(Event)
    local text = Event.text:lower()
    local vec3 = {y=Event.pos.y, x=Event.pos.z, z=Event.pos.x}
    local coord = COORDINATE:NewFromVec3(vec3)
    coord.y = coord:GetLandHeight()


    if text:find("route") then
        local tanker = nil
        local altitude = nil
        local speed = nil
        if text:find("130") then
            tanker = KC130Tanker
            altitude = UTILS.FeetToMeters(12000)
            speed = UTILS.KnotsToMps(290)
        elseif text:find("s3") then
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
        tanker:SetTask(routeTask)
        local tankerTask = tanker:EnRouteTaskTanker()
        tanker:PushTask(tankerTask)
        CommandCenter:MessageTypeToCoalition( string.format("%s Tanker is re-routed to the requested destination.\n10 minutes cooldown starting now", tanker:GetName()), MESSAGE.Type.Information )
        SCHEDULER:New(nil, tankerCooldownHelp, {"sdfsdfd"}, 6)
    end
end

-------------------------------------------------------------------------------
function handleSupportRequest(Event)
    local text = Event.text:lower()
    local vec3 = {y=Event.pos.y, x=Event.pos.z, z=Event.pos.x}
    local coord = COORDINATE:NewFromVec3(vec3)
    coord.y = coord:GetLandHeight()

    local supportSpawn = nil
    if text:find("arty") then
        supportSpawn = artySpawn
    elseif text:find("tank") then
        supportSpawn = tankSpawn
    elseif text:find("repair") then
        supportSpawn = repairSpawn
    elseif text:find("apc") then
        supportSpawn = apcSpawn
    elseif text:find("sam") then
        supportSpawn = samSpawn
    end


    local supportGroup = supportSpawn:SpawnFromCoordinate(coord)
    supportGroup:RouteToVec2(coord:GetRandomVec2InRadius( 20, 5 ), 5)
    CommandCenter:MessageTypeToCoalition( string.format("%s Support asset is enroute to the requested destination.\n10 minutes cooldown starting now", supportGroup:GetName()), MESSAGE.Type.Information )
    SCHEDULER:New(nil, supportCooldownHelp, {"sdfsdfd"}, 6)
end

--------------------------------------------------------------------------------
local destroyZoneCount = 0
function handleExfillRequest(Event)
    local text = Event.text:lower()
    local vec3 = {y=Event.pos.y, x=Event.pos.z, z=Event.pos.x}
    local coord = COORDINATE:NewFromVec3(vec3)
    coord.y = coord:GetLandHeight()

    if text:find("salvage") then

    elseif text:find("destroy") then

    end
    env.info(string.format("BTI: We need to destroy this"))
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
    CommandCenter:MessageTypeToCoalition( string.format("Exfill complete! Salvage and Destroy services are now on cooldown for 10 minutes"), MESSAGE.Type.Information )
    exfillCooldownHelp()
end

---------------------------------------------------------------------------------
function markRemoved(Event)
    if Event.text~=nil then 
        if Event.text:lower():find("-fac") then
            handleFACRequest(Event)
        elseif Event.text:lower():find("-tanker") then
            handleTankerRequest(Event)
        elseif Event.text:lower():find("-support") then
            handleSupportRequest(Event)
        elseif Event.text:lower():find("-exfill") then
            handleExfillRequest(Event)
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