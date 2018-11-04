env.info(string.format("BTI: Beginning CIA surveillance..."))

local PlayerMap = {}
local PlayerMenuMap = {}

SetPlayer = SET_CLIENT:New():FilterCoalitions("blue"):FilterActive():FilterStart()

function displayIntelToGroup(playerClient)
    local playerGroup = playerClient:GetGroup()
    local intelMessage = UTILS.OneLineSerialize(SelectedZonesCoalition)

    -- Generate intel message

    MESSAGE:New( "YARRRRR!\n", 15, "INTEL Report for " .. playerClient:GetPlayerName()):ToGroup(playerGroup)

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
            local  groupMenu = MENU_GROUP_COMMAND:New( playerGroup, "GIMME INTEL!!", IntelMenu, displayIntelToGroup, playerClient )
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

SCHEDULER:New(nil, permanentPlayerCheck, {"Something"}, 3, 30)
SCHEDULER:New(nil, permanentPlayerMenu, {"something"}, 35, 55)

env.info(string.format("BTI: CIA back to the safe house"))
