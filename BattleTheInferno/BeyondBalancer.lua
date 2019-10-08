env.info("BTI: Preparing AI Balancer");

BLUE_TANKER_KC130 = "BLUE REFUK KC130"
BLUE_TANKER_KC135 = "BLUE REFUK KC135"

F15clients = SET_CLIENT:New():FilterPrefixes("Player A2A F15");
Mirageclients = SET_CLIENT:New():FilterPrefixes("Player A2A Mirage");
Su27clients = SET_CLIENT:New():FilterPrefixes("Player A2A J11A");

BLUE_F16 = SPAWN:New("BLUE A2A F16 Nellis"):InitLimit(2, 0):InitRepeatOnLanding()
BLUE_F18 = SPAWN:New("BLUE A2A F18 Nellis"):InitLimit(2, 0):InitRepeatOnLanding()
BLUE_Mig29 = SPAWN:New("Blue A2A F14 Nellis"):InitLimit(2, 0):InitRepeatOnLanding()

BLUE_F15_Balancer = AI_BALANCER:New(F15clients, BLUE_F16):InitSpawnInterval(45, 78)--:ReturnToHomeAirbase(30000);
BLUE_Mirage_Balancer = AI_BALANCER:New(Mirageclients, BLUE_F18):InitSpawnInterval(24, 34)--:ReturnToHomeAirbase(30000);
BLUE_Su27_Balancer = AI_BALANCER:New(Su27clients, BLUE_Mig29):InitSpawnInterval(90, 132)--:ReturnToHomeAirbase(30000);
 
ZONE_PATROL_A = ZONE_POLYGON:New( "BLUE CAP A", GROUP:FindByName( "BLUE CAP A" ) )
ZONE_PATROL_B = ZONE_POLYGON:New( "BLUE CAP B", GROUP:FindByName( "BLUE CAP B" ) )
BLUE_ZONE_ENGAGE = ZONE_POLYGON:New( "BLUE ENGAGE CAP", GROUP:FindByName( "BLUE ENGAGE CAP" ) )

env.info("BTI: AI Balancer is ready");

function BLUE_F15_Balancer:OnAfterSpawned( SetGroup, From, Event, To, AIGroup )
        -- Cap15 = AI_A2A_CAP:New( AIGroup, ZONE_PATROL_A, 3000, 6000, 400, 600, 800, 1200, "BARO" )
    -- Cap15:SetEngageZone(BLUE_ZONE_ENGAGE)
    -- Cap15:SetEngageRange(35000)
    -- Cap15:SetTanker(BLUE_TANKER_KC135)
    Cap15 = AI_CAP_ZONE:New( ZONE_PATROL_A, 3000, 6000, 500, 700, "BARO" )
    Cap15:SetDetectionZone(BLUE_ZONE_ENGAGE)
    Cap15:SetRefreshTimeInterval(90)
    Cap15:SetControllable(AIGroup)
    Cap15:Start()
end

function BLUE_Mirage_Balancer:OnAfterSpawned( SetGroup, From, Event, To, AIGroup )
        -- CapMirage:SetEngageZone(BLUE_ZONE_ENGAGE)
    -- CapMirage:SetEngageRange(35000)
    -- CapMirage:SetTanker(BLUE_TANKER_KC130)
    CapMirage = AI_CAP_ZONE:New( ZONE_PATROL_B, 3000, 6000, 500, 700, "BARO" )
    CapMirage:SetControllable(AIGroup)
    CapMirage:SetDetectionZone(BLUE_ZONE_ENGAGE)
    CapMirage:SetRefreshTimeInterval(90)
    CapMirage:Start()
end

function BLUE_Su27_Balancer:OnAfterSpawned( SetGroup, From, Event, To, AIGroup )
        -- Cap27:SetEngageZone(BLUE_ZONE_ENGAGE)
    -- Cap27:SetEngageRange(35000)
    -- Cap27:SetTanker(BLUE_TANKER_KC130)
    Cap27 = AI_CAP_ZONE:New( ZONE_PATROL_B, 3000, 6000, 500, 700, "BARO" )
    Cap27:SetControllable(AIGroup)
    Cap27:SetDetectionZone(BLUE_ZONE_ENGAGE)
    Cap27:SetRefreshTimeInterval(90)
    Cap27:Start()
end

env.info("BTI: AI Balancer and patrolling is up");
