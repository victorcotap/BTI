net.log("TOP: In TOPSlots")
local lfs = require('lfs')

-- IMPORTANT -> Add the name of your server slot booking file beloew. Path starts in SavedGames/DCS.openbeta/
local TOPSlotsFilePath = lfs.writedir()..[[ServerBookings.json]]


if JSONLib == nil then
    JSONLib = dofile("C:\\BTI\\Json.lua")
end

local slotBooking = {}

--- CALLBACKS -------------------------------------------------------------------------------------------------------
local TOPSlotsCallbacks = {}

TOPSlotsCallbacks.onPlayerTryChangeSlot = function(playerID, side, slotID)
    if  DCS.isServer() and DCS.isMultiplayer() then
        local ucid = net.get_player_info(playerID, 'ucid')
        local playerName = net.get_player_info(playerID, 'name')
        local unitRole = DCS.getUnitType(slotID)

        net.log("TOP: Player selected slot: ".._playerName.." side:"..side.." slot: "..slotID.." ucid: ".._ucid)

        -- check slot booking
            -- if yes check date is now
                -- if yes check the pilot
                -- return null or reject accordingly

    end
    return
end

TOPSlotsCallbacks.onPlayerTrySendChat = function(playerID, message, all)  --new definition
    if message == "-ucid" then
        local ucid = net.get_player_info(playerID, 'ucid')
        local name = net.get_player_info(playerID, 'name')

        net.send_chat_to("Your UCID is " .. ucid .. " . This message is only sent to you " .. name, playerID)
        return 'toto'
    end

    return message
end
-----------------------------------------------------------------------------------------------------------------------

--- READ SLOT BOOKING FILE
local function readSlotsFile()
    local savedSlotBookingMaster = loadFile(TOPSlotsFilePath)
    net.log("TOP: saved file " .. savedSlotBookingMaster)
    local slotTable = JSONLib.decode(savedSlotBookingMaster)
    net.log("TOP: decoded json slots " .. tostring(slotTable))
    -- local dcsTable = net.json2lua(savedSlotBookingMaster)
    -- net.log("TOP: decoded slots " .. oneLineSerialize(dcsTable))
    slotBooking = slotTable
end
-----------------------------------------------------------------------------------------------------------------------
--- UTILS -------------------------------------------------------------------------------------------------------------


--- START HOOK
DCS.setUserCallbacks(TOPSlotsCallbacks)
readSlotsFile()
net.log("TOP: TOPSlots are hooked")
