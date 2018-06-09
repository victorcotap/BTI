env.info('BTI Spawn starting')

function spawnServices()
    env.info('BTI Spawn function activated')

    SPAWN:New('BLUE EWR E2'):Spawn()
    SPAWN:New('BLUE REFUK KC130'):Spawn()
end

function spawnRecon()
    SPAWN:New('BLUE FAC Reaper A'):Spawn()
end

SCHEDULER:New(nil, spawnServices, {}, 1, 7200)
SCHEDULER:New(nil, spawnRecon, {}, 2, 3600)



env.info('BTI Spawn scheduled')
