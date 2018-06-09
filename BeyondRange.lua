env.info("BTI: Starting Practice Range initialization");

local strafePitA = {
    "RNG Strafe Target #000",
}
local strafePitB = {
    "RNG Strafe Target #001",
}
local strafePitC = {
    "RNG Strafe Target #002",
}

local bombMovingTargets = {
    "RNG Bomb Moving Target #001"
}
local bombtargets = {
    "RNG Bomb Target #000",
    "RNG Bomb Target #001",
    "RNG Bomb Target #002",
    "RNG Bomb Target #003",
    "RNG Bomb Target #004",
    "RNG Bomb Target #005",
    "RNG Bomb Target #006",
    "RNG Bomb Target #007",
    "RNG Bomb Target #008",
    "RNG Bomb Target #010",
    "RNG Bomb Target #011",
    "RNG Bomb Target #012",
    "RNG Bomb Target #013",
    "RNG Bomb Target #014",
    "RNG Bomb Target #016",
    "RNG Bomb Target #017",
    "RNG Bomb Target #018",
    "RNG Bomb Target #019",
    "RNG Bomb Target #020",
    "RNG Bomb Target #021",
    "RNG Bomb Target #022",
    "RNG Bomb Target #023",
    "RNG Bomb Target #024",
    "RNG Bomb Target #025",
    "RNG Bomb Target #026",
    "RNG Bomb Target #027",
    "RNG Bomb Target #028",
    "RNG Bomb Target #029",
    "RNG Bomb Target #030",
    "RNG Bomb Target #031",
    "RNG Bomb Target #032"
}

rangeStatic = UNIT:FindByName("RNG Bomb Moving Target #001")
local rangeCoord = rangeStatic:GetCoordinate()

range = RANGE:New("Boulder City Range");
range:SetRangeLocation(rangeCoord)
range:SetRangeRadius(25000)
range:AddStrafePit(strafePitA, 3000, 500, nil, true, 20, 300);
range:AddStrafePit(strafePitB, 3000, 500, nil, true, 10, 200);
range:AddStrafePit(strafePitC, 3000, 500, nil, true, 30);


range:AddBombingTargets(bombtargets, 50, false);
range:AddBombingTargetUnit(rangeStatic, 50, false);
range:Start();

env.info("BTI: Range is ready");
