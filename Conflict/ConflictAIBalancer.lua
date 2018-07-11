
env.info("CTI: AI Balancer is starting");

BLUE_P_CAP = "P F/A-18C"
RED_AI_CAP = "A2A_Spawn_Init_CO"

BLUE_CAP_Clients = SET_CLIENT:New():FilterPrefixes(BLUE_P_CAP)
RED_CAP_SPAWN =  SPAWN:New(RED_AI_CAP)

BLUE_P_CAP_Balancer = AI_BALANCER:New(BLUE_CAP_Clients, RED_CAP_SPAWN):InitSpawnInterval(15, 28)
BLUE_P_CAP_Balancer:ReturnToHomeAirbase(15000)

function BLUE_P_CAP_Balancer:OnAfterSpawned( SetGroup, From, Event, To, AIGroup )
    env.info("HEYYYY SPAWN")
end


env.info("CTI: AI Balancer is ready")
