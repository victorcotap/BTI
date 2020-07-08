env.info("TOP: Persistence here! OHAI")

if JSONLib == nil then
    JSONLib = dofile("C:\\BTI\\Json.lua")
end

local PersistenceHandler = EVENTHANDLER:New()

local persistenceMaster = {}
local persistenceMasterPath = "C:\\BTI\\Tracking\\PersistenceFile.json"

SetPersistenceGroups = SET_GROUP:New():FilterCoalitions("red"):FilterStart()

local function trackGroup(group, master)
    local groupName = group.GroupName
    local groupCoalition = group:GetCoalition()
    local groupData = persistenceMaster[groupName]

    -- Protect against a group coming back to life (thanks ED)
    if groupName == nil or groupData ~= nil and groupData["alive"] == false then
        env.info("TOP: Group is already marked as dead, skipping dead detection " .. groupName)
        persistenceMaster[groupName] = {
            ["alive"] = false,
            ["coalition"] = groupCoalition
        }
        return
    end

    local dcsGroup = Group.getByName(groupName)
    local groupAlive = group:IsAlive()
    -- env.info("TOP: MOOSE IsAlive() " .. groupName .. " " .. tostring(groupAlive))

    if dcsGroup then
        if dcsGroup and dcsGroup:isExist() and dcsGroup:getSize() > 0 then
            -- env.info("TOP: Group " .. groupName .. " is considered alive size " .. tostring(dcsGroup:getSize()) )
            groupAlive = true
        else
            env.info("TOP: Persistence can't find units marking group " .. groupName .. " as dead")
            groupAlive = false
        end
    else
        groupAlive = false
        env.info("TOP: Persistence can't find group, marking group " .. groupName .. "  as dead")
    end

    persistenceMaster[groupName] = {
        ["alive"] = groupAlive,
        ["coalition"] = groupCoalition
    }

    -- if groupName then
    --     -- env.info("TOP: tracking group data " .. groupName .. " -> " .. UTILS.OneLineSerialize({groupCoalition, groupName, groupCategory, groupType, groupAlive}))

    --     if dcsGroup ~= nil then
    --         local groupUnits = dcsGroup:getUnits()
    --         if groupUnits == nil or #groupUnits < 1 then
    --             env.info("TOP: Persistence can't find units marking group " .. groupName .. " as dead")
    --             groupIsReallyAlive = false
    --         end
    --     else
    --         env.info("TOP: Persistence can't find group, marking group " .. groupName .. "  as dead")
    --         groupIsReallyAlive = false
    --     end

    --     persistenceMaster[groupName] = {
    --         ["alive"] = groupIsReallyAlive,
    --         ["coalition"] = groupCoalition
    --     }
    -- end
end

function trackPersistenceGroups()
    SetPersistenceGroups:ForEachGroup(
        function(group)
            trackGroup(group, persistenceMaster)
        end
    )
    env.info("TOP: tracking alive finished")
end

function PersistenceHandler:onEvent(event)
    if event.id == world.event.S_EVENT_DEAD then
        if event.initiator == nil then
            env.info("TOP: event.initiator was nil, skipping. Thanks ED!")
            return
        end
        if event.initiator.getGroup then
            local dcsGroup = event.initiator.getGroup()
            if not dcsGroup then env.info("TOP: For some reason unit exists but not the group, thanks again ED") end
            local groupName = dcsGroup.getName()
            env.info('TOP: Got group name ' .. groupName .. " from event initiator")
            local groupData = persistenceMaster[groupName]

            if groupData and groupData["alive"] == true then
                local unitCount = 0
                for i, unit in pairs(dcsGroup:getUnits()) do unitCount = unitCount + 1 end

                env.info("TOP: Determined " .. tostring(unitCount) .. " as total unit in group " .. groupName)
                if (unitCount == 0) then
                    persistenceMaster[groupName] = {
                        ["alive"] = false,
                        ["coalition"] = groupCoalition
                    }
                end
            end
        elseif event.initiator.getName then
            local shittyName = event.initiator.getName(event.initiator)
            env.info('TOP: got into the weird case for initiator named ' .. shittyName)
        end
    end
end

local function applyMaster(master)
    env.info("TOP: Persistence is applying master")
    for groupName, group in pairs(master) do
        local persistedGroup = master[groupName]
        local dcsGroup = GROUP:FindByName(groupName)
        if dcsGroup ~= nil then
            if group["alive"] == nil or group["alive"] == false then
                env.info("TOP: Destroying dead group" .. groupName)
                dcsGroup:Destroy()
            end
        elseif group["alive"] == nil or group["alive"] == false then
            env.info("TOP: Couldn't find dead group " .. groupName .. "to apply master to")
        end
    end
end

function saveMasterPersistence(master, masterPath)
    if master == nil then
        env.info("TOP: No master provided for saving")
        return
    end
    local newMasterJSON = JSONLib.encode(master)
    saveFile(masterPath, newMasterJSON)
end

-- Tracking Engine --------------------------------------------------------
function startPersistenceEngine(something)
    local savedMasterBuffer = loadFile(persistenceMasterPath)
    if savedMasterBuffer ~= nil and TOPGroupPersistence then
        local savedMaster = JSONLib.decode(savedMasterBuffer)
        applyMaster(savedMaster)
        persistenceMaster = savedMaster
    else
        env.info("TOP: No Tracking master file found, reset in progress")
    end
    -- Start the dead event handler once we killed everything
    world.addEventHandler(PersistenceHandler)
    SCHEDULER:New(nil, trackPersistenceGroups, {"something"}, 10, 30)

    SCHEDULER:New(nil, saveMasterPersistence, {persistenceMaster, persistenceMasterPath}, 30, 60)
end

SCHEDULER:New(nil, startPersistenceEngine, {trackingMaster, trackingMasterPath}, 10)

env.info("TOP: Persistence better than your girlfriend remember you looking at someone else's ass")
