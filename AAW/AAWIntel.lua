env.info(string.format("BTI: Beginning CIA surveillance..."))
_SETTINGS:SetPlayerMenuOff()
-- Utils ---------------------------------------------------------------
local function ternary ( cond , T , F )
    if cond then return T else return F end
end



----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
PlayerMap = {}
local PlayerMenuMap = {}

SetPlayer = SET_CLIENT:New():FilterCoalitions("blue"):FilterActive():FilterStart()

-- COMMANDS ----------------------------------------------------------------------------------------------
function requestTankerAWACSTasking()
    SUPPORTResetTankerAWACSTask()
end

function requestCarrierRecovery(case)
    env.info(string.format( "BTI: received demand for recovery case %d", case ))
    OpenCarrierRecovery(29, case)
end

function requestCarrierBeacon()
    ActivateCarrierBeacons()
end

function requestCarrierCancelRecovery()
    CancelCarrierRecovery()
end

function requestWipeAllAssets()
    SUPPORTWipeSpawnedAssets()
end

function requestWipeLastAsset()
    SUPPORTWipeLastAsset()
end

function requestGenerateMaster()
    TRACKINGGenerateMaster()
end

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
local function permanentPlayerMenu(something)
    -- env.info(string.format( "BTI: Starting permanent menus"))
    for playerID, alive in pairs(PlayerMap) do
        -- env.info(string.format( "BTI: Commencing Menus for playerID %s alive %s", playerID, tostring(alive)))
        local playerClient = CLIENT:FindByName(playerID)
        local playerGroup = playerClient:GetGroup()
        if alive and playerGroup ~= nil then
            local IntelMenu = MENU_GROUP:New( playerGroup, "DO NOT USE(for real)[Buggy]" )

            local tankerAWACSMenu = MENU_GROUP_COMMAND:New( playerGroup, "Fix Tanker & AWACS [WIP]", IntelMenu, requestTankerAWACSTasking)
            local carrierBeaconMenu = MENU_GROUP_COMMAND:New( playerGroup, "Reset Carrier TCN / ICLS", IntelMenu, requestCarrierBeacon)
            local wipeSpawnedAssets = MENU_GROUP_COMMAND:New( playerGroup, "[DO NOT USE] Wipe All", IntelMenu, requestWipeAllAssets)
            local wipeLastAssets = MENU_GROUP_COMMAND:New( playerGroup, "Wipe last Spawned Assets", IntelMenu, requestWipeLastAsset)

            local groupMenus = { tankerAWACSMenu, carrierBeaconMenu, wipeLastAssets, wipeSpawnedAssets }
            PlayerMenuMap[playerID] = groupMenus
        else
            local deleteGroupMenus = PlayerMenuMap[playerID]
            if deleteGroupMenus ~= nil then
                for i,menu in ipairs(deleteGroupMenus) do
                    menu:Remove()
                end
            end
            PlayerMenuMap[playerID] = nil
        end
    end
end

local function permanentPlayerCheck(something)
    SetPlayer:ForEachClient(
        function (PlayerClient)
            local PlayerID = PlayerClient.ObjectName
            PlayerClient:AddBriefing("Welcome to AAW|APEX Advanced Warfare \\o/!\n\n")
            if PlayerClient:IsAlive() then
                PlayerMap[PlayerID] = true
            else
                PlayerMap[PlayerID] = false
            end
        end
    )
    -- env.info(string.format("BTI: PlayerMap %s", UTILS.OneLineSerialize(PlayerMap))) -- { [P F18 #001] = true/false, }
end

SCHEDULER:New(nil, permanentPlayerCheck, {"Something"}, 3, 10)
SCHEDULER:New(nil, permanentPlayerMenu, {"something"}, 11, 15)

--------------------------------------------------------------------------------------------------------
--- CSAR -----------------------------------------------------------------------------------------------
-- local CSARTrackingPath = "C:\\BTI\\Tracking\\CSARTracking.json"
-- local currentCSARData = { ["records"] = {} }

-- local function loadCSARTracking()
--     local savedCSARBuffer = loadFile(CSARTrackingPath)
--     if savedCSARBuffer ~= nil then
--         local savedCSAR = JSONLib.decode(savedCSARBuffer)
--         currentCSARData = savedCSAR
--         local savedDisabled = savedCSAR["disabled"]
--         if savedDisabled ~= nil then
--             csar.currentlyDisabled = savedDisabled
--             env.info("CSARPersisted: CSAR master file found, applied master " .. UTILS.OneLineSerialize(csar.currentlyDisabled))
--         end
--     else
--         env.info("CSARPersisted: No CSAR master file found, reset in progress")
--     end
-- end

-- local function saveCSARTracking()
--     local master = currentCSARData
--     newCSARJSON = JSONLib.encode(master)
--     saveFile(CSARTrackingPath, newCSARJSON)
--     -- env.info("CSARPersisted: Saved CSARPersisted tracking file " .. UTILS.OneLineSerialize(master))
-- end

-- local function computeSlotList()
--     local slotTable = {}
--     SetSlots:FilterOnce()
--     SetSlots:ForEachClient(
--         function(SlotClient)
--             local slotName = SlotClient.ObjectName
--             table.insert( slotTable, slotName)
--         end
--     )
--     currentCSARData["slots"] = slotTable
--     saveCSARTracking()
-- end
-- loadCSARTracking()
-- computeSlotList()

-- -- Exposed function to Dynamic Loader
-- function saveCSARSlotDisabledEvent(csarCurrentlyDisabled, slotName, crashedPlayerName)
--     env.info("CSAR: disabled " .. UTILS.OneLineSerialize(slotName) .. " by " .. UTILS.OneLineSerialize(crashedPlayerName))
--     currentCSARData["disabled"] = csarCurrentlyDisabled
--     currentCSARData["records"][slotName] = {
--         ["disabled"] = true,
--         ["crashedPlayerName"] = crashedPlayerName,
--     }
--     saveCSARTracking()
-- end
-- function saveCSARSlotEnabledEvent(csarCurrentlyDisabled, slotName, rescuePlayerName)
--     env.info("CSAR: enabled " .. UTILS.OneLineSerialize(slotName) .. " by " .. UTILS.OneLineSerialize(rescuePlayerName))
--     currentCSARData["disabled"] = csarCurrentlyDisabled
--     if (rescuePlayerName == nil) then rescuePlayerName = "God" end
--     currentCSARData["records"][slotName] = {
--         ["disabled"] = false,
--         ["rescuePlayerName"] = rescuePlayerName,
--     }
--     saveCSARTracking()
-- end



-- Regular CSAR init
csar.csarMode = 1

    --      0 - No Limit - NO Aircraft disabling
    --      1 - Disable Aircraft when its down - Timeout to reenable aircraft
    --      2 - Disable Aircraft for Pilot when he's shot down -- timeout to reenable pilot for aircraft
    --      3 - Pilot Life Limit - No Aircraft Disabling -- timeout to reset lives?

csar.maxLives = 8 -- Maximum pilot lives

csar.countCSARCrash = false -- If you set to true, pilot lives count for CSAR and CSAR aircraft will count.

csar.reenableIfCSARCrashes = false -- If a CSAR heli crashes, the pilots are counted as rescued anyway. Set to false to Stop this

-- - I recommend you leave the option on below IF USING MODE 1 otherwise the
-- aircraft will be disabled for the duration of the mission
csar.disableAircraftTimeout = false -- Allow aircraft to be used after 20 minutes if the pilot isnt rescued
csar.disableTimeoutTime = 10 -- Time in minutes for TIMEOUT

csar.destructionHeight = 150 -- height in meters an aircraft will be destroyed at if the aircraft is disabled

csar.enableForAI = false -- set to false to disable AI units from being rescued.

csar.enableForRED = false -- enable for red side

csar.enableForBLUE = true  -- enable for blue side

csar.enableSlotBlocking = true -- if set to true, you need to put the csarSlotBlockGameGUI.lua
-- in C:/Users/<YOUR USERNAME>/DCS/Scripts for 1.5 or C:/Users/<YOUR USERNAME>/DCS.openalpha/Scripts for 2.0
-- For missions using FLAGS and this script, the CSAR flags will NOT interfere with your mission :)

csar.bluesmokecolor = 4 -- Color of smokemarker for blue side, 0 is green, 1 is red, 2 is white, 3 is orange and 4 is blue
csar.redsmokecolor = 1 -- Color of smokemarker for red side, 0 is green, 1 is red, 2 is white, 3 is orange and 4 is blue

csar.requestdelay = 2 -- Time in seconds before the survivors will request Medevac

csar.coordtype = 3 -- Use Lat/Long DDM (0), Lat/Long DMS (1), MGRS (2), Bullseye imperial (3) or Bullseye metric (4) for coordinates.
csar.coordaccuracy = 1 -- Precision of the reported coordinates, see MIST-docs at http://wiki.hoggit.us/view/GetMGRSString
-- only applies to _non_ bullseye coords

csar.immortalcrew = false -- Set to true to make wounded crew immortal
csar.invisiblecrew = false -- Set to true to make wounded crew insvisible

csar.messageTime = 30 -- Time to show the intial wounded message for in seconds

csar.loadDistance = 60 -- configure distance for pilot to get in helicopter in meters.

csar.radioSound = "beacon.ogg" -- the name of the sound file to use for the Pilot radio beacons. If this isnt added to the mission BEACONS WONT WORK!

csar.allowFARPRescue = true --allows pilot to be rescued by landing at a FARP or Airbase

env.info(string.format("BTI: CIA back to the safe house"))

----------------------------------------------------------------------------------------------------------
-- A2A ---------------------------------------------------------------------------------------------------
local A2APatrols = {
    "MirageAlDhafra",
    "J11AlAin",
    "F4AlMinhad",
    "Mig29AlMinhad",
    "Mi28Sharjah"
}

local function randomizeA2A(something)
    local probability = math.random( 1, 2 )
    env.info(string.format( "BTI: A2A probability %d", probability ))
    if probability == 2 then
        local switch = math.random( 1, #A2APatrols)
        env.info(string.format( "BTI: A2A switch %d", switch ))

        if switch == 1 then
            MirageAlDhafra = true
        elseif switch == 2 then
            J11AlAin = true
        elseif switch == 3 then
            F4AlMinhad = true
        elseif switch == 4 then
            Mig29AlMinhad = true
        elseif switch == 5 then
            Mi28Sharjah = true
        end
    end
end

SCHEDULER:New(nil, randomizeA2A, {"something"}, 1200, 3600)



-- INTEL -------------------------------------------------------------------------------------------------
--Backup for future intel
-- function generateIntel(playerGroup)
--         --zones
--     local intelMessage = "|ZONES / AOs|\n"

--     local function weatherStringForCoordinate(coord)
--         local currentPressure = coord:GetPressure(0)
--         local currentTemperature = coord:GetTemperature()
--         local currentWindDirection, currentWindStrengh = coord:GetWind()
--         local weatherString = string.format("Wind from %d@%.1fkts, QNH %.2f, Temperature %d", currentWindDirection, UTILS.MpsToKnots(currentWindStrengh), currentPressure * 0.0295299830714, currentTemperature)
--         return weatherString
--     end

--     return intelMessage
-- end

-- function displayIntelToGroup(playerClient)
--     local playerGroup = playerClient:GetGroup()
--     local intelMessage = generateIntel(playerGroup)
--     MESSAGE:New( intelMessage, 35, "INTEL Report for " .. playerClient:GetPlayerName() .. "\n"):ToGroup(playerGroup)
-- end