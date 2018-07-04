env.info('BTI Spawn starting')

SETTINGS:SetPlayerMenuOff()

function spawnServices(something)
    env.info('BTI Spawn function activated')

    SPAWN:New('BLUE C EWR E2'):Spawn()
    SPAWN:New('BLUE REFUK KC130'):Spawn()
    SPAWN:New('BLUE C REFUK S3B'):Spawn()
end

function spawnRecon(something)
    local group = SPAWN:New('BLUE FAC Reaper A'):Spawn()
    local type = group:GetTypeName()
    env.info(string.format("blue fac reaper type %s", type))
end

function spawnBomberFerry(something)
    env.info('BTI: RED Bomber Ferry activated')
    SPAWN:New('RED Bomber Ferry'):Spawn()
end

function spawnShipConvoy(something)
    SPAWN:New('RED Ship Convoy'):Spawn()
end

SCHEDULER:New(nil, spawnServices, {"sdfsdfd"}, 55, 7200)
SCHEDULER:New(nil, spawnRecon, {"dfsdf"}, 2, 3600)
SCHEDULER:New(nil, spawnBomberFerry, {"toto"}, 60, 4000)
SCHEDULER:New(nil, spawnShipConvoy, {"toto"}, 15, 10800)

TruckSpawn = SPAWN:New('BLUE Supply Convoy')

env.info('BTI Spawn scheduled')
