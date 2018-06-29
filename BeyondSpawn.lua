env.info('BTI Spawn starting')

SETTINGS:SetPlayerMenuOff()

function spawnServices(something)
    env.info('BTI Spawn function activated')

    SPAWN:New('BLUE C EWR E2'):Spawn()
    SPAWN:New('BLUE REFUK KC130'):Spawn()
    SPAWN:New('BLUE C REFUK S3B'):Spawn()
end

function spawnRecon(something)
    SPAWN:New('BLUE FAC Reaper A'):Spawn()
end

function spawnBomberEscortFerry(something)
    env.info('BTI RED Bonber Ferry activated')
    SPAWN:New('RED Bomber Ferry'):Spawn()
    SPAWN:New('RED Bomber Escort'):Spawn()
end

SCHEDULER:New(nil, spawnServices, {"sdfsdfd"}, 5, 7200)
SCHEDULER:New(nil, spawnRecon, {"dfsdf"}, 2, 3600)
SCHEDULER:New(nil, spawnBomberEscortFerry, {"toto"}, 10, 4000)

TruckSpawn = SPAWN:New('BLUE Supply Convoy')

env.info('BTI Spawn scheduled')
