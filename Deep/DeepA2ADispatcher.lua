
env.info("[BTI] A2A Dispatcher: Starting the mastermind dispatcher")

RedBorderZone = ZONE_POLYGON:New( "RED Border", GROUP:FindByName( "RED BorderZone" ) )
RedCapZone = ZONE_POLYGON:New( "RED Patrol", GROUP:FindByName("RED Patrol"))
env.info("[BTI] A2A Dispatcher: Zone Poly ready")


REDEWR = SET_GROUP:New()
REDEWR:FilterPrefixes( { "RED EWR" } )
REDEWR:FilterStart()
env.info("[BTI] A2A Dispatcher: EWR ready")

-- Setup the detection and group targets to a 30km range!
EWR = DETECTION_AREAS:New( REDEWR, 28000 ):SetRefreshTimeInterval( 70 )
env.info("[BTI] A2A Dispatcher: Detection ready")

-- Setup the A2A dispatcher, and initialize it.
A2ADispatcher = AI_A2A_DISPATCHER:New( EWR )
A2ADispatcher:SetEngageRadius( 50000 )
A2ADispatcher:SetGciRadius( 269000 )
A2ADispatcher:SetIntercept(30)
-- A2ADispatcher:SetTacticalDisplay( true )
A2ADispatcher:SetBorderZone( RedBorderZone )
env.info("[BTI] A2A Dispatcher: Dispatcher created")

-- Set Defaults
A2ADispatcher:SetDefaultGrouping(1)
A2ADispatcher:SetDefaultOverhead(1)
A2ADispatcher:SetDefaultFuelThreshold(0.25)
A2ADispatcher:SetDefaultTanker("RED Tanker")
A2ADispatcher:SetDefaultDamageThreshold(0.4)
A2ADispatcher:SetDisengageRadius(130000)
env.info("[BTI] A2A Dispatcher: Defaults set")

--Set Squadrons
SquadronA = "Squadron A"
A2ADispatcher:SetSquadron( SquadronA , "Vaziani", { "RED F4" }, 6 )
A2ADispatcher:SetSquadronCap( SquadronA, RedCapZone, 4000, 8000, 500, 640, 500, 650, "BARO" )
A2ADispatcher:SetSquadronCapInterval( SquadronA, 2, 180, 300, 1 )

-- LarSquadron = "Lar Squadron"
-- A2ADispatcher:SetSquadron( LarSquadron, "Al Maktoum Intl", { "RED F5" }, 4 )
-- A2ADispatcher:SetSquadronGci( LarSquadron, 800, 1800)

SquadronB = "Squadron B"
A2ADispatcher:SetSquadron( SquadronB, "Vaziani", { "RED Mig29" }, 6 )
A2ADispatcher:SetSquadronGci( SquadronB, 500, 650)


env.info("[BTI] A2A Dispatcher: Squadrons ready")