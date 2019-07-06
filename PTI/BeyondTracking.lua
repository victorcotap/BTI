env.info("BTI: Tracking here!")

local trackingMaster = {}
local persistenceMaster = {}
local trackingMasterPath = "C:\\BTI\\TrackingFile.json"
local persistenceMasterPath = "C:\\BTI\\PersistenceMaster.json"


-- debug -----------------------------------------------
persistenceMaster = {
    ["AAAAA"] = "Test String",
    ["Support"] = {
        ["Helos"] = 2
    }
}


-- File functions -----------------------------------------------------------------------------
function loadFile(path)
    local file, err = io.open(path, "r")
    if err ~= nil then
        env.info("BTI: Error loading tracking master file" .. err)
        return nil
    end

    local buffer, error = file:read("*a")
    return buffer
end

function saveFile(path, buffer)
    local file,err = io.open( path, "wb" )
    file:write(buffer)
    file:close()
end

-- Tracking functions -----------------------------------------------------------------------------

function trackGroup(group, master)
    local groupName = group.GroupName
    local groupCoalition = group:GetCoalition()
    local groupCategory = group:GetCategoryName()
    local groupType = group:GetTypeName()
    local groupAlive = group:IsAlive()

    local groupCoord = group:GetCoordinate()
    local lat, lon = nil
    if groupCoord ~= nil then
        lat, lon = coord.LOtoLL(groupCoord:GetVec3())
    end
    if groupName then
        env.info("BTI: tracking group data " .. groupName .. " -> " .. UTILS.OneLineSerialize({groupName, groupCategory, groupType, groupAlive}))
        master[groupName] = {
            ["alive"] = groupAlive,
            ["coalition"] = groupCoalition,
            ["category"] = groupCategory,
            ["type"] = groupType,
            ["latitude"] = lat,
            ["longitude"] = lon
        }
    end
end

SetPersistenceGroups = SET_GROUP:New():FilterCoalitions("red"):FilterCategoryGround():FilterStart()
SetTrackingGroups = SET_GROUP:New():FilterStart()

function trackAliveGroups()
    SetTrackingGroups:ForEachGroup(
        function (group)
            trackGroup(group, trackingMaster)
        end
    )
    env.info("BTI: tracking alive finished")
end

function trackPersistenceGroups()
    SetPersistenceGroups:ForEachGroup(
        function (group)
            trackGroup(group, persistenceMaster)
        end
    )
    env.info("BTI: tracking persistence finished")
end

function applyMaster(master)
    env.info("BTI: apply master")
    persistenceMaster = master
    for groupName, group in pairs(persistenceMaster) do
        env.info("BTI: Found group persisted " .. groupName .. ": " .. UTILS.OneLineSerialize(group))
        local persistedGroup = persistenceMaster[groupName]
        local dcsGroup = GROUP:FindByName(groupName)
        if dcsGroup ~= nil then
            if group["alive"] == nil or group["alive"] == false then
                dcsGroup:Destroy()
            end
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
    env.info("BTI: encoding new master JSON" .. newMasterJSON)
    saveFile(masterPath, newMasterJSON)
end

-- Tracking Engine --------------------------------------------------------
function startTrackingEngine()
    local savedMasterBuffer = loadFile(persistenceMasterPath)
    if savedMasterBuffer ~= nil then
        local savedMaster = JSONLib.decode(savedMasterBuffer)
        applyMaster(savedMaster)
    else
        env.info("BTI: No Tracking master file found")
    end
    SCHEDULER:New(nil, trackPersistenceGroups, {"something"}, 4, 45)
    SCHEDULER:New(nil, saveMasterTracking, {persistenceMaster, persistenceMasterPath}, 10, 80)
   
    SCHEDULER:New(nil, trackAliveGroups, {"something"}, 30, 60)
    SCHEDULER:New(nil, saveMasterTracking, {trackingMaster, trackingMasterPath}, 20, 90)

end

startTrackingEngine()

env.info("BTI: Tracking better than google tracks your location")