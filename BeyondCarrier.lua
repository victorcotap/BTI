
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
function ResetCarriersBeacons()
    activateCarrierBeacons("Name of your carrier", 15, "X", "STN", 5, "LSO")
    activateCarrierBeacons("Name of your carrier", 16, "X", "SAR", 1, "LSO")
    activateCarrierBeacons("Name of your carrier", 17, "X", "MPH", 7, "LSO")
end

function activateCarrierBeacons(carrierUnitName, TCNFreq, TCNBand, TCNName, ICLSChannel, ICLSName)
	local CyclicCarrier = UNIT:FindByName(carrierUnitName)
   	local carrierBeacon = BEACON:New(CyclicCarrier)
    carrierBeacon:ActivateTACAN(TCNFreq, TCNBand, TCNName, true)
    carrierBeacon:ActivateICLS(ICLSChannel, ICLSName)
end

-- Utils


env.info("BTI: Carrier fleet is deployed, starting operations")

-- Cyclic ops

CyclicCarrier = Carrier


env.info("BTI: Carrier fleet is now on cyclic operations")

---------------------------------------------------------------------------
-- AIRBOSS

local airbossStennis = AIRBOSS:New("BLUE CVN", "CVN-74 Stennis")

airbossStennis:SetTACAN(15, "X", "STN")
airbossStennis:SetICLS(5, "LSO")
airbossStennis:SetLSORadio(250)
airbossStennis:SetMarshalRadio(250)
airbossStennis:SetPatrolAdInfinitum(false)
airbossStennis:SetCarrierControlledArea(45)
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
-- airbossStennis:SetDebugModeON() --disable

-- create fake recovery window at the end of the mission play
airbossStennis:AddRecoveryWindow("23:50", "23:55", 1)

local carrierTanker = nil  --Ops.RecoveryTanker#RECOVERYTANKER
carrierTanker = RECOVERYTANKER:New("BLUE CVN", "BLUE C REFUK S3 Navy")
carrierTanker:SetTakeoffHot()
carrierTanker:SetTACAN(14, "SMC")
carrierTanker:SetRadio(263, "AM")
carrierTanker:SetRespawnOn()
carrierTanker:Start()
airbossStennis:SetRecoveryTanker(carrierTanker)

RescueheloStennis=RESCUEHELO:New(UNIT:FindByName("BLUE CVN"), "BLUE Rescue Helo")
RescueheloStennis:SetTakeoffHot()
RescueheloStennis:Start()

airbossStennis:Start()
--------------------------------------------------------------------------------------

-- local airbossTarawa = AIRBOSS:New("LHA Tarawa", "LHA-1 Tarawa")

-- airbossTarawa:SetTACAN(3, "X", "TRW")
-- airbossTarawa:SetICLS(3, "LSO")
-- airbossTarawa:SetLSORadio(259)
-- airbossTarawa:SetMarshalRadio(259)
-- airbossTarawa:SetPatrolAdInfinitum(false)
-- airbossTarawa:SetCarrierControlledArea(45)
-- airbossTarawa:SetStaticWeather(false)
-- airbossTarawa:SetMenuSingleCarrier(false)
-- airbossTarawa:SetRecoveryCase(1)
-- airbossTarawa:SetMaxLandingPattern(2)
-- airbossTarawa:SetDefaultPlayerSkill(AIRBOSS.Difficulty.Easy)
-- airbossTarawa:SetHandleAIOFF()
-- airbossTarawa:SetMenuMarkZones(true)
-- airbossTarawa:SetAirbossNiceGuy(false)
-- airbossTarawa:SetMenuSmokeZones(false)
-- airbossTarawa:Load(nil, "Tarawa Greenie Board.csv")
-- airbossTarawa:SetAutoSave(nil, "Tarawa Greenie Board.csv")
-- airbossTarawa:AddRecoveryWindow("16:50", "23:50", case, defaultOffset, false, speed)

-- RescueheloTarawa=RESCUEHELO:New(UNIT:FindByName("LHA Tarawa"), "BLUE Rescue Helo")
-- RescueheloTarawa:SetTakeoffHot()
-- RescueheloTarawa:Start()

-- airbossTarawa:Start()

--------------------------------------------------------------------------------------------------
-- Menu commands
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
    airbossStennis:DeleteAllRecoveryWindows()
    CommandCenter:MessageTypeToCoalition("Carrier Recoveries are cancelled.\nCarrier will return onto its original path.\nUse the F10 radio menu to request a new recovery", MESSAGE.Type.Information)
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- Backup oldie


-- function sendCarrierLaunchRecoveryCycle()
--     CommandCenter:MessageTypeToCoalition("Carrier will turn into Launch/Recovery cycle in 5 minute!\nArco will reposition for recovery operation.\nWeather to follow", MESSAGE.Type.Information)
-- end

-- function sendCarrierRoutingCycle()
--     CommandCenter:MessageTypeToCoalition("Carrier launch/recovery cycle is over in 5 minute.\nCarrier will resume its original route higher speed.\nPunch it Chewie!", MESSAGE.Type.Information)
-- end

-- function sendCarrierRouting()
--     CommandCenter:MessageTypeToCoalition("Carrier will now turn to resume its original route", MESSAGE.Type.Information)
-- end

-- function sendWeatherTextFromCoordinate(coordinate)
--     local currentPressure = coordinate:GetPressure(0)
--     local currentTemperature = coordinate:GetTemperature()
--     local currentWindDirection, currentWindStrengh = coordinate:GetWind()
--     local weatherString = string.format("Carrier weather: Wind from %d@%.1fkts, BRC %d, QNH %.2f, Temperature %d", currentWindDirection, UTILS.MpsToKnots(currentWindStrengh), currentWindDirection, currentPressure * 0.0295299830714, currentTemperature)
--     CommandCenter:MessageTypeToCoalition(weatherString, MESSAGE.Type.Information)
--     return weatherString
-- end

-- local currentMissionRoute = CyclicCarrier:GetTaskRoute()
-- local index = 1
-- local lockRecoveryRequest = false

-- function routeCarrierBackToNextWaypoint(routePoints)
--     -- index = index + 1

--     env.info(string.format("BTI: Trying to route back to the next waypoint index %d on route waypoints count %d", index, #currentMissionRoute))

--     local nextPoint = currentMissionRoute[index]
--     if nextPoint then
--         env.info("BTI: we have an extra point!")
--         -- table.remove(currentMissionRoute, 1)
--         local newTask = CyclicCarrier:TaskRoute(currentMissionRoute)
--         CyclicCarrier:SetTask(newTask)
--         env.info("BTI: Carrier back on track")
--         sendCarrierRouting()
--     end
--     CARRIERCycle = 0
--     CARRIERTimer = os.time()
--     -- SCHEDULER:New(nil, sendCarrierLaunchRecoveryCycle, {"toto"}, CARRIERRouteLength - 300)
--     -- SCHEDULER:New(nil, routeCarrierTemporary, {"routePoints"}, CARRIERRouteLength)
--     lockRecoveryRequest = false
--     env.info("BTI: carrier set to go back to into the wind in 1500")
-- end

-- function routeCarrierTemporary(recoveryLength, routePoints)
--     env.info("BTI: Going to route the carrier into the wind")
--     local currentCoordinate = CyclicCarrier:GetCoordinate()
--     local currentWindDirection, currentWindStrengh = currentCoordinate:GetWind()
--     env.info(string.format("Current wind from %d @ %f", currentWindDirection - 7, UTILS.MpsToKnots(currentWindStrengh)))
--     local intoTheWindCoordinate = currentCoordinate:Translate(30000, currentWindDirection)
--     local speed = 0
--     if currentWindStrengh < UTILS.KnotsToMps(5) then
--         speed = UTILS.KnotsToMps(22)
--     elseif currentWindStrengh > UTILS.KnotsToMps(5) and currentWindStrengh < UTILS.KnotsToMps(23)  then
--         speed = UTILS.KnotsToMps(19) - currentWindStrengh
--     elseif currentWindStrengh > UTILS.KnotsToMps(23) then
--         speed = UTILS.KnotsToMps(12)
--     end
--     CyclicCarrier:TaskRouteToVec2(intoTheWindCoordinate:GetVec2(), speed)
--     env.info(string.format("BTI: Carrier re-routed at speed %f", speed))

--     sendWeatherTextFromCoordinate(currentCoordinate)
--     CARRIERCycle = 1
--     CARRIERTimer = os.time()
--     -- SCHEDULER:New(nil, sendCarrierRoutingCycle, {"toto"}, recoveryLength - 300)
--     SCHEDULER:New(nil, routeCarrierBackToNextWaypoint, {"routePoints"}, recoveryLength)
--     lockRecoveryRequest = true
-- end

-- -- Disable/Enable lines below for carrier ops training
-- -- SCHEDULER:New(nil, sendCarrierLaunchRecoveryCycle, {"toto"}, 15)
-- -- SCHEDULER:New(nil, routeCarrierTemporary, {"currentMissionRoute"}, 30)
-- CommandCenter:MessageTypeToCoalition("Carrier will now observe cyclic operations", MESSAGE.Type.Information)
