env.info('BTI Spawn starting')
SETTINGS:SetPlayerMenuOff()

HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )


function spawnRecon(something)
    local group = SPAWN:New('BLUE FAC Reaper A'):Spawn()
    local type = group:GetTypeName()
    env.info(string.format("blue fac reaper type %s", type))
end

function spawnBomberFerry(something)
    env.info('BTI: RED Bomber Ferry activated')
    SPAWN:New('RED Bomber Ferry'):Spawn()
    CommandCenter:MessageTypeToCoalition( string.format("Bomber has been detected leaving Al Dhafra with an important Officer!\nIntel tells us its headed for Bandas Shenas\nIntercept the bomber before it reaches its destination and be wary of its protection"), MESSAGE.Type.Information )
end

function spawnShipConvoy(something)
    SPAWN:New('RED Ship Convoy'):Spawn()
    CommandCenter:MessageTypeToCoalition( string.format("A convoy consisting of several warships has left Bandar Shenas to re-supply Abu-Dhabi with new and modern SAM.\nDestroy the convoy before it can bring new and improved SAMs to the peninsula"), MESSAGE.Type.Information )
end

function spawnArty(something)
    env.info("BTI: Cargo delivered!")
    SPAWN:New('BLUE Arty Paladin'):Spawn()
end

SCHEDULER:New(nil, spawnRecon, {"dfsdf"}, 2, 3600)
SCHEDULER:New(nil, spawnBomberFerry, {"toto"}, 60, 2500)
SCHEDULER:New(nil, spawnShipConvoy, {"toto"}, 750, 10800)

TruckSpawn = SPAWN:New('BLUE Supply Convoy')

env.info('BTI Spawn scheduled')
