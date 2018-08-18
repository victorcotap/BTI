
env.info("BTI: Starting Carrier deployement")

HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )

Carrier = GROUP:FindByName("BLUE CV Fleet")
TestCarrier = GROUP:FindByName("TEST CVN")
Carrier:HandleEvent(EVENTS.Land)



-- Events

function Carrier:OnEventLand(EventData)
    env.info(string.format("Carrier got an event from %s to %s", EventData.iniUnitName, EventData.tgtUnitName))
end

-- Utils

function sendWeatherTextFromCoordinate(coordinate)
    local currentPressure = coordinate:GetPressure(0)
    local currentTemperature = coordinate:GetTemperature()
    local currentWindDirection, currentWindStrengh = coordinate:GetWind()
    local weatherString = string.format("Carrier weather: Wind from %d@%.1fkts, BRC %d, QNH %.2f, Temperature %d", currentWindDirection, UTILS.MpsToKnots(currentWindStrengh), currentWindDirection, currentPressure * 0.0295299830714, currentTemperature)
    CommandCenter:MessageTypeToCoalition(weatherString, MESSAGE.Type.Information)
    return weatherString
end

function sendCarrierLaunchRecoveryCycle()
    CommandCenter:MessageTypeToCoalition("Carrier will turn into Launch/Recovery cycle in 5 minute!\nArco will reposition for recovery operation.\nWeather to follow", MESSAGE.Type.Information)
end

function sendCarrierRoutingCycle()
    CommandCenter:MessageTypeToCoalition("Carrier launch/recovery cycle is over in 5 minute.\nCarrier will resume its original route higher speed.\nPunch it Chewie!", MESSAGE.Type.Information)
end

function sendCarrierRouting()
    CommandCenter:MessageTypeToCoalition("Carrier will now turn to resume its original route", MESSAGE.Type.Information)
end

env.info("BTI: Carrier fleet is deployed, starting operations")

-- Cyclic ops

CyclicCarrier = Carrier

originalMissionRoute = CyclicCarrier:GetTaskRoute()
if originalMissionRoute then
    env.info("BTI: Got mission route")
    if #originalMissionRoute > 1 then
        env.info(string.format("BTI: We have %d points", #originalMissionRoute))
    end
end

local index = 1

function routeCarrierBackToNextWaypoint(routePoints)
    index = index + 1

    env.info(string.format("BTI: Trying to route back to the next waypoint index %d on route waypoints count %d", index, #originalMissionRoute))

    local nextPoint = originalMissionRoute[index]
    if nextPoint then
        env.info("BTI: we have an extra point!")
        table.remove(originalMissionRoute, 1)
        local newTask = CyclicCarrier:TaskRoute(originalMissionRoute)
        CyclicCarrier:SetTask(newTask)
        env.info("BTI: Carrier back on track")
        sendCarrierRouting()
    end
    SCHEDULER:New(nil, sendCarrierLaunchRecoveryCycle, {"toto"}, 600)
    SCHEDULER:New(nil, routeCarrierTemporary, {"routePoints"}, 900)
    env.info("BTI: carrier set to go back to into the wind in 1500")
end

function routeCarrierTemporary(routePoints)
    env.info("BTI: Going to route the carrier into the wind")
    local currentCoordinate = CyclicCarrier:GetCoordinate()
    local currentWindDirection, currentWindStrengh = currentCoordinate:GetWind()
    env.info(string.format("Current wind from %d @ %f", currentWindDirection - 7, UTILS.MpsToKnots(currentWindStrengh)))
    local intoTheWindCoordinate = currentCoordinate:Translate(30000, currentWindDirection)
    local speed = 0
    if currentWindStrengh < UTILS.KnotsToMps(5) then
        speed = UTILS.KnotsToMps(23)
    elseif currentWindStrengh > UTILS.KnotsToMps(5) and currentWindStrengh < UTILS.KnotsToMps(23)  then
        speed = UTILS.KnotsToMps(23) - currentWindStrengh
    elseif currentWindStrengh > UTILS.KnotsToMps(23) then
        speed = UTILS.KnotsToMps(15)
    end
    CyclicCarrier:TaskRouteToVec2(intoTheWindCoordinate:GetVec2(), speed)
    env.info(string.format("BTI: Carrier re-routed at speed %f", speed))

    sendWeatherTextFromCoordinate(currentCoordinate)
    SCHEDULER:New(nil, sendCarrierRoutingCycle, {"toto"}, 600)
    SCHEDULER:New(nil, routeCarrierBackToNextWaypoint, {"routePoints"}, 900)
end

-- Disable/Enable lines below for carrier ops training
SCHEDULER:New(nil, sendCarrierLaunchRecoveryCycle, {"toto"}, 540)
SCHEDULER:New(nil, routeCarrierTemporary, {"originalMissionRoute"}, 550)
CommandCenter:MessageTypeToCoalition("Carrier will now observe cyclic operations", MESSAGE.Type.Information)

env.info("BTI: Carrier fleet is now on cyclic operations")
