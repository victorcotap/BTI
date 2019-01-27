
env.info("BTI: Starting Carrier deployement")

HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )

Carrier = GROUP:FindByName("BLUE CV Fleet")
TestCarrier = GROUP:FindByName("TEST CVN")

-- Globals ---------------------------------------------------------------
CARRIERCycle = 0
CARRIERTimer = 0
CARRIERRecoveryLength = 180
CARRIERRouteLength = 1800

-- Events ----------------------------------------------------------------

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

local currentMissionRoute = CyclicCarrier:GetTaskRoute()
local index = 1
local lockRecoveryRequest = false

function routeCarrierBackToNextWaypoint(routePoints)
    -- index = index + 1

    env.info(string.format("BTI: Trying to route back to the next waypoint index %d on route waypoints count %d", index, #currentMissionRoute))

    local nextPoint = currentMissionRoute[index]
    if nextPoint then
        env.info("BTI: we have an extra point!")
        -- table.remove(currentMissionRoute, 1)
        local newTask = CyclicCarrier:TaskRoute(currentMissionRoute)
        CyclicCarrier:SetTask(newTask)
        env.info("BTI: Carrier back on track")
        sendCarrierRouting()
    end
    CARRIERCycle = 0
    CARRIERTimer = os.time()
    -- SCHEDULER:New(nil, sendCarrierLaunchRecoveryCycle, {"toto"}, CARRIERRouteLength - 300)
    -- SCHEDULER:New(nil, routeCarrierTemporary, {"routePoints"}, CARRIERRouteLength)
    lockRecoveryRequest = false
    env.info("BTI: carrier set to go back to into the wind in 1500")
end

function routeCarrierTemporary(recoveryLength, routePoints)
    env.info("BTI: Going to route the carrier into the wind")
    local currentCoordinate = CyclicCarrier:GetCoordinate()
    local currentWindDirection, currentWindStrengh = currentCoordinate:GetWind()
    env.info(string.format("Current wind from %d @ %f", currentWindDirection - 7, UTILS.MpsToKnots(currentWindStrengh)))
    local intoTheWindCoordinate = currentCoordinate:Translate(30000, currentWindDirection)
    local speed = 0
    if currentWindStrengh < UTILS.KnotsToMps(5) then
        speed = UTILS.KnotsToMps(22)
    elseif currentWindStrengh > UTILS.KnotsToMps(5) and currentWindStrengh < UTILS.KnotsToMps(23)  then
        speed = UTILS.KnotsToMps(19) - currentWindStrengh
    elseif currentWindStrengh > UTILS.KnotsToMps(23) then
        speed = UTILS.KnotsToMps(12)
    end
    CyclicCarrier:TaskRouteToVec2(intoTheWindCoordinate:GetVec2(), speed)
    env.info(string.format("BTI: Carrier re-routed at speed %f", speed))

    sendWeatherTextFromCoordinate(currentCoordinate)
    CARRIERCycle = 1
    CARRIERTimer = os.time()
    -- SCHEDULER:New(nil, sendCarrierRoutingCycle, {"toto"}, recoveryLength - 300)
    SCHEDULER:New(nil, routeCarrierBackToNextWaypoint, {"routePoints"}, recoveryLength)
    lockRecoveryRequest = true
end

-- Disable/Enable lines below for carrier ops training
-- SCHEDULER:New(nil, sendCarrierLaunchRecoveryCycle, {"toto"}, 15)
-- SCHEDULER:New(nil, routeCarrierTemporary, {"currentMissionRoute"}, 30)
CommandCenter:MessageTypeToCoalition("Carrier will now observe cyclic operations", MESSAGE.Type.Information)

env.info("BTI: Carrier fleet is now on cyclic operations")

---------------------------------------------------------------------------
-- AIRBOSS

local airbossStennis = AIRBOSS:New("BLUE CVN", "CVN-74 Stennis")

airbossStennis:SetTACAN(15, "X", "STN")
airbossStennis:SetICLS(5, "LSO")
airbossStennis:SetLSORadio(250)
airbossStennis:SetMarshalRadio(252)
airbossStennis:SetPatrolAdInfinitum(false)
airbossStennis:SetCarrierControlledArea(40)
airbossStennis:SetStaticWeather(false)
airbossStennis:SetMenuSingleCarrier(true)
airbossStennis:SetRecoveryCase(1)
airbossStennis:SetMaxLandingPattern(3)
airbossStennis:SetDefaultPlayerSkill(AIRBOSS.Difficulty.Easy)
airbossStennis:SetHandleAIOFF()
airbossStennis:SetMenuMarkZones(true)
airbossStennis:SetAirbossNiceGuy(false)
airbossStennis:SetMenuSmokeZones(false)
airbossStennis:Load(nil, "Greenie Board.csv")
airbossStennis:SetAutoSave(nil, "Greenie Board.csv")

-- create fake recovery window at the end of the mission play
airbossStennis:AddRecoveryWindow("23:50", "23:55", 1)
-- airbossStennis:AddRecoveryWindow("15:00", "15:30", 2, 15)
-- airbossStennis:AddRecoveryWindow("16:00", "16:30", 3, -20)
-- airbossStennis:AddRecoveryWindow("17:00", "17:30", 1)
-- airbossStennis:AddRecoveryWindow("18:00", "18:30", 1)

-- airbossStennis:SetDebugModeON() --disable

local carrierTanker = nil  --Ops.RecoveryTanker#RECOVERYTANKER
carrierTanker = RECOVERYTANKER:New("BLUE CVN", "BLUE C REFUK S3 Navy")
carrierTanker:SetTakeoffAir()
carrierTanker:SetTACAN(14, "SMC")
carrierTanker:Start()
carrierTanker:SetRadio(263, "AM")
carrierTanker:SetRespawnOn()
airbossStennis:SetRecoveryTanker(carrierTanker)

airbossStennis:Start()


local defaultOffset = 0
function OpenCarrierRecovery(minutesRemainingOpen, case)
    if lockRecoveryRequest == true then
        CommandCenter:MessageTypeToCoalition("Sorry, carrier is already performing a recovery.\n Wait until the recovery is over before requesting another one", MESSAGE.Type.Information)
        return
    end

    local turningMinutes = 1
    currentMissionRoute = CyclicCarrier:GetTaskRoute()
    local timeRecoveryOpen = timer.getAbsTime()+ turningMinutes*60
    local timeRecoveryClose = timeRecoveryOpen + minutesRemainingOpen*60

    -- manual routing
    -- routeCarrierTemporary((turningMinutes + minutesRemainingOpen) * 60)
    
    local currentCoordinate = CyclicCarrier:GetCoordinate()
    local currentWindDirection, currentWindStrengh = currentCoordinate:GetWind()
    local speed = 0
    if currentWindStrengh < UTILS.KnotsToMps(5) then
        speed = UTILS.KnotsToMps(26)
    elseif currentWindStrengh > UTILS.KnotsToMps(5) and currentWindStrengh < UTILS.KnotsToMps(23)  then
        speed = UTILS.KnotsToMps(26) - currentWindStrengh
    elseif currentWindStrengh > UTILS.KnotsToMps(23) then
        speed = UTILS.KnotsToMps(10)
    end
    env.info(string.format( "BTI: Calculating carrier recovery speed for %f mps (%f kts) -> speed %f kt", currentWindStrengh, UTILS.MpsToKnots(currentWindStrengh), UTILS.MpsToKnots(speed) ))

    airbossStennis:AddRecoveryWindow(UTILS.SecondsToClock(timeRecoveryOpen), UTILS.SecondsToClock(timeRecoveryClose), case, defaultOffset, true, speed)
    CommandCenter:MessageTypeToCoalition(string.format("Carrier will open CASE %d recovery window in 1 minutes.\n It will remain open for %d minutes", case, minutesRemainingOpen), MESSAGE.Type.Information)

end

function ActivateCarrierBeacons()
    local carrierBeacon = BEACON:New(CyclicCarrier)
    carrierBeacon:ActivateTACAN(15, "X", "STN", true)
    carrierBeacon:ActivateICLS(5, "LSO")
end

function CancelCarrierRecovery()
    routeCarrierBackToNextWaypoint()
    airbossStennis:CloseCurrentRecoveryWindow()
    CommandCenter:MessageTypeToCoalition("Carrier Recovery is cancelled.\nCarrier will return onto its original path.\nUse the F10 radio menu to request a new recovery", MESSAGE.Type.Information)
end

---------------------------------------------------------------------------
