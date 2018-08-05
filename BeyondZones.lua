env.info("BTI: Starting Zones")

QeshmZonesList = BeyondPersistedZones["Qeshm"]

HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )

ZonesCaptureCoalitions = {}

function InitZoneCoalition(line, keyIndex, zoneName)
    env.info(string.format("BTI: Creating new Coalition Zone with index %d and name %s", keyIndex, zoneName))
    CaptureZone = ZONE:New( zoneName )
    local ZoneCaptureCoalition = ZONE_CAPTURE_COALITION:New( CaptureZone, coalition.side.RED ) 
    ZoneCaptureCoalition:Start( 5, 60 )

    ZonesCaptureCoalitions[line] = {}
    ZonesCaptureCoalitions[line][keyIndex] = ZoneCaptureCoalition

    function ZoneCaptureCoalition:OnEnterGuarded( From, Event, To )
        if From ~= To then
            local Coalition = self:GetCoalition()
            self:E( { Coalition = Coalition } )
            if Coalition == coalition.side.BLUE then
                env.info("BTI: Zone is detected guarded, changing persistence")

                BeyondPersistedZones[line][keyIndex]["Coalition"] = coalition.side.BLUE
                CommandCenter:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
            else
                CommandCenter:MessageTypeToCoalition( string.format( "%s is under protection of Iran", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
            end
        end
    end

    function ZoneCaptureCoalition:OnEnterEmpty(From, Event, To)
        if From ~= 'Empty' then
            ZoneCaptureCoalition:Smoke( SMOKECOLOR.Green )
        end
        CommandCenter:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        local coordinate = ZoneCaptureCoalition:GetZone():GetCoordinate()
        -- local newTrucks = TruckSpawn:Spawn()
        -- newTrucks:RouteGroundOnRoad(coordinate, 70)
        -- Cavalry:RouteGroundOnRoad(coordinate, 35)
    end

    function ZoneCaptureCoalition:OnEnterAttacked(From, Event, To)
        -- ZoneCaptureCoalition:Smoke( SMOKECOLOR.White )
        local Coalition = self:GetCoalition()
        self:E({Coalition = Coalition})
        if Coalition == coalition.side.BLUE then
            CommandCenter:MessageTypeToCoalition( string.format( "%s is under attack by Iran", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        else
            CommandCenter:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        end
    end

    function ZoneCaptureCoalition:OnEnterCaptured(From, Event, To)
        local Coalition = self:GetCoalition()
        self:E({Coalition = Coalition})
        if Coalition == coalition.side.BLUE then
            if From ~= 'Empty' then
                env.info("BTI: Zone is detected captured, changing persistence")
                BeyondPersistedZones[line][keyIndex]["Coalition"] = coalition.side.BLUE
            end
            CommandCenter:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        else
            CommandCenter:MessageTypeToCoalition( string.format( "%s is captured by Iran, we lost it!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        end
        
        -- self:AddScore( "Captured", "Zone captured: Extra points granted.", 200 )    
        self:__Guard( 30 )
    end

    ZoneCaptureCoalition:__Guard(1)

    function ZoneMarkingRefresh(line, keyIndex, zoneName)
        env.info(string.format("BTI: DEBUG line %s, key %d, name %s", line, keyIndex, zoneName))
        local Zone = ZonesCaptureCoalitions[line][keyIndex]
        if not Zone then
            env.info("BTI: DEBUG Couldn't get the zone")
            return
        end
        Zone:Mark()
    end

    function ZoneIntelRefresh(line, keyIndex, zoneName)
        local Zone = ZonesCaptureCoalitions[line][keyIndex]

        local Coalition = Zone:GetCoalition()
        if Coalition == coalition.side.BLUE then
            if Zone:IsGuarded() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is guarded by BLUFOR", Zone:GetZoneName() ), MESSAGE.Type.Information )
            elseif Zone:IsAttacked() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is attacked by REDFOR, go help!", Zone:GetZoneName() ), MESSAGE.Type.Information )
            elseif Zone:IsEmpty() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is BLUEFOR but empty", Zone:GetZoneName() ), MESSAGE.Type.Information )
            elseif Zone:IsCaptured() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is captured by BLUEFOR", Zone:GetZoneName() ), MESSAGE.Type.Information )
            end
        else
            if Zone:IsGuarded() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is captured by the Iranians", Zone:GetZoneName() ), MESSAGE.Type.Information )
            elseif Zone:IsAttacked() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is attacked by BLUEFOR. Go help them!", Zone:GetZoneName() ), MESSAGE.Type.Information )
            elseif Zone:IsEmpty() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is empty! Go Capture it!", Zone:GetZoneName() ), MESSAGE.Type.Information )
            elseif Zone:IsCaptured() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is being captured by Iranians! You lost it", Zone:GetZoneName() ), MESSAGE.Type.Information )
            end
        end
    end

    SCHEDULER:New(nil, ZoneMarkingRefresh, {line, keyIndex, zoneName}, 2, 30)
    SCHEDULER:New(nil, ZoneIntelRefresh, {line, keyIndex, zoneName}, 600, 600)
end

local interval = 5
for keyIndex, zone in pairs(QeshmZonesList) do
    local seconds = keyIndex * interval
    if zone["Coalition"] ~= coalition.side.BLUE then
        SCHEDULER:New(nil, InitZoneCoalition, {"Qeshm", keyIndex, zone["ZoneName"]}, seconds)
    else
        env.info("BTI: We need to destroy this zone")
    end
end

function IntelBriefing()
    CommandCenter:MessageTypeToCoalition("Intel Report to follow\n. Use F10 map markers to find coordinates for each zone.\nCapture them by escorting the convoy that spawns when the zone is undefended.")
end

SCHEDULER:New(nil, IntelBriefing, nil, 600, 600)






















