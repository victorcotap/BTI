net.log("TOP: In TOPSlots")
local lfs = require("lfs")

-- IMPORTANT -> Add the name of your server slot booking file below. Path starts in SavedGames/DCS.openbeta/
local TOPSlotsFilePath = lfs.writedir() .. [[ServerBookings.json]]
local TOPLogbookFilePath = lfs.writedir() .. [[Logbook.json]]

if JSONLib == nil then
    JSONLib = dofile("C:\\BTI\\Json.lua")
end

local slotBooking = {}
local slotRules = {}

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

TOPSlotsCallbacks.onGameEvent = function(eventName, playerID, slotID)
    if eventName ~= 'takeoff' and eventName ~= 'self_kill' and eventName ~= 'eject' and eventName ~= 'landing' and eventName ~= 'pilot_death' then
        return -- Return right away if we don't care about such event
    end
    net.log("TOP: onGameEvent " .. eventName)

    local playerInfo = net.get_player_info(playerID)
    local playerUCID = playerInfo["ucid"]
    net.log("TOP: onGameEvent for player ucid " .. playerUCID)
    local playerData = LogbookTable[playerUCID]
    if playerData == nil then
        playerData = {
            ["flights"] = {},
            ["currentTakeoffTime"] = 0
        }
    end

    if eventName == 'takeoff' then
        playerData["currentTakeoffTime"] = os.time()
        net.log("TOP: Setting currentTakeoffTime to " .. tostring(os.time()))
    elseif eventName == 'self_kill' or eventName == 'eject' or eventName == 'landing' or eventName == 'pilot_death' then
        if playerData["currentTakeoffTime"] == 0 then
            net.log("TOP: Logbook event arriving before takeoff event")
        end

        local slotName = DCS.getUnitProperty(slotID, DCS.UNIT_NAME)
        local slotType = DCS.getUnitProperty(slotID, DCS.UNIT_TYPE)
        local landingTime = os.time()
        net.log("TOP: end flight event " .. eventName .. " slotName " .. slotName .. " slotType " .. slotType)
        local flight = {
            ["id"] = tostring(playerData["currentTakeoffTime"]) .. tostring(landingTime),
            ["takeoffTime"] = playerData["currentTakeoffTime"],
            ["landingTime"] = os.time(),
            ["slotName"] = slotName,
            ["slotType"] = slotType,
            ["outcome"] = eventName,
            -- Add score here when figured out what teamkilling looks like
        }
        net.log("TOP: After flight table ready " .. flight["id"])
        table.insert( playerData["flights"], flight )
        net.log("TOP: after insert " .. tostring(#playerData["flights"]))
        playerData["currentTakeoffTime"] = 0 --Maybe we don't need that
        TOPsaveLogbookFile()
        net.log("TOP: Logbook file saved")
    elseif eventName == 'kill' then
        -- check if player gets killed
    elseif eventName == 'disconnect' then
        -- trim data table maybe
    end

    LogbookTable[playerUCID] = playerData
    net.log("TOP: end table takeofftime " .. tostring(LogbookTable[playerUCID]["currentTakeoffTime"]))
    TOPsaveLogbookFile() -- remove that
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
