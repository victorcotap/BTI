env.info("BTI: Welcome to FEDEX Cargo")

function spawnRecon(something)
    local group = SPAWN:New('BLUE FAC Reaper A'):Spawn()
end
SCHEDULER:New(nil, spawnRecon, {"dfsdf"}, 7, 3600)

local convoySpawn = SPAWN:New('BLUE G Convoy')
function testCargo(something)
    env.info("BTI: Got cargo! Spawning")
    local group = convoySpawn:Spawn()
end
SCHEDULER:New(nil, testCargo, {"dfsdf"}, 10, 360)

env.info("BTI: Cargo airline operational")