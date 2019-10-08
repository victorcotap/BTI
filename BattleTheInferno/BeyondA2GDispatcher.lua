env.info('BTI: Strategic Command initiating communication')

local HQ = GROUP:FindByName("BLUE CC")
local CommandCenter = COMMANDCENTER:New( HQ, "HQ" )

------------------------------------------------------------------------------
-- Globals -------------------------------------------------------------------
A2GSquadrons = {}
A2GPatrolZone = nil
------------------------------------------------------------------------------
-- Init ----------------------------------------------------------------------
A2GDetectionGroups = SET_GROUP:New()
A2GDetectionGroups:FilterPrefixes('BLUE FAC'):FilterStart()
A2GDetection = DETECTION_AREAS:New(A2GDetectionGroups, 1000):SetRefreshTimeInterval(60)

A2GDispatcher = AI_A2G_DISPATCHER:New(A2GDetection)
A2GDispatcher:SetDefenseRadius(250000)
A2GDispatcher:SetDefenseReactivityLow()
A2GDispatcher:SetDefaultLanding(AI_A2G_DISPATCHER.Landing.AtRunway)
A2GDispatcher:SetTacticalDisplay(false)
-- A2GDispatcher:SetCommandCenter(CommandCenter)

------------------------------------------------------------------------------
-- Zones ---------------------------------------------------------------------
local zones = QUAKE[QUAKEZonesAO]
for zoneName, zoneAO in pairs(zones) do
    env.info(string.format( "BTI: Preparing dispatcher for zone %s", zoneName ))
    local zone = ZONE:FindByName(zoneName)
    local coord = zone:GetCoordinate()

    A2GDispatcher:AddDefenseCoordinate(zoneName, coord)
    local zoneSideMissions = zoneAO["SideMissions"]
    for i = 1, #zoneSideMissions do
        local sideMissionGroup = zoneSideMissions[i]["Group"]
        A2GDispatcher:AddDefenseCoordinate(zoneName .. tostring(i), sideMissionGroup:GetCoordinate())
    end

end

-- A2GDispatcher:AddDefenseCoordinate("HQ", HQ:GetCoordinate())

------------------------------------------------------------------------------
-- Squadrons -----------------------------------------------------------------

local SEADSquadron = "BLUE D SEAD"
A2GDispatcher:SetSquadron(SEADSquadron, AIRBASE.PersianGulf.Bandar_Lengeh, { SEADSquadron }, 5 )
A2GDispatcher:SetSquadronSead(SEADSquadron, 700, 900)
-- A2GDispatcher:SetSquadronSeadPatrol( SEADSquadron, A2GPatrolZone, 600, 700, UTILS.KnotsToMps(200), UTILS.KnotsToMps(300), UTILS.KnotsToMps(250), UTILS.KnotsToMps(300) )
-- A2GDispatcher:SetSquadronSeadPatrolInterval( SEADSquadron, 1, 30, 60, 1)

local BAISquadron = "BLUE D BAI"
A2GDispatcher:SetSquadron(BAISquadron, AIRBASE.PersianGulf.Bandar_Lengeh, { BAISquadron }, 5 )
A2GDispatcher:SetSquadronBai(BAISquadron, 700, 900)
-- A2GDispatcher:SetSquadronBaiPatrol( BAISquadron, A2GPatrolZone, 600, 700, UTILS.KnotsToMps(200), UTILS.KnotsToMps(300), UTILS.KnotsToMps(250), UTILS.KnotsToMps(300) )
-- A2GDispatcher:SetSquadronBaiPatrolInterval( BAISquadron, 1, 30, 60, 1)

local CASSquadron = "BLUE D CAS"
A2GDispatcher:SetSquadron( CASSquadron, AIRBASE.PersianGulf.Bandar_Lengeh, { CASSquadron }, 5 )
A2GDispatcher:SetSquadronBai(CASSquadron, 700, 900)
-- A2GDispatcher:SetSquadronCasPatrol( CASSquadron, A2GPatrolZone, 600, 700, UTILS.KnotsToMps(200), UTILS.KnotsToMps(300), UTILS.KnotsToMps(250), UTILS.KnotsToMps(300) )
-- A2GDispatcher:SetSquadronCasPatrolInterval( CASSquadron, 1, 30, 60, 1)

env.info('BTI: Strategic Command is operational')
