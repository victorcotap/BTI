env.info(string.format("BTI: Beginning CIA surveillance..."))

-- Utils ---------------------------------------------------------------
local function ternary ( cond , T , F )
    if cond then return T else return F end
end

PlayerMap = {}
local PlayerMenuMap = {}

SetPlayer = SET_CLIENT:New():FilterCoalitions("blue"):FilterActive():FilterStart()

function generateIntel()
        --zones
    local intelMessage = "ZONES\n\n"
    for i = 1, #SelectedZonesCoalition do
        local zoneCaptureCoalition = SelectedZonesCoalition[i]
        local zoneName = zoneCaptureCoalition:GetZoneName()
        local zoneCoalition = ternary(zoneCaptureCoalition:GetCoalition() == coalition.side.BLUE, "Blue", "Red")
        
        local zoneStatus = ""
        if zoneCaptureCoalition:IsAttacked() then
            zoneStatus = "Attacked"
        elseif zoneCaptureCoalition:IsCaptured() then
            zoneStatus = "Captured"
        elseif zoneCaptureCoalition:IsEmpty() then
            zoneStatus = "Empty"
        elseif zoneCaptureCoalition:IsGuarded() then
            zoneStatus = "Guarded"
        end

        local zoneCAS = ""
        local CAS = CASTrack[zoneName]
        if CAS ~= nil and CAS == true then
            zoneCAS = "Careful, CAS has been sent to respond to your attack and might operate in the AO"
        else
            zoneCAS = "No CAS has been sent to the AO yet"
        end

        local zoneConvoy = ""
        local convoy = GroundTrack[zoneName]
        if convoy ~= nil and convoy == true then
            zoneConvoy = "A moving ground force is reinforcing in the area"
        else
            zoneConvoy = "No moving reinforcement have been sent to this zone yet"
        end

        local zoneCapture = ""
        local capture = ZoneCoalitionHeloCaptureMap[zoneName]
        if capture ~= nil and capture == true then
            zoneCapture = "Our helos are deployed to go capture the AO"
        else
            zoneCapture = "No capturing friendly forces have been sent yet"
        end

        local zoneMessage = zoneName .. ":\nStatus: " .. zoneStatus .. "\n Enemy Support: " .. zoneCAS .. "\nEnemy Assets: " .. zoneConvoy 
        intelMessage = intelMessage .. zoneMessage .. "\n\n"
    end

    -- local currentTime = os.time()
    -- local tankerCooldown = string.format("%d minutes", (currentTime - tankerTimer) / 60)
    -- local facCooldown = tostring((currentTime - facTimer) / 60)
    -- local supportCooldown = tostring((currentTime - supportTimer) / 60)
    -- local exfillCooldown = tostring((currentTime - exfillTimer) / 60)

    -- local cooldownReport = "Command Report:\nTankers routing available in " .. tankerCooldown .. "\nFAC drones routing available in " .. facCooldown .. "\nSupport delivery available in " .. supportCooldown .. "\nExfill services"
    -- intelMessage = intelMessage .. "\n" .. cooldownReport

    return intelMessage
    --QRF convoys
    --QRF Airborn

    --airborn threats
    --support in flight
    --carrier cycle
end

function displayIntelToGroup(playerClient)
    local playerGroup = playerClient:GetGroup()
    local intelMessage = generateIntel()

    -- Generate intel message

    MESSAGE:New( intelMessage, 15, "INTEL Report for " .. playerClient:GetPlayerName()):ToGroup(playerGroup)

end

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

local function permanentPlayerMenu(something)
    env.info(string.format( "BTI: Starting permanent menus"))
    for playerID, alive in pairs(PlayerMap) do
        -- env.info(string.format( "BTI: Commencing Menus for playerID %s alive %s", playerID, tostring(alive)))
        local playerClient = CLIENT:FindByName(playerID)
        local playerGroup = playerClient:GetGroup()
        if alive and playerGroup ~= nil then
            local IntelMenu = MENU_GROUP:New( playerGroup, "Intel" )
            local  groupMenu = MENU_GROUP_COMMAND:New( playerGroup, "Request Intel Report", IntelMenu, displayIntelToGroup, playerClient )
            PlayerMenuMap[playerID] = groupMenu
        else
            local deleteGroupMenu = PlayerMenuMap[playerID]
            if deleteGroupMenu ~= nil then
                deleteGroupMenu:Remove()
            end
            PlayerMenuMap[playerID] = nil
        end
    end
end

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------


local function permanentPlayerCheck(something)
    SetPlayer:ForEachClient(
        function (PlayerClient)
            local PlayerID = PlayerClient.ObjectName
            PlayerClient:AddBriefing("Welcome to BTI \\o/! The intel menu will appear in your F10 radio menu after one minute")

            if PlayerClient:IsAlive() then
                -- env.info(string.format( "BTI: Player in set group ID %s", PlayerID ))
                -- local playerName =  PlayerClient:GetPlayerName()
                -- if playerName then
                --     env.info(string.format( "BTI: Player alive name %s", playerName))
                -- end
                PlayerMap[PlayerID] = true
            else
                PlayerMap[PlayerID] = false
            end
        end
    )
    env.info(string.format("BTI: PlayerMap %s", UTILS.OneLineSerialize(PlayerMap)))
end

SCHEDULER:New(nil, permanentPlayerCheck, {"Something"}, 3, 10)
SCHEDULER:New(nil, permanentPlayerMenu, {"something"}, 11, 15)

env.info(string.format("BTI: CIA back to the safe house"))
