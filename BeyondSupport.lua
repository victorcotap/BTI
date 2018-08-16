SupportHandler = EVENTHANDLER:New()
FAC = nil
AFAC = nil
function spawnRecon(something)
    AFAC = SPAWN:New('BLUE FAC Reaper A'):Spawn()
    FAC = SPAWN:New('BLUE FAC HMMWV'):Spawn()
end
SCHEDULER:New(nil, spawnRecon, {"dfsdf"}, 2, 3600)


function markRemoved(Event)
    if Event.text~=nil and Event.text:lower():find("arty") then
        
    end
end

function SupportHandler:onEvent(Event)
    if Event.id == world.event.S_EVENT_MARK_ADDED then
        env.info(string.format("BTI: Support got event ADDED id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
    elseif Event.id == world.event.S_EVENT_MARK_CHANGED then
        env.info(string.format("BTI: Support got event CHANGED id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
    elseif Event.id == world.event.S_EVENT_MARK_REMOVED then
        env.info(string.format("BTI: Support got event REMOVED id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
    end
end

world.addEventHandler(SupportHandler)

env.info('BTI: Beyond Support is operational')