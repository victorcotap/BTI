HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )
artySpawn = SPAWN:New('BLUE Support arty')
tankSpawn = SPAWN:New('BLUE Support tank')
repairSpawn = SPAWN:New('BLUE Support repair')
SupportHandler = EVENTHANDLER:New()
FAC = nil
AFAC = nil
function spawnRecon(something)
    AFAC = SPAWN:New('BLUE FAC Reaper A'):Spawn()
    FAC = SPAWN:New('BLUE FAC HMMWV'):Spawn()
end
SCHEDULER:New(nil, spawnRecon, {"dfsdf"}, 2, 3600)


function handleAFACRequest(Event)
    local text = Event.text:lower()
    local vec3 = {y=Event.pos.y, x=Event.pos.z, z=Event.pos.x}
    local coord = COORDINATE:NewFromVec3(vec3)
    coord.y = coord:GetLandHeight()

    if text:find("route") then
        local routeTask = AFAC:TaskOrbitCircleAtVec2( coord:GetVec2(), 6000,  UTILS.KnotsToMps(150) )
        AFAC:SetTask(routeTask)
        local facTask = AFAC:EnRouteTaskFAC( 10000, 2 )
        AFAC:PushTask(facTask)
    end
end

function handleFACRequest(Event)
    local text = Event.text:lower()
    local vec3 = {y=Event.pos.y, x=Event.pos.z, z=Event.pos.x}
    local coord = COORDINATE:NewFromVec3(vec3)
    coord.y = coord:GetLandHeight()

    if text:find("route") then
        local routeTask = FAC:RouteGroundTo( coord, UTILS.KnotsToMps(55), nil, 5 )
        FAC:SetTask(routeTask)
        local facTask = AFAC:EnRouteTaskFAC( 10000, 2 )
        AFAC:PushTask(facTask)
    end
end


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
    end


    local supportGroup = supportSpawn:SpawnFromCoordinate(coord)
    supportGroup:RouteToVec2(coord:GetRandomVec2InRadius( 20, 5 ), 5)
end

function markRemoved(Event)
    if Event.text~=nil then 
        if Event.text:lower():find("afac") then
            handleAFACRequest(Event)
        elseif Event.text:lower():find("support") then
            handleSupportRequest(Event)
        end
    end
end

function SupportHandler:onEvent(Event)
    if Event.id == world.event.S_EVENT_MARK_ADDED then
        -- env.info(string.format("BTI: Support got event ADDED id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
    elseif Event.id == world.event.S_EVENT_MARK_CHANGED then
        env.info(string.format("BTI: Support got event CHANGED id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
    elseif Event.id == world.event.S_EVENT_MARK_REMOVED then
        -- env.info(string.format("BTI: Support got event REMOVED id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
        markRemoved(Event)
    end


end

world.addEventHandler(SupportHandler)

env.info('BTI: Beyond Support is operational')