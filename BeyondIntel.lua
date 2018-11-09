env.info(string.format("BTI: Beginning CIA surveillance..."))

-- Utils ---------------------------------------------------------------
local function ternary ( cond , T , F )
    if cond then return T else return F end
end

local function weatherStringForCoordinate(coord)
    local currentPressure = coord:GetPressure(0)
    local currentTemperature = coord:GetTemperature()
    local currentWindDirection, currentWindStrengh = coord:GetWind()
    local weatherString = string.format("Wind from %d@%.1fkts, QNH %.2f, Temperature %d", currentWindDirection, UTILS.MpsToKnots(currentWindStrengh), currentPressure * 0.0295299830714, currentTemperature)
    return weatherString
end

PlayerMap = {}
local PlayerMenuMap = {}

SetPlayer = SET_CLIENT:New():FilterCoalitions("blue"):FilterActive():FilterStart()

function generateIntel(playerGroup)
        --zones
    local intelMessage = "|ZONES / AOs|\n"
    for i = 1, #SelectedZonesCoalition do
        local zoneCaptureCoalition = SelectedZonesCoalition[i]
        local zoneName = zoneCaptureCoalition:GetZoneName()
        local zoneCoord = zoneCaptureCoalition:GetZone():GetCoordinate()
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

        local zoneWeatherString = weatherStringForCoordinate(zoneCoord)

        local zoneMessage = "* " .. zoneName .. " *\nStatus: " .. zoneStatus .. "\nEnemy Support: " .. zoneCAS .. "\nEnemy Assets: " .. zoneConvoy .. "\n/Weather/: " .. zoneWeatherString 
        intelMessage = intelMessage .. zoneMessage .. "\n\n"
        
        local zoneSideMissions = QUAKE[QUAKEZonesAO][zoneName]["SideMissions"]
        intelMessage = intelMessage .. "AO Dynamic Side Missions: "
        for i = 1, #zoneSideMissions do
            local mission = zoneSideMissions[i]
            if mission["Finished"] == false then
                local missionReport = "Type " .. tostring(mission["Type"]) .. ". "
                intelMessage = intelMessage .. missionReport
            else
                intelMessage = intelMessage .. "Finished. "
            end
        end
        intelMessage = intelMessage .. "\n\n"
    end

    local currentTime = os.time()

    intelMessage = intelMessage .. "|Enemy Air|\n *NON exhaustive list*\n"
    local CASGroups = QUAKE[QUAKECAS]
    for i = 1, #CASGroups do
        local zoneName = CASGroups[i]["Zone"]
        intelMessage = intelMessage .. "Enemy CAS is operating in " .. zoneName .. "\n"
    end
    local FightersGroups = QUAKE[QUAKEFighters]
    for i = 1, #FightersGroups do
        local zoneName = FightersGroups[i]["Zone"]
        intelMessage = intelMessage .. "Enemy fighter sweep is patrolling around " .. zoneName .. "\n"
    end
    intelMessage = intelMessage .. "\n\n"


    intelMessage = intelMessage .. "|Enemy Airborn Resupply|\n"
    local convoys = QUAKE[QUAKEHeloConvoys]
    intelMessage = intelMessage .. ternary(#convoys == 0, "No enemy resupply operation launched yet", "The enemy is sending resupply SA-2s. Intercept them before they reach their destination\n") .. "\n"
    for i = 1, #convoys do
        local convoy = convoys[i]
        local convoyTime = string.format("%d minutes", (currentTime - convoy["Timer"]) / 60)
        local convoyReport = "From " .. convoy["From"] .. " to " .. convoy["To"] .. " started " .. convoyTime .. " ago\n"
        intelMessage = intelMessage .. convoyReport
    end
    intelMessage = intelMessage .. "\n\n"


    intelMessage = intelMessage .. "|COMMANDS|\nSee throughtheinferno.com/battle-the-inferno for help\n"
    local tankerCooldown =  ternary(currentTime > tankerTimer + TANKER_COOLDOWN, "Ready for new command", string.format("Available in %d minutes", math.abs((currentTime - (tankerTimer + TANKER_COOLDOWN)) / 60)))
    local facCooldown = ternary(currentTime > facTimer + FAC_COOLDOWN, "Ready for new command", string.format("Available in %d minutes", math.abs((currentTime - (facTimer + FAC_COOLDOWN)) / 60)))
    local supportCooldown = ternary(currentTime > supportTimer + SUPPORT_COOLDOWN, "Ready for new command", string.format("Available in %d minutes", math.abs((currentTime - (supportTimer + SUPPORT_COOLDOWN)) / 60)))
    local exfillCooldown = ternary(currentTime > exfillTimer + EXFILL_COOLDOWN, "Ready for new command", string.format("Available in %d minutes", math.abs((currentTime - (exfillTimer + EXFILL_COOLDOWN)) / 60)))
        -- Number of C-17s in flight
    local cooldownReport = "Tankers routing -> " .. tankerCooldown .. "\nFAC drones routing -> " .. facCooldown .. "\nSupport delivery -> " .. supportCooldown .. "\nExfill services -> " .. exfillCooldown
    intelMessage = intelMessage .. "\n" .. cooldownReport .. "\n\n"


    intelMessage = intelMessage .. "|CARRIER|\n"
    local carrierPhase = ternary(CARRIERCycle == 1, "Launch & Recovery", "Planned Route")
    local carrierPhaseTime = string.format("%d minutes", (currentTime - CARRIERTimer) / 60)
    local carrierWeather = weatherStringForCoordinate(GROUP:FindByName("BLUE CV Fleet"):GetCoordinate())
    local carrierATIS = carrierWeather .. " " .. ternary(CARRIERCycle == 1, "Deck is open, CASE I in effect", "Deck is closed, Marshall stack starting at 2000MSL")
    local carrierReport = "Carrier Cycle: " .. carrierPhase .. "\nCarrier Cycle time remaining: " .. carrierPhaseTime .. "\nATIS: " .. carrierATIS
    intelMessage = intelMessage .. carrierReport .. "\n\n"
    

    intelMessage = intelMessage .. "|ATIS|\n"
    local coord = playerGroup:GetCoordinate()
    local weatherString = "Weather for current position:\n" .. weatherStringForCoordinate(coord)
    intelMessage = intelMessage .. weatherString .. "\n\n"

    return intelMessage
end

function displayIntelToGroup(playerClient)
    local playerGroup = playerClient:GetGroup()
    local intelMessage = generateIntel(playerGroup)

    -- Generate intel message

    MESSAGE:New( intelMessage, 35, "INTEL Report for " .. playerClient:GetPlayerName() .. "\n"):ToGroup(playerGroup)

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
            PlayerClient:AddBriefing("Welcome to BTI|Battle The Inferno \\o/!\n\nThe intel menu will appear in your F10 radio menu after one minute\n\nPlease check the briefing for essential informations\nAlso visit http://throughtheinferno.com/battle-the-inferno for a tutorial concerning game mechanics on BTI")

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
