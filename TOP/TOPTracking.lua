env.info("TOP: Tracking here!")

if JSONLib == nil then
    JSONLib = dofile("C:\\BTI\\Json.lua")
end

local TrackingHandler = EVENTHANDLER:New()

local trackingMaster = {}
local trackingMasterPath = "C:\\BTI\\Tracking\\TrackingFile.json"

---------------------------------------------------------------------------------------
-- Tracking functions -----------------------------------------------------------------------------

SetTrackingGroups = SET_GROUP:New():FilterActive():FilterStart()

local function trackGroup(group, master)
    local groupName = group.GroupName
    local groupData = trackingMaster[groupName]

    if groupName == nil or groupData ~= nil and groupData["alive"] == false then return end

    local groupCoalition = group:GetCoalition()
    local groupCategory = group:GetCategoryName()
    local groupType = group:GetTypeName()
    local groupAlive = group:IsAlive()
    local groupHeading = group:GetHeading()
    local groupHeight = group:GetHeight()

    local groupCoord = group:GetCoordinate()
    local lat, lon, LLDMS, LLDDM, MGRS = nil
    if groupCoord ~= nil then
        lat, lon = coord.LOtoLL(groupCoord:GetVec3())
        LLDMS = groupCoord:ToStringLLDMS()
        LLDDM = groupCoord:ToStringLLDDM()
        MGRS = groupCoord:ToStringMGRS()
    end

    local displayName = nil
    local attributes = nil
    local descAttributes = group:GetDCSDesc()
    if descAttributes ~= nil then
        displayName = descAttributes["displayName"]
        attributes = descAttributes["attributes"]
    end
    if groupName then
        -- env.info("TOP: tracking group data " .. groupName .. " -> " .. UTILS.OneLineSerialize({groupCoalition, groupName, groupCategory, groupType, groupAlive}))
        local groupIsReallyAlive = groupAlive
        trackingMaster[groupName] = {
            ["alive"] = groupIsReallyAlive,
            ["coalition"] = groupCoalition,
            ["category"] = groupCategory,
            ["type"] = groupType,
            ["latitude"] = lat,
            ["longitude"] = lon,
            ["LLDMS"] = LLDMS,
            ["LLDDM"] = LLDDM,
            ["MGRS"] = MGRS,
            ["heading"] = groupHeading,
            ["height"] = groupHeight,
            ["displayName"] = displayName,
            ["attributes"] = attributes,
        }
    end
end

function trackAliveGroups()
    SetTrackingGroups:ForEachGroup(
        function (group)
            trackGroup(group, trackingMaster)
        end
    )
    env.info("TOP: tracking alive finished")
end

function TrackingHandler:onEvent(event)
    if event.id == world.event.S_EVENT_DEAD then
        if event.initiator == nil then
            env.info("TOP: event.initiator was nil, skipping. Thanks ED!")
            return
        end
        if event.initiator.getGroup then
            local dcsGroup = event.initiator:getGroup()
            if not dcsGroup then env.info("TOP: For some reason unit exists but not the group, thanks again ED") end
            local groupName = dcsGroup:getName()
            -- env.info('TOP: Got group name ' .. groupName .. " from event initiator")
            local groupData = trackingMaster[groupName]

            if groupData and groupData["alive"] == true then
                local unitCount = 0
                for i, unit in pairs(dcsGroup:getUnits()) do unitCount = unitCount + 1 end

                -- env.info("TOP: Determined " .. tostring(unitCount) .. " as total unit in group " .. groupName)
                if (unitCount == 1) then
                    groupData["alive"] = false
                    trackingMaster[groupName] = groupData
                    env.info("TOP: Last unit in group " .. groupName .. " was killed, marking dead for Tracking")
                end
            end
        elseif event.initiator.getName then
            local shittyName = event.initiator:getName(event.initiator)
            env.info('TOP: got into the weird case for initiator named ' .. shittyName)
        end
    end
end

function saveMasterTracking(master, masterPath)
    if master == nil then
        env.info("TOP: No master provided for saving")
        return
    end
    local newMasterJSON = JSONLib.encode(master)
    -- env.info("TOP: encoding new master JSON" .. newMasterJSON)
    saveFile(masterPath, newMasterJSON)
end

-- Tracking Engine --------------------------------------------------------
function startTrackingEngine(something)
    local savedMasterBuffer = loadFile(trackingMasterPath)
    if savedMasterBuffer ~= nil then
        local savedMaster = JSONLib.decode(savedMasterBuffer)
        trackingMaster = savedMaster
    else
        env.info("TOP: No Tracking master file found, reset in progress")
    end
    world.addEventHandler(TrackingHandler)
    SCHEDULER:New(nil, trackAliveGroups, {"something"}, 10, 60)

    SCHEDULER:New(nil, saveMasterTracking, {trackingMaster, trackingMasterPath}, 30, 60)
end

SCHEDULER:New(nil, startTrackingEngine, {trackingMaster, trackingMasterPath}, 15)

env.info("TOP: Tracking better than google tracks your location")


--------------------------------------------------------------------------------------------
-- Slot CSAR tracking ----------------------------------------------------------------------
local CSARTrackingPath = "C:\\BTI\\Tracking\\CSARTracking.json"
local currentCSARData = { ["records"] = {} }
local SetSlots = SET_CLIENT:New():FilterCoalitions("blue")


local function loadCSARTracking()
    local savedCSARBuffer = loadFile(CSARTrackingPath)
    if savedCSARBuffer ~= nil and TOPCSARPersistence then
        local savedCSAR = JSONLib.decode(savedCSARBuffer)
        currentCSARData = savedCSAR
        local savedDisabled = savedCSAR["disabled"]
        if savedDisabled ~= nil then
            csar.currentlyDisabled = savedDisabled
            env.info("CSARPersisted: CSAR master file found, applied master " .. UTILS.OneLineSerialize(csar.currentlyDisabled))
        end
    else
        env.info("CSARPersisted: No CSAR master file found, reset in progress")
    end
end

local function saveCSARTracking()
    local master = currentCSARData
    newCSARJSON = JSONLib.encode(master)
    saveFile(CSARTrackingPath, newCSARJSON)
    -- env.info("CSARPersisted: Saved CSARPersisted tracking file " .. UTILS.OneLineSerialize(master))
end

local function computeSlotList()
    if not TOPCSARPersistence then return end
    local slotTable = {}
    SetSlots:FilterOnce()
    SetSlots:ForEachClient(
        function(SlotClient)
            env.info("CSARPersisted: computing slot  " .. UTILS.OneLineSerialize(SlotClient))
            local slotName = SlotClient.ObjectName
            table.insert( slotTable, slotName)
        end
    )
    currentCSARData["slots"] = slotTable
    saveCSARTracking()
end
loadCSARTracking()
computeSlotList()

-- Exposed function to Dynamic Loader
function saveCSARSlotDisabledEvent(csarCurrentlyDisabled, slotName, crashedPlayerName)
    env.info("CSAR: disabled " .. UTILS.OneLineSerialize(slotName) .. " by " .. UTILS.OneLineSerialize(crashedPlayerName))
    currentCSARData["disabled"] = csarCurrentlyDisabled
    currentCSARData["records"][slotName] = {
        ["disabled"] = true,
        ["crashedPlayerName"] = crashedPlayerName,
    }
    saveCSARTracking()
end
function saveCSARSlotEnabledEvent(csarCurrentlyDisabled, slotName, rescuePlayerName)
    env.info("CSAR: enabled " .. UTILS.OneLineSerialize(slotName) .. " by " .. UTILS.OneLineSerialize(rescuePlayerName))
    currentCSARData["disabled"] = csarCurrentlyDisabled
    if (rescuePlayerName == nil) then rescuePlayerName = "God" end
    currentCSARData["records"][slotName] = {
        ["disabled"] = false,
        ["rescuePlayerName"] = rescuePlayerName,
    }
    saveCSARTracking()
end