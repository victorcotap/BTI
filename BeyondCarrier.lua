
env.info("BTI: Starting Carrier deployement")

Carrier = UNIT:FindByName("BLUE CVN")
Fleet = GROUP:FindByName("BLUE CV Fleet")
CarrierAircrafts = SET_GROUP:New():FilterPrefixes("BLUE C"):FilterStart()
PlayerAircrafts = SET_CLIENT:New():FilterPrefixes("P"):FilterStart()
E2 = UNIT:FindByName("BLUE C E")




-- Carrier:HandleEvent(EVENTS.Land)
-- Carrier:HandleEvent(EVENTS.Takeoff)
-- CarrierAircrafts:HandleEvent(EVENTS.Takeoff)
-- CarrierAircrafts:HandleEvent(EVENTS.Land)



function Carrier:OnEventLand(EventData)
    env.info(string.format("Carrier got an event from %s to %s", EventData.iniUnitName, EventData.tgtUnitName))
end

function CarrierAircrafts:OnEventLand(EventData)
    env.info(string.format("Carrier got an event from %s to %s", EventData.iniUnitName, EventData.tgtUnitName))
end

function CarrierAircrafts:OnEventTakeoff(EventData)
    if EventData then
        env.info("Carrier Got EventData")
    end
    env.info(string.format("Carrier got an event from %s to %s", EventData.iniUnitName, EventData.tgtUnitName))
end



PlayerAircrafts:HandleEvent(EVENTS.Takeoff)
function PlayerAircrafts:OnEventTakeoff(eventData)
    if eventData then
        env.info("Carrier Got EventData")
    end
    env.info("BLABLABLABLABNLA")
end

env.info("BTI: Carrier fleet is deployed")
