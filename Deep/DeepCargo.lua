env.info("BTI: Welcome to FEDEX Cargo")


local convoySpawn = SPAWN:New('BLUE G Convoy')
function testCargo(something)
    env.info("BTI: Got cargo! Spawning")
    local group = convoySpawn:Spawn()
end

function testTroop(something)
    env.info('BTI: Troops delivered, capturing')
end


env.info("BTI: Cargo airline operational")