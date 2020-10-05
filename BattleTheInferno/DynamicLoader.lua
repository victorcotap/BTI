local baseDirectory = "C:\\BTI\\AAW\\"
local libDirectory = "C:\\BTI\\TOP\\"

-- Libs ----------------------------------------------------------------------------------------------
JSONLib = dofile("C:\\BTI\\Json.lua")
dofile("C:\\BTI\\Moose.lua")
dofile("C:\\BTI\\CSARPersisted.lua")
-- TOPLib
TOPGroupPersistence = false
TOPCSARPersistence = false
dofile(libDirectory .. "TOPTracking.lua")

-- Lib Hooks -----------------------------------------------------------------------------------------

-- CSAR routing
-- function CSARSlotDisabledEvent(csarCurrentlyDisabled, slotName, crashedPlayerName)
--     saveCSARSlotDisabledEvent(csarCurrentlyDisabled, slotName, crashedPlayerName)
-- end

-- function CSARSlotEnabledEvent(csarCurrentlyDisabled, slotName, rescuePlayerName)
--     saveCSARSlotEnabledEvent(csarCurrentlyDisabled, slotName, rescuePlayerName)
-- end


-- Mission scripts ----------------------------------------------------------------------------------
-- dofile(baseDirectory .. "AAWIntel.lua")
-- dofile(baseDirectory .. "ZeusData.lua")
-- dofile(baseDirectory .. "AAWSupport.lua")
-- dofile(baseDirectory .. "AAWCarrier.lua")
-- dofile(baseDirectory .. "AAWRange.lua")
