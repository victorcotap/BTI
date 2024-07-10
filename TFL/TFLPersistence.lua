env.info("TFL: Persistence engine is back from the dead!")

-- Constants
local persistenceMasterKey = "persistenceMaster"

--initializer
local persistenceMaster = LOCALGet(persistenceMasterKey)
if persistenceMaster == nil then
  persistenceMaster = {}
end

SetPersistenceGroups = SET_GROUP:New():FilterCoalitions("red"):FilterStart()

local function trackGroup(group, master)
    local groupName = group.GroupName
    local groupCoalition = group:GetCoalition()
    local groupData = persistenceMaster[groupName]

    -- Protect against a group coming back to life (thanks ED)
    if groupName == nil or groupData ~= nil and groupData["alive"] == false then
        env.info("TFL: Group is already marked as dead, skipping dead detection " .. groupName)
        return
    end

    local dcsGroup = Group.getByName(groupName)
    local groupNotAlive = group:IsAlive() == nil
    if groupNotAlive == false then
            -- env.info("TOP: MOOSE IsAlive() " .. groupName .. " " .. tostring(groupNotAlive))
    end

    persistenceMaster[groupName] = {
        ["alive"] = not groupNotAlive,
        ["coalition"] = groupCoalition
    }
end

local function trackPersistenceGroups()
    SetPersistenceGroups:ForEachGroup(
        function(group)
            trackGroup(group, persistenceMaster)
        end
    )
    LOCALStore(persistenceMasterKey, persistenceMaster)
    -- env.info("TFL: tracking alive finished")
end

local function applyMaster(master)
    env.info("TFL: Persistence is applying master")
    for groupName, group in pairs(master) do
        local persistedGroup = master[groupName]
        local dcsGroup = GROUP:FindByName(groupName)
        if dcsGroup ~= nil then
            if group["alive"] == nil or group["alive"] == false then
                env.info("TFL: Destroying dead group" .. groupName)
                dcsGroup:Destroy()
            end
        elseif group["alive"] == nil or group["alive"] == false then
            env.info("TFL: Couldn't find dead group " .. groupName .. "to apply master to")
        end
    end
end

if persistenceMaster ~= nil then
  applyMaster(persistenceMaster)
end
SCHEDULER:New(nil, trackPersistenceGroups, {"something"}, 15, 60)


env.info("TFL: Persistence engine has finished playing god")