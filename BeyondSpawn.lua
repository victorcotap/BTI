env.info('BTI Spawn starting')

-- BLUEAwacsSpawn = SPAWN:New('BLUE EWR E2')
-- BLUERefuk135Spawn = SPAWN:New('BLUE REFUK KC135')
-- BLUERefuk130Spawn = SPAWN:New('BLUE REFUK KC130')
-- BLUEFACBSpawn = SPAWN:New('BLUE FAC Reaper B')
-- BLUEFACASpawn = SPAWN:New('BLUE FAC Reaper A')

function spawnServices()
    env.info('BTI Spawn function activated')
    -- BLUEAwacsSpawn:Spawn()
    -- BLUERefuk130Spawn:Spawn()
    -- BLUERefuk135Spawn:Spawn()
    -- BLUEFACASpawn:Spawn()
    -- BLUEFACBSpawn:Spawn()

    SPAWN:New('BLUE EWR E2'):Spawn()
    SPAWN:New('BLUE REFUK KC135'):Spawn()
    SPAWN:New('BLUE REFUK KC130'):Spawn()
    SPAWN:New('BLUE FAC Reaper B'):Spawn()
    SPAWN:New('BLUE FAC Reaper A'):Spawn()
end

SCHEDULER:New(nil, spawnServices, {}, 1, 7200)

-- Old way that doesn't work with InitRepeat
-- BLUEAwacsSpawn = SPAWN:New('BLUE EWR E2'):InitRepeat():Spawn()
-- BLUERefuk135Spawn = SPAWN:New('BLUE REFUK KC135'):InitRepeat():Spawn()
-- BLUERefuk130Spawn = SPAWN:New('BLUE REFUK KC130'):InitRepeat():Spawn()
-- BLUEFACBSpawn = SPAWN:New('BLUE FAC Reaper B'):InitRepeat():Spawn()
-- BLUEFACASpawn = SPAWN:New('BLUE FAC Reaper A'):InitRepeat():Spawn()

env.info('BTI Spawn scheduled')
