env.info("BTI: Tracking here!")

local master = {}
local masterPath = "C:\\BTI\\MasterFile.json"

-- debug -----------------------------------------------
-- json = require "json"
-- local json = dofile('json.lua')
-- env.info("BTI: After json")
-- UTILS.OneLineSerialize({"toto", "tata"})
-- -- local toto = JSONLib.decode('[1,2,3,{"x":10}]')
-- local toto = JSONLib.decode('{"toto" : 2, "tata": 4}')

-- UTILS.OneLineSerialize(toto)
-- env.info("BTI: env toto ", toto)
-- local encoded = JSONLib.encode(toto)
-- env.info("BTI: env encode " .. encoded)

master = {
    ["Coast"] = {
        [1] = {
            ["ZoneName"] = "Kessel",
            ["Coalition"] = 1,
            ["SideMissions"] = 1
        },
        [2] = {
            ["ZoneName"] = "Felucia",
            ["Coalition"] = 1,
            ["SideMissions"] = 2
        },
    },
    ["AAAAA"] = "Test String",
    ["Resources"] = {
        ["tank"] = 10,
        ["arty"] = 10,
        ["apc"] = 10,
        ["repair"] = 10,
        ["result"] = 234356
    },
    ["Support"] = {
        ["Helos"] = 2
    }
}


-- File functions -----------------------------------------------------------------------------
function loadFile(path)
    local file, err = io.open(path, "r")
    local buffer, error = file:read("*a")
    if err ~= nil then
        env.info("BTI: Error loading tracking master file" .. error)
    end
    return buffer
end

function saveFile(path, buffer)
    local file,err = io.open( path, "wb" )
    file:write(buffer)
    file:close()
end

-- Tracking functions -----------------------------------------------------------------------------

SetGroups = SET_GROUP:New():FilterCoalitions("red"):FilterCategoryGround():FilterStart()

function trackGroups()
    env.info("BTI: trackikng groups")
    SetGroups:ForEachGroup(
        function (group)
            local groupName = group.GroupName
            local groupCoord = group:GetCoordinate()
            local lat, lon = coord.LOtoLL(groupCoord:GetVec3())
            local groupAlive = group:IsAlive()
            if groupName and lat and lon then
                env.info(string.format("BTI: Tracking group %s alive %s coord lat %f lon %f", groupName, tostring(groupAlive), lat, lon))
                master[groupName] = {
                    ["alive"] = groupAlive,
                    ["latitude"] = lat,
                    ["longitude"] = lon 
                }
            end
        end
    )
    env.info("BTI: trackikng finished")

end

function applyMaster(master)
    env.info("BTI: apply master")
end

function saveMasterTracking()
    local newMasterJSON = JSONLib.encode(master)
    env.info("BTI: encoding new master JSON" .. newMasterJSON)
    saveFile(masterPath, newMasterJSON)
end

-- Tracking Engine --------------------------------------------------------
function startTrackingEngine()
    local savedMasterBuffer = loadFile(masterPath)
    if savedMasterBuffer ~= nil then
        local savedMaster = JSONLib.decode(savedMasterBuffer)
        applyMaster(savedMaster)
    else
        env.info("BTI: No Tracking master file found")
    end
    SCHEDULER:New(nil, trackGroups, {"something"}, 4)
    -- SCHEDULER:New(nil, saveMasterTracking, {"something"}, 10)
end

local masterJSON = JSONLib.encode(master)
env.info("BTI: Master JSON " .. masterJSON)
saveFile(masterPath, masterJSON)

startTrackingEngine()


env.info("BTI: Tracking better than google tracks your location")