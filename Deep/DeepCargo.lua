env.info("BTI: Welcome to FEDEX Cargo")


local convoySpawn = SPAWN:New('BLUE G Convoy')
function testCargo(something)
    env.info("BTI: Got cargo! Spawning")
    local group = convoySpawn:Spawn()
end

SCHEDULER:New(nil, testCargo, {"toto"}, 2500, 2000)

local NavySeals = SPAWN:New('BLUE SF Fleet')
function testTroop(something)
    env.info('BTI: Troops delivered, capturing')
    local NavySeals = SPAWN:New('BLUE SF Fleet')
    NavySeals:Spawn()
end


env.info("BTI: Cargo airline operational")