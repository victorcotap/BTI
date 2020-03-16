env.info("BTI: Tracking here!")

if JSONLib == nil then
    JSONLib = dofile("C:\\BTI\\Json.lua")
end

local trackingMaster = {}
local trackingMasterPath = "C:\\BTI\\Tracking\\TrackingFile.json"

---------------------------------------------------------------------------------------
-- Tracking functions -----------------------------------------------------------------------------

local function trackGroup(group, master)
    local groupName = group.GroupName
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
        -- env.info("BTI: tracking group data " .. groupName .. " -> " .. UTILS.OneLineSerialize({groupCoalition, groupName, groupCategory, groupType, groupAlive}))
        local groupData = trackingMaster[groupName]
        local groupIsReallyAlive = groupAlive
        if groupData ~= nil and groupData["alive"] == false then
            groupIsReallyAlive = false
        end
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

SetTrackingGroups = SET_GROUP:New():FilterActive():FilterStart()

function trackAliveGroups()
    SetTrackingGroups:ForEachGroup(
        function (group)
            trackGroup(group, trackingMaster)
        end
    )
    env.info("BTI: tracking alive finished")
end

function computePersistenceGroups()
    for groupName, group in pairs(trackingMaster) do
        if group["alive"] and group["coalition"] == 1 then
            local dcsGroup = GROUP:FindByName(groupName)

            if dcsGroup ~= nil then
                local groupUnits = dcsGroup:GetUnits()
                if groupUnits == nil or #groupUnits == 0 then
                    env.info("BTI: can't find units marking group as dead")
                    trackingMaster[groupName]["alive"] = false
                end
            else
                env.info("BTI: can't find group, marking group as dead")
                trackingMaster[groupName]["alive"] = false
            end
        end
    end
    env.info("BTI: tracking persistence finished")
end


local function applyMaster(master)
    env.info("BTI: apply master")
    for groupName, group in pairs(master) do
        local persistedGroup = master[groupName]
        local dcsGroup = GROUP:FindByName(groupName)
        if dcsGroup ~= nil then
            if group["alive"] == nil or group["alive"] == false then
                env.info("BTI: Destroying dead group" .. groupName)
                dcsGroup:Destroy()
            end
        elseif group["alive"] == nil or group["alive"] == false then
            env.info("BTI: Couldn't find dead group " .. groupName .. "to apply master to")
        end
    end
    -- TODO foreach group of master, check if alive and destroy if not
end

function saveMasterTracking(master, masterPath)
    if master == nil then
        env.info("BTI: No master provided for saving")
        return
    end
    local newMasterJSON = JSONLib.encode(master)
    -- env.info("BTI: encoding new master JSON" .. newMasterJSON)
    saveFile(masterPath, newMasterJSON)
end

-- Tracking Engine --------------------------------------------------------
function startTrackingEngine(something)
    local savedMasterBuffer = loadFile(trackingMasterPath)
    if savedMasterBuffer ~= nil and TOPGroupPersistence then
        local savedMaster = JSONLib.decode(savedMasterBuffer)
        applyMaster(savedMaster)
        trackingMaster = savedMaster
    else
        env.info("BTI: No Tracking master file found, reset in progress")
    end
    SCHEDULER:New(nil, trackAliveGroups, {"something"}, 10, 60)

    SCHEDULER:New(nil, computePersistenceGroups, {"something"}, 15, 60)

    SCHEDULER:New(nil, saveMasterTracking, {trackingMaster, trackingMasterPath}, 30, 60)

end

SCHEDULER:New(nil, startTrackingEngine, {trackingMaster, trackingMasterPath}, 10)
-- startTrackingEngine()

env.info("BTI: Tracking better than google tracks your location")


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
    local slotTable = {}
    SetSlots:FilterOnce()
    SetSlots:ForEachClient(
        function(SlotClient)
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