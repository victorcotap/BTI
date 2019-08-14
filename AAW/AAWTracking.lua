env.info("BTI: Tracking here!")

local trackingMaster = {}
-- local persistenceMaster = {}
local trackingMasterPath = "C:\\BTI\\TrackingFile.json"
-- local persistenceMasterPath = "C:\\BTI\\PersistenceMaster.json"


-- debug -----------------------------------------------


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
    local properties = nil
    local attributes = group:GetDCSDesc()
    if attributes ~= nil then
        displayName = attributes["displayName"]
        properties = attributes["attributes"]
    end
    if groupName then
        -- env.info("BTI: tracking group data " .. groupName .. " -> " .. UTILS.OneLineSerialize({groupCoalition, groupName, groupCategory, groupType, groupAlive}))
        master[groupName] = {
            ["alive"] = groupAlive,
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
            ["properties"] = properties,
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

function generateMaster()
end

function applyMaster(master)
    env.info("BTI: apply master")
    for groupName, group in pairs(master) do
        local persistedGroup = master[groupName]
        local dcsGroup = GROUP:FindByName(groupName)
        if dcsGroup ~= nil then
            if group["alive"] == nil or group["alive"] == false then
                env.info("BTI: Destroying dead group" .. groupName)
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
    local savedMasterBuffer = loadFile(trackingMasterPath)
    if savedMasterBuffer ~= nil then
        local savedMaster = JSONLib.decode(savedMasterBuffer)
        applyMaster(savedMaster)
    else
        env.info("BTI: No Tracking master file found, reset in progress")
    end
    SCHEDULER:New(nil, trackAliveGroups, {"something"}, 5, 30)

    SCHEDULER:New(nil, computePersistenceGroups, {"something"}, 10, 60)
   
    SCHEDULER:New(nil, saveMasterTracking, {trackingMaster, trackingMasterPath}, 30, 60)

end

startTrackingEngine()

env.info("BTI: Tracking better than google tracks your location")