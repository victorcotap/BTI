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

RedSquadronA = "Taboule"
RED_A2ADispatcher:SetSquadron( RedSquadronA , "Bandar Abbas Intl", { "!mig29_ai #002" })
RED_A2ADispatcher:SetSquadronGci( RedSquadronA, 800, 1800)

RedSquadronB = "Couscous"
RED_A2ADispatcher:SetSquadron( RedSquadronB , "Bandar Abbas Intl", { "!mig23_ai hard" })
RED_A2ADispatcher:SetSquadronGci( RedSquadronB, 800, 1800)

RedSquadronC = "Kebab"
RED_A2ADispatcher:SetSquadron( RedSquadronC , "Bandar Abbas Intl", { "!mig23_ai easy" } )
RED_A2ADispatcher:SetSquadronGci( RedSquadronC, 800, 1800)

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

BlueSquadronA = "BBQ"
BLUE_A2ADispatcher:SetSquadron( BlueSquadronA , "Dubai Intl", { "@f16_ai med" })
BLUE_A2ADispatcher:SetSquadronGci( BlueSquadronA, 800, 1800)

BlueSquadronB = "Guns"
BLUE_A2ADispatcher:SetSquadron( BlueSquadronB , "Dubai Intl", { "@f16_ai hard" })
BLUE_A2ADispatcher:SetSquadronGci( BlueSquadronB, 800, 1800)

env.info("CTI: BLUE Dispatcher ready")