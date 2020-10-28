net.log("TOP: In TOPSlots")
local lfs = require("lfs")

-- IMPORTANT -> Add the name of your server slot booking file below. Path starts in SavedGames/DCS.openbeta/
local TOPSlotsFilePath = lfs.writedir() .. [[ServerBookings.json]]
-- local TOPLogbookFilePath = lfs.writedir() .. [[Logbook.json]]
local TOPLogbookFilePath = "C:\\BTI\\Tracking\\Logbook.json"

if JSONLib == nil then
    JSONLib = dofile("C:\\BTI\\Json.lua")
end

local slotBooking = {}
local slotRules = {}

--- Business Logic utils --------------------------------------------------------------------------------------------
local function basePlayerData()
    return {
        ["flights"] = {},
        ["currentTakeoffTime"] = 0,
        ["currentTakeoffAirdromeName"] = nil,
        ["currentFriendlyFire"] = 0,
        ["vehicles"] = 0,
        ["planes"] = 0,
        ["ships"] = 0,
        ["score"] = 0,
    }
end

local function getPlayerStat(playerID, statID)
    local stat = net.get_stat(playerID, statID)
    net.log("TOP: Player " .. playerID .. " STAT " .. statID  .. " value " .. tostring(stat))
    if stat == nil then
        return 0
    end
    return stat
end
--- CALLBACKS -------------------------------------------------------------------------------------------------------
local TOPSlotsCallbacks = {}

TOPSlotsCallbacks.onPlayerTryChangeSlot = function(playerID, side, slotID)
    if DCS.isServer() and DCS.isMultiplayer() then
        net.log("TOP: onPlayerTryChangeSlot")
        local playerSlot = DCS.getUnitProperty(slotID, DCS.UNIT_GROUPNAME)
        local playerInfo = net.get_player_info(playerID)
        local playerUCID = playerInfo.ucid
        local playerName = playerInfo.name

        net.log(
            "TOP: Player selected slot: " ..
                playerName .. " side:" .. side .. " slot: " .. playerSlot .. " ucid: " .. playerUCID
        )

        local currentTime = os.time()
        for _, booking in pairs(slotBooking) do
            local slotKey = booking["slot"]["nameKey"]
            local pilotUCID = booking["pilot"]["playerUCID"]
            local fromTime = booking["fromDate"]
            local toTime = booking["toDate"]

            net.log("TOP: booking " .. slotKey)
            if slotKey == playerSlot then
                net.log("TOP: Correct slot")
                net.log(string.format("TOP: current %d fromDate %d toDate %d", currentTime, fromTime, toTime))
                if currentTime > fromTime and currentTime < toTime then
                    net.log("TOP: Correct time")
                    if pilotUCID == playerUCID then
                        net.send_chat_to("I knew you would show up, son...", playerID)
                        return true
                    else
                        net.send_chat_to("Sorry this slot is currently booked on DCSSuperCareer.online", playerID)
                        return false
                    end
                end
            end
        end
        for _, slotRule in pairs(slotRules) do
            net.log("TOP: checking rule " .. slotRule["match"])
            if slotRule["block"] == true then
                local ruleMatch = string.lower(slotRule["match"])
                local slotMatch = string.lower(playerSlot)
                if string.find(slotMatch, ruleMatch, 1, true) ~= nil then
                    net.log("TOP: Match, blocking slot " .. playerSlot .. "from rule " .. ruleMatch)
                    net.send_chat_to("Sorry this slot requires a booking from DCSSuperCareer.online", playerID)
                    return false
                end
            end
        end
    end
end

local LogbookTable = {}

TOPSlotsCallbacks.onGameEvent = function(eventName, playerID, arg3, arg4)
    if
        eventName ~= "takeoff" and eventName ~= "self_kill" and eventName ~= "eject" and eventName ~= "landing" and
            eventName ~= "pilot_death" and eventName ~= "friendly_fire"
     then
        return -- Return right away if we don't care about such event
    end
    -- net.log("TOP: onGameEvent " .. eventName)

    local playerInfo = net.get_player_info(playerID)
    local playerUCID = playerInfo["ucid"]
    -- net.log("TOP: onGameEvent for player ucid " .. playerUCID)
    local playerData = LogbookTable[playerUCID]
    if playerData == nil then -- Create playerData for the UCID if it doesn't exist yet
        playerData = basePlayerData() -- Zero-ed out player score tracking and flights array
    end

    if eventName == "takeoff" then
        playerData["currentTakeoffTime"] = os.time()
        playerData["currentTakeoffAirdromeName"] = arg4
        net.log("TOP: Setting currentTakeoffTime to " .. tostring(os.time() .. " for " .. playerID))
    elseif eventName == "self_kill" or eventName == "eject" or eventName == "landing" or eventName == "pilot_death" then
        if playerData["currentTakeoffTime"] == 0 then
            net.log("TOP: Logbook event arriving before takeoff event")
        end

        local slotID = arg3
        local slotName = DCS.getUnitProperty(slotID, DCS.UNIT_NAME)
        local slotType = DCS.getUnitProperty(slotID, DCS.UNIT_TYPE)
        local landingTime = os.time()
        local vehicles = getPlayerStat(playerID, net.PS_CAR)
        local ships = getPlayerStat(playerID, net.PS_SHIP)
        local planes = getPlayerStat(playerID, net.PS_PLANE)
        local score = getPlayerStat(playerID, net.PS_SCORE)

        net.log("TOP: end flight event " .. eventName .. " slotName " .. slotName .. " slotType " .. slotType)
        -- net.log("TOP: stats: score " .. tostring(score) .. " vehicles " .. tostring(vehicles) .. " planes " .. tostring(planes) .. " ships" .. tostring(ships) .. " teamkill " .. tostring(playerData["currentFriendlyFire"]))
        local flight = {
            ["id"] = tostring(playerData["currentTakeoffTime"]) .. tostring(landingTime),
            ["takeoffTime"] = playerData["currentTakeoffTime"],
            ["takeoffAirdrome"] = playerData["currentTakeoffAirdromeName"], -- may be nil
            ["landingTime"] = os.time(),
            ["landingAirdrome"] = arg4, --may be nil
            ["slotName"] = slotName,
            ["slotType"] = slotType,
            ["outcome"] = eventName,
            ["vehicles"] = vehicles - playerData["vehicles"],
            ["planes"] = planes - playerData["planes"],
            ["ships"] = ships - playerData["ships"],
            ["score"] = score - playerData["score"],
            ["friendlyFire"] = playerData["currentFriendlyFire"]
        }
        -- net.log("TOP: After flight table ready " .. flight["id"])
        table.insert(playerData["flights"], flight)
        -- net.log("TOP: after insert " .. tostring(#playerData["flights"]))

        -- Saving data to compare for next flight in the session
        playerData["vehicles"] = vehicles
        playerData["planes"] = planes
        playerData["ships"] = ships
        playerData["score"] = score
        playerData["currentTakeoffTime"] = 0 -- resetting this as a flag
        playerData["currentFriendlyFire"] = 0
        TOPsaveLogbookFile()
        net.log("TOP: Logbook file saved")
    elseif eventName == "friendly_fire" then
        playerData["currentFriendlyFire"] = playerData["currentFriendlyFire"] + 1
        -- check if player gets killed
    end

    LogbookTable[playerUCID] = playerData
    -- net.log("TOP: end table takeofftime " .. tostring(LogbookTable[playerUCID]["currentTakeoffTime"]))
    -- TOPsaveLogbookFile() -- remove that
    return --Return nothing to let other hooks take over
end

TOPSlotsCallbacks.onPlayerTrySendChat = function(playerID, message, all) --new definition
    if message == "-ucid" then
        local ucid = net.get_player_info(playerID, "ucid")
        local name = net.get_player_info(playerID, "name")
        net.log("TOP: Player" .. name .. " trying to access ucid " .. ucid)
        net.send_chat_to("Your UCID is " .. ucid .. " . This message is only sent to you " .. name, playerID)
        return ""
    end
end
-----------------------------------------------------------------------------------------------------------------------
----JSON Files---------------------------------------------------------------------------------------------------------

--- READ SLOT BOOKING FILE1
local function readSlotsFile()
    local savedSlotBookingMaster = loadFile(TOPSlotsFilePath)
    master = JSONLib.decode(savedSlotBookingMaster)
    slotBooking = master["bookings"]
    slotRules = master["slotRules"]
end

-- This
function TOPsaveLogbookFile()
    net.log("TOP: Trying to encode LogbookTable " .. tostring(#LogbookTable))
    local master = JSONLib.encode(LogbookTable)
    net.log("TOP: Logbook master " .. master)
    saveFile(TOPLogbookFilePath, master)
    net.log("TOP: Logbook save complete")
end

local function wipeLogbookFile()
    local emptyTable = {}
    master = JSONLib.encode(emptyTable)
    saveFile(TOPLogbookFilePath, master)
end
-----------------------------------------------------------------------------------------------------------------------
--- UTILS -------------------------------------------------------------------------------------------------------------

--- START HOOK
DCS.setUserCallbacks(TOPSlotsCallbacks)
readSlotsFile() -- PUT THAT ON A TIMER FOR REFRESH
wipeLogbookFile()
net.log("TOP: TOPSlots are hooked")

--DEBUG
-- local slotID = "F16A"
-- local currentTime = os.time()
-- for _, booking in pairs(slotBooking) do
--     local slotKey = booking["slot"]["nameKey"]
--     local pilotUCID = booking["pilot"]["playerUCID"]
--     local fromTime = booking["fromDate"]
--     local fromTime = booking["toDate"]

--     net.log("TOP: booking " .. slotKey)
--     if slotKey == slotID then
--         if currentTime > fromDate and currentTime < toDate then
--             if pilotUCID == ucid then
--                 return true
--             else
--                 return false
--             end
--         end
--     end
-- end
