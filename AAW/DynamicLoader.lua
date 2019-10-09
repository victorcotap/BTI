local baseDirectory = "C:\\BTI\\AAW\\"

-- Libs ----------------------------------------------------------------------------------------------
JSONLib = dofile("C:\\BTI\\Json.lua")
dofile("C:\\BTI\\Moose.lua")
dofile("C:\\BTI\\CSARPersisted.lua")

-- Lib Hooks -----------------------------------------------------------------------------------------

-- CSAR routing
function CSARSlotDisabledEvent(csarCurrentlyDisabled, slotName, crashedPlayerName)
    saveCSARSlotDisabledEvent(csarCurrentlyDisabled, slotName, crashedPlayerName)
end

function CSARSlotEnabledEvent(csarCurrentlyDisabled, slotName, rescuePlayerName)
    saveCSARSlotEnabledEvent(csarCurrentlyDisabled, slotName, rescuePlayerName)
end


-- Mission scripts ----------------------------------------------------------------------------------
dofile(baseDirectory .. "AAWIntel.lua")
dofile(baseDirectory .. "AAWTracking.lua")
dofile(baseDirectory .. "ZeusData.lua")
dofile(baseDirectory .. "AAWSupport.lua")
dofile(baseDirectory .. "AAWCarrier.lua")
dofile(baseDirectory .. "AAWRange.lua")
