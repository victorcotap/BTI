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
A2ADispatcher:SetGciRadius( 180000 )
A2ADispatcher:SetIntercept(90)
-- A2ADispatcher:SetTacticalDisplay( true )
A2ADispatcher:SetBorderZone( RedBorderZone )
env.info("[BTI] A2A Dispatcher: Dispatcher created")

-- Set Defaults
A2ADispatcher:SetDefaultGrouping(2)
A2ADispatcher:SetDefaultFuelThreshold(0.25)
A2ADispatcher:SetDefaultTanker("RED Tanker")
A2ADispatcher:SetDefaultDamageThreshold(0.4)
-- A2ADispatcher:SetDisengageRadius(150000)
env.info("[BTI] A2A Dispatcher: Defaults set")

--Set Squadrons
GroomSquadron = "Groom Squadron"
A2ADispatcher:SetSquadron( GroomSquadron , AIRBASE.Nevada.Groom_Lake_AFB, { "RED Su33" }, 10 )
A2ADispatcher:SetSquadronGci( GroomSquadron, 800, 1800)

TonopahSquadron = "Tonopah Squadron"
A2ADispatcher:SetSquadron( TonopahSquadron, AIRBASE.Nevada.Tonopah_Test_Range_Airfield, { "RED Mig29" }, 50 )
A2ADispatcher:SetSquadronCap( TonopahSquadron, RedCapZone, 4000, 8000, 600, 800, 800, 1200, "BARO" )
A2ADispatcher:SetSquadronCapInterval( TonopahSquadron, 1, 30, 120, 1 )

env.info("[BTI] A2A Dispatcher: Squadrons ready")
