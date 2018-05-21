
HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )

MCRGO = MISSION:New( CommandCenter, "Virtual Fedex", "CARGO", "Transport various cargo for FEDEX, kinda...")

HeloAvailableGroups = SET_GROUP:New():FilterCoalitions("blue"):FilterPrefixes("Player Helo"):FilterCategoryHelicopter():FilterStart()





FrontlineZone = ZONE:New("RED Forefront Zone")
FrontlineZoneCoalition = ZONE_CAPTURE_COALITION:New(FrontlineZone, coalition.side.red)
FrontlineZoneCoalition:Start(20, 30)

function FrontlineZoneCoalition:OnEnterGuarded( From, Event, To )
    if From ~= To then
      local Coalition = self:GetCoalition()
      self:E( { Coalition = Coalition } )
      if Coalition == coalition.side.BLUE then
        ZoneCaptureCoalition:Smoke( SMOKECOLOR.Blue )
        US_CC:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        RU_CC:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      else
        ZoneCaptureCoalition:Smoke( SMOKECOLOR.Red )
        RU_CC:MessageTypeToCoalition( string.format( "%s is under protection of Russia", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        US_CC:MessageTypeToCoalition( string.format( "%s is under protection of Russia", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      end
    end
end

function FrontlineZoneCoalition:OnEnterCaptured()
    local Coalition = self:GetCoalition()
    self:E({Coalition = Coalition})
    if Coalition == coalition.side.BLUE then
      RU_CC:MessageTypeToCoalition( string.format( "%s is captured by the USA, we lost it!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      US_CC:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    else
      US_CC:MessageTypeToCoalition( string.format( "%s is captured by Russia, we lost it!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      RU_CC:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    end
end

function FrontlineZoneCoalition:OnEnterEmpty()
    self:Smoke( SMOKECOLOR.Green )
    US_CC:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    RU_CC:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
end

function FrontlineZoneCoalition:OnEnterAttacked()
    ZoneCaptureCoalition:Smoke( SMOKECOLOR.White )
    local Coalition = self:GetCoalition()
    self:E({Coalition = Coalition})
    if Coalition == coalition.side.BLUE then
      US_CC:MessageTypeToCoalition( string.format( "%s is under attack by Russia", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      RU_CC:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    else
      RU_CC:MessageTypeToCoalition( string.format( "%s is under attack by the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      US_CC:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    end
end



env.info('BTI: Zone coalition set')










CargoHospital = ZONE:New("BLUE Cargo Hospital")
CargoMountain = ZONE:New("BLUE Cargo Mountain")
InfantryGroups = SET_CARGO:New():FilterTypes("Infantry"):FilterStart()
LAVGroups = SET_CARGO:New():FilterTypes("APC"):FilterStart()


CargoDispatcher = TASK_CARGO_DISPATCHER:New(MCRGO, HeloAvailableGroups)

local infantryTask = CargoDispatcher:AddTransportTask("Transport Infantry", InfantryGroups, "Transport the infantry somewhere over the rainbow")
CargoDispatcher:SetTransportDeployZones(infantryTask, { CargoHospital, CargoMountain })

local apcTask = CargoDispatcher:AddTransportTask("Transport LAV", LAVGroups, "Transport our APCs to support our troops")
CargoDispatcher:SetTransportDeployZones(apcTask, { CargoHospital })

env.info("BTI: CARGO Dispatcher Ready")

local CrateStaticA = STATIC:FindByName( "Boxes A" )
local CrateStaticB = STATIC:FindByName( "Boxes B" )
local CrateStaticC = STATIC:FindByName( "Boxes C" )
local CrateStaticD = STATIC:FindByName( "Boxes D" )
local CrateCargoA = CARGO_CRATE:New( CrateStaticA, "Boxes", "Crates", 1000, 25 )
local CrateCargoB = CARGO_CRATE:New( CrateStaticB, "Boxes", "Crates", 1000, 25 )
local CrateCargoC = CARGO_CRATE:New( CrateStaticC, "Boxes", "Crates", 1000, 25 )
local CrateCargoD = CARGO_CRATE:New( CrateStaticD, "Boxes", "Crates", 1000, 25 )
local CrateCargoSet = SET_CARGO:New():FilterTypes( "Boxes" ):FilterStart()

local staticTask = CargoDispatcher:AddTransportTask("Slingload crates", CrateCargoSet, "Slingload olympics!! Get those crates to the hospital")
CargoDispatcher:SetTransportDeployZones(staticTask, { CargoHospital })

env.info("BTI: CARGO Static slingload ready")
