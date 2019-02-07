env.info(string.format("BTI: Beginning CIA surveillance..."))

-- Utils ---------------------------------------------------------------
local function ternary ( cond , T , F )
    if cond then return T else return F end
end



----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
PlayerMap = {}
local PlayerMenuMap = {}

SetPlayer = SET_CLIENT:New():FilterCoalitions("blue"):FilterActive():FilterStart()

-- INTEL -------------------------------------------------------------------------------------------------
--Backup for future intel
function generateIntel(playerGroup)
        --zones
    local intelMessage = "|ZONES / AOs|\n"

    local function weatherStringForCoordinate(coord)
        local currentPressure = coord:GetPressure(0)
        local currentTemperature = coord:GetTemperature()
        local currentWindDirection, currentWindStrengh = coord:GetWind()
        local weatherString = string.format("Wind from %d@%.1fkts, QNH %.2f, Temperature %d", currentWindDirection, UTILS.MpsToKnots(currentWindStrengh), currentPressure * 0.0295299830714, currentTemperature)
        return weatherString
    end

    return intelMessage
end

function displayIntelToGroup(playerClient)
    local playerGroup = playerClient:GetGroup()
    local intelMessage = generateIntel(playerGroup)
    MESSAGE:New( intelMessage, 35, "INTEL Report for " .. playerClient:GetPlayerName() .. "\n"):ToGroup(playerGroup)
end

-- COMMANDS ----------------------------------------------------------------------------------------------
function requestTankerAWACSTasking()
    SUPPORTResetTankerAWACSTask()
end

function requestCarrierRecovery(case)
    env.info(string.format( "BTI: received demand for recovery case %d", case ))
    OpenCarrierRecovery(29, case)
end

function requestCarrierBeacon()
    ActivateCarrierBeacons()
end

function requestCarrierCancelRecovery()
    CancelCarrierRecovery()
end

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

local function permanentPlayerMenu(something)
    -- env.info(string.format( "BTI: Starting permanent menus"))
    for playerID, alive in pairs(PlayerMap) do
        -- env.info(string.format( "BTI: Commencing Menus for playerID %s alive %s", playerID, tostring(alive)))
        local playerClient = CLIENT:FindByName(playerID)
        local playerGroup = playerClient:GetGroup()
        if alive and playerGroup ~= nil then
            local IntelMenu = MENU_GROUP:New( playerGroup, "Commands [WIP/Buggy]" )
            
            local intelGroupMenu = MENU_GROUP_COMMAND:New( playerGroup, "Request Intel Report", IntelMenu, displayIntelToGroup, playerClient )
            local tankerAWACSMenu = MENU_GROUP_COMMAND:New( playerGroup, "Fix Tanker & AWACS", IntelMenu, requestTankerAWACSTasking)
            local carrierBeaconMenu = MENU_GROUP_COMMAND:New( playerGroup, "Reset Carrier TCN / ICLS", IntelMenu, requestCarrierBeacon)

            local carrierCASEIMenu = MENU_GROUP_COMMAND:New( playerGroup, "Open CASE I Recovery ", IntelMenu, requestCarrierRecovery, 1 )
            local carrierCASEIIMenu = MENU_GROUP_COMMAND:New( playerGroup, "Open CASE II Recovery ", IntelMenu, requestCarrierRecovery, 2 )
            local carrierCASEIIIMenu = MENU_GROUP_COMMAND:New( playerGroup, "Open CASE III Recovery ", IntelMenu, requestCarrierRecovery, 3 )

            local carrierCancelMenu = MENU_GROUP_COMMAND:New( playerGroup, "Cancel Recovery", IntelMenu, requestCarrierCancelRecovery)
 
            local groupMenus = { intelGroupMenu, tankerAWACSMenu, carrierBeaconMenu, carrierCASEIMenu, carrierCASEIIMenu, carrierCASEIIIMenu, carrierCancelMenu }
            PlayerMenuMap[playerID] = groupMenus
        else
            local deleteGroupMenus = PlayerMenuMap[playerID]
            if deleteGroupMenus ~= nil then
                for i,menu in ipairs(deleteGroupMenus) do
                    menu:Remove()
                end
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
            PlayerClient:AddBriefing("Welcome to PTI|Practice The Inferno \\o/!\n\n Head to http://tthroughtheinferno.com/practice-the-inferno for a complete list of ZEUS commands")

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
    -- env.info(string.format("BTI: PlayerMap %s", UTILS.OneLineSerialize(PlayerMap)))
end

SCHEDULER:New(nil, permanentPlayerCheck, {"Something"}, 3, 10)
SCHEDULER:New(nil, permanentPlayerMenu, {"something"}, 11, 15)

env.info(string.format("BTI: CIA back to the safe house"))
