
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
airbossStennis:SetLSORadio(264)
airbossStennis:SetMarshalRadio(264)
airbossStennis:SetPatrolAdInfinitum(true)
airbossStennis:SetCarrierControlledArea(45)
airbossStennis:SetStaticWeather(false)
airbossStennis:SetMenuSingleCarrier()
airbossStennis:SetRecoveryCase(1)
airbossStennis:SetMaxLandingPattern(3)
airbossStennis:SetDefaultPlayerSkill(AIRBOSS.Difficulty.HARD)
airbossStennis:SetHandleAIOFF()
airbossStennis:SetMenuRecovery(45, 25, true)
airbossStennis:SetMenuMarkZones(true)
airbossStennis:SetMenuSmokeZones(true)
airbossStennis:SetAirbossNiceGuy(true)
airbossStennis:SetRadioRelayMarshal("BLUE Rescue Helo")
airbossStennis:SetRadioRelayLSO("BLUE Rescue Helo")
airbossStennis:SetSoundfilesFolder("Airboss Soundfiles/")
airbossStennis:Load(nil, "Greenie Board.csv")
airbossStennis:SetAutoSave(nil, "Greenie Board.csv")
-- airbossStennis:SetDebugModeON() --disable

-- create fake recovery window at the end of the mission play
-- local window1 = airbossStennis:AddRecoveryWindow("09:01", "23:55", 1, 0, false)

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

local airbossTarawa = AIRBOSS:New("LHA-1 Tarawa", "LHA-1 Tarawa")

airbossTarawa:SetTACAN(3, "X", "TRW")
airbossTarawa:SetICLS(3, "LSO")
airbossTarawa:SetLSORadio(259)
airbossTarawa:SetMarshalRadio(259)
airbossTarawa:SetPatrolAdInfinitum(true)
airbossTarawa:SetCarrierControlledArea(45)
airbossTarawa:SetStaticWeather(false)
airbossTarawa:SetMenuSingleCarrier(true)
airbossTarawa:SetRecoveryCase(1)
airbossTarawa:SetMaxLandingPattern(2)
airbossTarawa:SetDefaultPlayerSkill(AIRBOSS.Difficulty.Easy)
airbossTarawa:SetHandleAIOFF()
airbossTarawa:SetMenuMarkZones(true)
airbossTarawa:SetAirbossNiceGuy(false)
airbossTarawa:SetMenuSmokeZones(false)
airbossTarawa:Load(nil, "Tarawa Greenie Board.csv")
airbossTarawa:SetAutoSave(nil, "Tarawa Greenie Board.csv")
airbossTarawa:AddRecoveryWindow("16:50", "23:50", case, defaultOffset, false, speed)

-- RescueheloTarawa=RESCUEHELO:New(UNIT:FindByName("LHA Tarawa"), "BLUE Rescue Helo")
-- RescueheloTarawa:SetTakeoffHot()
-- RescueheloTarawa:Start()

airbossTarawa:Start()

--------------------------------------------------------------------------------------------------
-- Menu commands
-- local defaultOffset = 0
-- function OpenCarrierRecovery(minutesRemainingOpen, case)
--     if lockRecoveryRequest == true then
--         CommandCenter:MessageTypeToCoalition("Sorry, carrier is already performing a recovery.\n Wait until the recovery is over before requesting another one", MESSAGE.Type.Information)
--         return
--     end

--     local turningMinutes = 1
--     currentMissionRoute = CyclicCarrier:GetTaskRoute()
--     local timeRecoveryOpen = timer.getAbsTime()+ turningMinutes*60
--     local timeRecoveryClose = timeRecoveryOpen + minutesRemainingOpen*60

--     local currentCoordinate = CyclicCarrier:GetCoordinate()
--     local currentWindDirection, currentWindStrengh = currentCoordinate:GetWind()
--     local speed = 0
--     if currentWindStrengh < UTILS.KnotsToMps(5) then
--         speed = UTILS.KnotsToMps(26)
--     elseif currentWindStrengh > UTILS.KnotsToMps(5) and currentWindStrengh < UTILS.KnotsToMps(23)  then
--         speed = UTILS.KnotsToMps(26) - currentWindStrengh
--     elseif currentWindStrengh > UTILS.KnotsToMps(23) then
--         speed = UTILS.KnotsToMps(10)
--     end
--     env.info(string.format( "BTI: Calculating carrier recovery speed for %f mps (%f kts) -> speed %f kt", currentWindStrengh, UTILS.MpsToKnots(currentWindStrengh), UTILS.MpsToKnots(speed) ))

--     airbossStennis:AddRecoveryWindow(UTILS.SecondsToClock(timeRecoveryOpen), UTILS.SecondsToClock(timeRecoveryClose), case, defaultOffset, true, speed)
--     CommandCenter:MessageTypeToCoalition(string.format("Carrier will open CASE %d recovery window in 1 minutes.\n It will remain open for %d minutes", case, minutesRemainingOpen), MESSAGE.Type.Information)

-- end

-- function ActivateCarrierBeacons()
--     local carrierBeacon = BEACON:New(CyclicCarrier)
--     carrierBeacon:ActivateTACAN(15, "X", "STN", true)
--     carrierBeacon:ActivateICLS(5, "LSO")
-- end
