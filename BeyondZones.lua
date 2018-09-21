env.info("BTI: Starting Zones")

local mainLine = "Coast"
local ZonesList = BeyondPersistedStore[mainLine]
local TimeToEvaluate = 60

BlueZonesCounter = 0
RedZonesCounter = 0

HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )
local captureHelos = SPAWN:New('BLUE H Capture')

-- Utils ---------------------------------------------------------------
function tableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end


-- ZONE COALITION ---------------------------------------------------------------------------------------------
function InitZoneCoalition(line, keyIndex, zoneName)
    env.info(string.format("BTI: Creating new Coalition Zone with index %d and name %s", keyIndex, zoneName))
    CaptureZone = ZONE:New( zoneName )
    local ZoneCaptureCoalition = ZONE_CAPTURE_COALITION:New( CaptureZone, coalition.side.RED ) 

    function ZoneCaptureCoalition:OnEnterGuarded( From, Event, To )
        if From ~= To then
            local Coalition = self:GetCoalition()
            self:E( { Coalition = Coalition } )
            if Coalition == coalition.side.BLUE then
                env.info(string.format("BTI: Zone %s is detected guarded, changing persistence", zoneName))

                BeyondPersistedStore[line][keyIndex]["Coalition"] = coalition.side.BLUE
                ZoneCaptureCoalition:Stop()
                CommandCenter:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Update )
            else
                CommandCenter:MessageTypeToCoalition( string.format( "%s is under protection of Iran", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Update )
            end
        end
    end

    function ZoneCaptureCoalition:OnEnterEmpty(From, Event, To)
        local Coalition = self:GetCoalition()
        if From ~= 'Empty' and BeyondPersistedStore[line][keyIndex]["Coalition"] ~= coalition.side.BLUE then
            ZoneCaptureCoalition:Smoke( SMOKECOLOR.Green )
            CommandCenter:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured! Sending Helos", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Update )
            local coordinate = ZoneCaptureCoalition:GetZone():GetCoordinate()
            captureHelos:OnSpawnGroup(
                function(spawnGroup)
                    env.info(string.format("BTI: Sending helos to zone %s", ZoneCaptureCoalition:GetZoneName()))
                    local task = spawnGroup:TaskLandAtZone(ZoneCaptureCoalition.Zone, 60000, true)
                    spawnGroup:SetTask(task)
                end 
            )
            captureHelos:Spawn()
        end
    end

    function ZoneCaptureCoalition:OnEnterAttacked(From, Event, To)
        -- ZoneCaptureCoalition:Smoke( SMOKECOLOR.White )
        local Coalition = self:GetCoalition()
        self:E({Coalition = Coalition})
        if Coalition == coalition.side.BLUE then
            AirQuakeZoneCounterCAS(ZoneCaptureCoalition:GetZone())
            CommandCenter:MessageTypeToCoalition( string.format( "%s is under attack by Iran", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Update )
        else
            CommandCenter:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Update )
        end
    end

    function ZoneCaptureCoalition:OnEnterCaptured(From, Event, To)
        local Coalition = self:GetCoalition()
        self:E({Coalition = Coalition})
        if Coalition == coalition.side.BLUE and BeyondPersistedZones[line][keyIndex]["Coalition"] ~= coalition.side.BLUE then
            env.info(string.format("BTI: Zone %s is detected captured, changing persistence", zoneName))
            BeyondPersistedZones[line][keyIndex]["Coalition"] = coalition.side.BLUE
            BlueZonesCounter = BlueZonesCounter + 1
            RedZonesCounter = RedZonesCounter - 1
            CommandCenter:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Update )
        else
            CommandCenter:MessageTypeToCoalition( string.format( "%s is captured by Iran, we lost it!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Update )
        end
        
        self:__Guard( 30 )
    end

    ZoneCaptureCoalition:Start( 5, TimeToEvaluate )
    ZoneCaptureCoalition:__Guard(1)
    ZoneCaptureCoalition:MonitorDestroyedUnits()
    function ZoneCaptureCoalition:OnAfterDestroyedUnit(From, Event, To, unit, PlayerName)
        env.info(string.format('BTI: Detected destroyed unit %s', Event))
        AirQuakeZoneAttacked(ZoneCaptureCoalition:GetZone())
    end

    function ZoneMarkingRefresh(lineName, keyIndexZone, zoneNameParam)
        local Zone = ZoneCaptureCoalition
        if not Zone then
            env.info(string.format("BTI: DEBUG Couldn't get the zone %s for Refresh %s", zoneNameParam, zoneName))
            return
        end
        Zone:Mark()
    end

    function ZoneIntelRefresh(lineName, keyIndexZone, zoneNameParam)
        local Zone = ZoneCaptureCoalition
        if not Zone then
            env.info(string.format("BTI: DEBUG Couldn't get the zone %s for Intel %s", zoneNameParam, zoneName))
            return
        end
        local Coalition = Zone:GetCoalition()
        if Coalition == coalition.side.BLUE then
            if Zone:IsGuarded() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is guarded by BLUFOR", Zone:GetZoneName() ), MESSAGE.Type.Update )
            elseif Zone:IsAttacked() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is attacked by REDFOR, go help!", Zone:GetZoneName() ), MESSAGE.Type.Update )
            elseif Zone:IsEmpty() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is BLUEFOR but empty", Zone:GetZoneName() ), MESSAGE.Type.Update )
            elseif Zone:IsCaptured() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is captured by BLUEFOR", Zone:GetZoneName() ), MESSAGE.Type.Update )
            end
        else
            if Zone:IsGuarded() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is captured by the Iranians", Zone:GetZoneName() ), MESSAGE.Type.Update )
            elseif Zone:IsAttacked() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is attacked by BLUEFOR. Go help them!", Zone:GetZoneName() ), MESSAGE.Type.Update )
            elseif Zone:IsEmpty() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is empty! Go Capture it!", Zone:GetZoneName() ), MESSAGE.Type.Update )
            elseif Zone:IsCaptured() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is being captured by Iranians! You lost it", Zone:GetZoneName() ), MESSAGE.Type.Update )
            end
        end
    end

    SCHEDULER:New(nil, ZoneMarkingRefresh, {line, keyIndex, zoneName}, 2, 120)
    -- SCHEDULER:New(nil, ZoneIntelRefresh, {line, keyIndex, zoneName}, 900, 900)
end





-- Schedule & init zone engine -----------------------------------------------------------------------------------------------------------------------

-------------------- Read Zones -------------------------------------------------------------------
for keyIndex, zone in pairs(ZonesList) do
    local zoneName = zone["ZoneName"]
    if zone["Coalition"] ~= coalition.side.BLUE then
        RedZonesCounter = RedZonesCounter + 1
    else
        BlueZonesCounter = BlueZonesCounter + 1
    end
end
env.info(string.format( "BTI: Iterating through zones. Red %d, Blue %d", RedZonesCounter, BlueZonesCounter ))

--------------------- Select Zones -----------------------------------------------------------------
local maxZones = RedZonesCounter
if maxZones > 5 then
    maxZones = 5
end

local SelectedZonesList = {}
repeat
    local r = math.random(1,24)
    local selectedZone = ZonesList[r]
    local name = selectedZone["ZoneName"]
    if selectedZone["Coalition"] ~= coalition.side.BLUE then
        SelectedZonesList[name] = true
    end
    env.info(string.format( "BTI: Selecting zone name %s", name))
until ( tableLength(SelectedZonesList) == maxZones)

-------------------- Init Zones -----------------------------------------------------------------------
local interval = 5
for keyIndex, zone in pairs(ZonesList) do
    local seconds = keyIndex * interval
    local zoneName = zone["ZoneName"]
    if zone["Coalition"] ~= coalition.side.BLUE and SelectedZonesList[zoneName] == true then
        -- if SelectedZonesList[zoneName] == true then
            SCHEDULER:New(nil, InitZoneCoalition, {mainLine, keyIndex, zoneName}, seconds)
        -- end
    else
        env.info(string.format("BTI: We need to destroy this zone %s", zoneName))
        local zoneToDestroy = ZONE:New(zoneName)
        local zoneRadiusToDestroy = ZONE_RADIUS:New(zoneName, zoneToDestroy:GetVec2(), 3850)
        local function destroyUnit(zoneUnit)
            env.info(string.format("BTI: Found unit in zone %s, destroying", zoneName))
            zoneUnit:Destroy()
            return true
        end
        zoneRadiusToDestroy:SearchZone(destroyUnit, Object.Category.UNIT)
    end
end


------------------------------------------------------------------------------------------------------------------------------------------------------------------
function IntelBriefing(something)
    -- CommandCenter:MessageTypeToCoalition("Intel Report to follow\n. Use F10 map markers to find coordinates for each zone.\nCapture them by escorting the convoy that spawns when the zone is undefended.")
    env.info(string.format('BTI: Starting Intel Blue %d Red %d', BlueZonesCounter, RedZonesCounter))
end

SCHEDULER:New(nil, IntelBriefing, {"something"}, 20)


