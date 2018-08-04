env.info("BTI: Welcome to FEDEX Spawn")

function spawnRecon(something)
    local group = SPAWN:New('BLUE FAC Reaper A'):Spawn()
    local type = group:GetTypeName()
    env.info(string.format("blue fac reaper type %s", type))
end
SCHEDULER:New(nil, spawnRecon, {"dfsdf"}, 2, 3000)


local convoySpawn = SPAWN:New('BLUE G Convoy')
function convoySpawn(something)
    env.info("BTI: Got cargo! Spawning")
    local group = convoySpawn:Spawn()
end
SCHEDULER:New(nil, convoySpawn, {"toto"}, 600, 1200)



-- local NavySeals = SPAWN:New('BLUE SF Fleet')
-- function testTroop(something)
--     env.info('BTI: Troops delivered, capturing')
--     local NavySeals = SPAWN:New('BLUE SF Fleet')
--     NavySeals:Spawn()
-- end


env.info("BTI: Cargo airline operational")