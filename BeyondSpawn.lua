env.info('BTI Spawn starting')

SETTINGS:SetPlayerMenuOff()

function spawnServices()
    env.info('BTI Spawn function activated')

    SPAWN:New('BLUE C EWR E2'):Spawn()
    SPAWN:New('BLUE REFUK KC130'):Spawn()
    SPAWN:New('BLUE C REFUK S3B'):Spawn()
end

function spawnRecon()
    SPAWN:New('BLUE FAC Reaper A'):Spawn()
end

SCHEDULER:New(nil, spawnServices, {}, 5, 7200)
SCHEDULER:New(nil, spawnRecon, {}, 2, 3600)

TruckSpawn = SPAWN:New('BLUE Supply Convoy')

env.info('BTI Spawn scheduled')
