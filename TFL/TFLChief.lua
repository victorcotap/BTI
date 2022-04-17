
local TemplateTPz = PLATOON:New("TPz", 10, "TPz APC"):AddMissionCapability( { AUFTRAG.Type.ARMOREDGUARD, AUFTRAG.Type.ARMORATTACK, AUFTRAG.Type.PATROLZONE }, 100 )
local TemplateGepard = PLATOON:New("Gepard", 10, "Gepard APC"):AddMissionCapability( { AUFTRAG.Type.ARMOREDGUARD, AUFTRAG.Type.ARMORATTACK, AUFTRAG.Type.PATROLZONE }, 100 )
local TemplateInfantry = PLATOON:New("Infantry", 10, "Infantry M4"):AddMissionCapability( { AUFTRAG.Type.ARMOREDGUARD, AUFTRAG.Type.ARMORATTACK, AUFTRAG.Type.PATROLZONE }, 100 )
local TemplateSA8 = PLATOON:New("SA8", 10, "SA8 SAM"):AddMissionCapability( { AUFTRAG.Type.ARMOREDGUARD, AUFTRAG.Type.ARMORATTACK, AUFTRAG.Type.PATROLZONE }, 100 )
local TemplateLeclerc = PLATOON:New("Leclerc", 10, "Leclerc Tanks"):AddMissionCapability( { AUFTRAG.Type.ARMOREDGUARD, AUFTRAG.Type.ARMORATTACK, AUFTRAG.Type.PATROLZONE }, 100 )
local TemplateTruck = PLATOON:New("Truck", 10, "Basic Trucks"):AddMissionCapability( { AUFTRAG.Type.ARMOREDGUARD, AUFTRAG.Type.ARMORATTACK, AUFTRAG.Type.PATROLZONE }, 100 )
local TemplateM270 = PLATOON:New("M270", 10, "Basic MLRS Arty"):AddMissionCapability( { AUFTRAG.Type.ARTY }, 100 )
local TemplatePaladin = PLATOON:New("Paladin", 10, "Basic Paladin Arty"):AddMissionCapability( { AUFTRAG.Type.ARTY}, 100 )


local BLUEBrigade = BRIGADE:New("BLUEWarehouse", "Some Blue Brigade")
BLUEBrigade:AddPlatoon(TemplateTPz)
BLUEBrigade:AddPlatoon(TemplateGepard)
BLUEBrigade:AddPlatoon(TemplateInfantry)
BLUEBrigade:AddPlatoon(TemplateSA8)
BLUEBrigade:AddPlatoon(TemplateLeclerc)
BLUEBrigade:AddPlatoon(TemplateTruck)
BLUEBrigade:AddPlatoon(TemplatePaladin)
BLUEBrigade:AddPlatoon(TemplateM270)


local BLUE_JTAC = SET_GROUP:New():FilterPrefixes( { 'BLUEDrone' } ):FilterOnce()
local BLUEChief = CHIEF:New("blue", BLUE_JTAC, "BLUE Chief")
function BLUEChief:OnAfterDefconChange(From, Event, To, Defcon)
  local text=string.format("Changed DEFCON to %s", Defcon)
  MESSAGE:New(text, 120):ToAll()
end
function BLUEChief:OnAfterStrategyChange(From, Event, To, Strategy)
  local text=string.format("Strategy changd to %s", Strategy)
  MESSAGE:New(text, 120):ToAll()
end

BLUEChief:AddBorderZone(ZONE:FindByName("BLUEBorderZone"))
BLUEChief:AddConflictZone(ZONE:FindByName("ConflictZoneA"))
BLUEChief:AddConflictZone(ZONE:FindByName("ConflictZoneB"))
BLUEChief:AddConflictZone(ZONE:FindByName("ConflictZoneC"))
-- BLUEChief:AddStrategicZone(ZONE:FindByName("StrategicZoneA"))
BLUEChief:SetStrategy(CHIEF.Strategy.TOTALWAR)
BLUEChief:SetDefcon(CHIEF.DEFCON.RED)
BLUEChief:AddBrigade(BLUEBrigade)
