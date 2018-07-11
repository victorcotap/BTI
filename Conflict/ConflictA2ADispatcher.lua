env.info("CTI A2A Dispatcher: Starting the mastermind dispatcher")

-- RedBorderZone = ZONE_POLYGON:New( "RED Border", GROUP:FindByName( "RED BorderZone" ) )

-- RedZone = ZONE:New("RED BorderZone")
env.info("[BTI] A2A Dispatcher: Zone Poly ready")


REDEWR = SET_GROUP:New()
REDEWR:FilterPrefixes( { "RED EWR" } )
REDEWR:FilterStart()
env.info("[BTI] A2A Dispatcher: EWR ready")

-- Setup the detection and group targets to a 30km range!
RED_EWR_Detection = DETECTION_AREAS:New( REDEWR, 20000 ):SetRefreshTimeInterval( 40 )
env.info("[BTI] A2A Dispatcher: Detection ready")

RED_A2ADispatcher = AI_A2A_DISPATCHER:New( RED_EWR_Detection )
-- RED_A2ADispatcher:SetEngageRadius( 50000 )
-- RED_A2ADispatcher:SetGciRadius( 80000 )
RED_A2ADispatcher:SetTacticalDisplay( true )
RED_A2ADispatcher:SetIntercept(60)

SquadronA = "Taboule"
RED_A2ADispatcher:SetSquadron( SquadronA , "Bandar Abbas Intl", { "!mig29_ai #002" }, 0 )
RED_A2ADispatcher:SetSquadronGci( SquadronA, 800, 1800)

SquadronB = "Couscous"
RED_A2ADispatcher:SetSquadron( SquadronA , "Bandar Abbas Intl", { "!mig23_ai hard" }, 0 )
RED_A2ADispatcher:SetSquadronGci( SquadronA, 800, 1800)

SquadronC = "Kebab"
RED_A2ADispatcher:SetSquadron( SquadronA , "Bandar Abbas Intl", { "!mig23_ai easy" }, 0 )
RED_A2ADispatcher:SetSquadronGci( SquadronA, 800, 1800)

env.info("CTI: RED Dispatcher ready")


BLUEEWR = SET_GROUP:New()
BLUEEWR:FilterPrefixes( { "BLUE EWR" } )
BLUEEWR:FilterStart()
env.info("[BTI] A2A Dispatcher: EWR ready")

-- Setup the detection and group targets to a 30km range!
BLUE_EWR_Detection = DETECTION_AREAS:New( BLUEEWR, 20000 ):SetRefreshTimeInterval( 40 )
env.info("[BTI] A2A Dispatcher: Detection ready")

BLUE_A2ADispatcher = AI_A2A_DISPATCHER:New( BLUE_EWR_Detection )
-- RED_A2ADispatcher:SetEngageRadius( 50000 )
-- RED_A2ADispatcher:SetGciRadius( 80000 )
BLUE_A2ADispatcher:SetTacticalDisplay( true )

BLUE_A2ADispatcher:SetIntercept(60)

SquadronA = "BBQ"
BLUE_A2ADispatcher:SetSquadron( SquadronA , "Dubai Intl", { "@f16_ai med" }, 0 )
BLUE_A2ADispatcher:SetSquadronGci( SquadronA, 800, 1800)

SquadronB = "Guns"
BLUE_A2ADispatcher:SetSquadron( SquadronA , "Dubai Intl", { "@f16_ai hard" }, 0 )
BLUE_A2ADispatcher:SetSquadronGci( SquadronA, 800, 1800)

env.info("CTI: BLUE Dispatcher ready")