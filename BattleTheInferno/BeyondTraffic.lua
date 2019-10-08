-- env.info("BTI: Starting RAT Traffic");


local c130 = RAT:New("CIV C130")
c130:SetTakeoff("cold");
c130:SetCoalition("neutral");
c130:ContinueJourney();
c130:Spawn(1);

local Yak40 = RAT:New("CIV Yak40")
Yak40:SetTakeoff("cold");
Yak40:SetCoalition("neutral");
Yak40:ContinueJourney();
Yak40:Spawn(1);

local Antonov = RAT:New("CIV Antonov")
Antonov:SetTakeoff("cold");
Antonov:SetCoalition("neutral");
Antonov:ContinueJourney();
Antonov:Spawn(2);

local Spitfire = RAT:New("CIV Spitfire")
Spitfire:SetTakeoff("cold");
Spitfire:SetCoalition("neutral");
Spitfire:ContinueJourney();
Spitfire:Spawn(1);

local p51 = RAT:New("CIV P51")
p51:SetTakeoff("cold");
p51:SetCoalition("neutral");
p51:ContinueJourney();
p51:Spawn(1);



-- local Tornado = RAT:New("CIV Tornado")
-- Tornado:SetTakeoff("cold");
-- Tornado:SetCoalition("neutral");
-- Tornado:ContinueJourney();
-- Tornado:Spawn(1);

-- local L39 = RAT:New("CIV L39")
-- L39:SetTakeoff("cold");
-- L39:SetCoalition("neutral");
-- L39:ContinueJourney();
-- L39:Spawn(1);

-- local Fw190 = RAT:New("CIV Fw190")
-- Fw190:SetTakeoff("cold");
-- Fw190:SetCoalition("neutral");
-- Fw190:ContinueJourney();
-- Fw190:Spawn(1);




-- env.info("BTI: Finished generating traffic");