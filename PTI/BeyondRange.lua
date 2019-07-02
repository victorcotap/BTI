env.info("BTI: Starting Practice Range initialization");

local strafePitA = {
    "RANGEArmedHouse",
}

local bombtargets = {
    "RANGETruck",
    "RANGEOutpost",
    "RANGECar",
}

rangeStatic = UNIT:FindByName("BLUE CC")
local rangeCoord = rangeStatic:GetCoordinate()

range = RANGE:New("Weapon Practice Range");
range:SetRangeLocation(rangeCoord)
range:SetRangeRadius(10000)
range:AddStrafePit(strafePitA, 3000, 500, nil, true, 20, 300);

range:AddBombingTargets(bombtargets, 50, false);
range:Start();

env.info("BTI: Range is ready");
