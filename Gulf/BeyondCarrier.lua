env.info("BTI: Starting Carrier deployement")

HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )

Carrier = GROUP:FindByName("BLUE CV Fleet")
TestCarrier = GROUP:FindByName("TEST CVN")
Carrier:HandleEvent(EVENTS.Land)
S3Tanker = nil

-- Spawns

function spawnRecon(something)
    local group = SPAWN:New('BLUE FAC Reaper A'):Spawn()
end
SCHEDULER:New(nil, spawnRecon, {"dfsdf"}, 7, 3600)

function spawnServices(something)
    env.info('BTI Spawn function activated')

    SPAWN:New('BLUE C EWR E2'):Spawn()
    SPAWN:New('BLUE REFUK KC130'):Spawn()
    S3Tanker = SPAWN:New('BLUE C REFUK S3B'):Spawn()
end

SCHEDULER:New(nil, spawnServices, {"sdfsdfd"}, 45, 7200)


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
    end
    SCHEDULER:New(nil, sendCarrierLaunchRecoveryCycle, {"toto"}, 600)
    SCHEDULER:New(nil, routeCarrierTemporary, {"routePoints"}, 900)
    env.info("BTI: carrier set to go back to into the wind in 900")
end

function routeCarrierTemporary(routePoints)
    env.info("BTI: Going to route the carrier into the wind")
    local currentCoordinate = CyclicCarrier:GetCoordinate()
    local currentWindDirection, currentWindStrengh = currentCoordinate:GetWind()
    env.info(string.format("Current wind from %d @ %f", currentWindDirection - 7, UTILS.MpsToKnots(currentWindStrengh)))
    local intoTheWindCoordinate = currentCoordinate:Translate(30000, currentWindDirection)
    local S3TankerCoordinate = currentCoordinate:Translate(15000, currentWindDirection)
    local speed = 0
    if currentWindStrengh < UTILS.KnotsToMps(5) then
        speed = UTILS.KnotsToMps(26)
    elseif currentWindStrengh > UTILS.KnotsToMps(5) and currentWindStrengh < UTILS.KnotsToMps(25)  then
        speed = UTILS.KnotsToMps(26) - currentWindStrengh
    elseif currentWindStrengh > UTILS.KnotsToMps(25) then
        speed = UTILS.KnotsToMps(17)
    end
    CyclicCarrier:TaskRouteToVec2(intoTheWindCoordinate:GetVec2(), speed)
    env.info(string.format("BTI: Carrier re-routed at speed %f", speed))

    sendWeatherTextFromCoordinate(currentCoordinate)
    SCHEDULER:New(nil, sendCarrierRoutingCycle, {"toto"}, 460)
    SCHEDULER:New(nil, routeCarrierBackToNextWaypoint, {"routePoints"}, 760)
end

-- Disable/Enable lines below for carrier ops training
SCHEDULER:New(nil, sendCarrierLaunchRecoveryCycle, {"toto"}, 540)
SCHEDULER:New(nil, routeCarrierTemporary, {"originalMissionRoute"}, 550)
CommandCenter:MessageTypeToCoalition("Carrier will now observe cyclic operations", MESSAGE.Type.Information)


env.info("BTI: Carrier fleet is now on cyclic operations")


--Trash
function routeTankerToMarshallStack(currentCoordinate, currentWindDirection)
    -- Fuck MOOSE, doesn't work
    -- local tasks = {}
    -- local S3TankerCoordinate = currentCoordinate:Translate(15000, currentWindDirection)
    -- tasks[#tasks+1] = S3Tanker:TaskOrbitCircleAtVec2(S3TankerCoordinate:GetVec2(), 3000, UTILS.KnotsToMps(280))
    -- tasks[#tasks+1] = S3Tanker:EnRouteTaskTanker()
    -- S3Tanker:SetTask(S3Tanker:TaskCombo(tasks), 1)
end

-- doesn't work, fuck lua
function findNearestRoutePointIndex(currentCoordinate, routePoints)
    local result = 1
    local distance = 100000000000000000000000000000

    for someIndex = 1, #routePoints, 1 do
        local something = routePoints[someIndex]
        string.format("BTI: something $d and ", something.x, something.y)
    end

    for keyIndex, originalPoint in pairs(routePoints) do
        env.info(string.format("BTI: Trying to read original route point at index %d", keyIndex))
        local originalPointCoordinate = COORDINATE:NewFromVec2(originalPoint)
        env.info("BTI: got a coordinate X %d Y %d", originalPointCoordinate.x, originalPointCoordinate.y)
        local originalPointDistance = currentCoordinate:Get2DDistance(originalPointCoordinate)
        env.info("BTI: distance to point %d", originalPointDistance)
        if originalPointDistance < distance then
            distance = originalPointDistance
            result = keyIndex
        end
    end
    return result, distance
end
