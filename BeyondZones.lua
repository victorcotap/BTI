env.info("BTI: Starting Zones")

ZonesList = {
    "Palm Jebel Ali",
    "Palm Jumeirah",
    "Al Makthoum Intl",
    "Al Dhafra AB",
    "Dubai Intl",
    "Sharjah Intl",
    "Maritime City",
    "Margham",
    "Al Dhaid",
    "Camel Racetrack",
    "Test Capture",
    "Test Capture 2",
}

HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "USA HQ" )

ZonesCaptureCoalition = {}

for keyIndex, zoneName in pairs(ZonesList) do
    env.info("BTI: Creating new Coalition Zone with index ")
    CaptureZone = ZONE:New( zoneName )
    local ZoneCaptureCoalition = ZONE_CAPTURE_COALITION:New( CaptureZone, coalition.side.BLUE ) 
    ZoneCaptureCoalition:Start( 5, 30 )

    ZonesCaptureCoalition[keyIndex] = ZoneCaptureCoalition

    function ZoneCaptureCoalition:OnEnterGuarded( From, Event, To )
        if From ~= To then
            local Coalition = self:GetCoalition()
            self:E( { Coalition = Coalition } )
            if Coalition == coalition.side.BLUE then
                ZoneCaptureCoalition:Smoke( SMOKECOLOR.Blue )
                CommandCenter:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
            else
                -- ZoneCaptureCoalition:Smoke( SMOKECOLOR.Red )
                CommandCenter:MessageTypeToCoalition( string.format( "%s is under protection of Russia", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
            end
        end
    end

    function ZoneCaptureCoalition:OnEnterEmpty()
        ZoneCaptureCoalition:Smoke( SMOKECOLOR.Green )
        CommandCenter:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    end

    function ZoneCaptureCoalition:OnEnterAttacked()
        -- ZoneCaptureCoalition:Smoke( SMOKECOLOR.White )
        local Coalition = self:GetCoalition()
        self:E({Coalition = Coalition})
        if Coalition == coalition.side.BLUE then
            CommandCenter:MessageTypeToCoalition( string.format( "%s is under attack by Russia", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        else
            CommandCenter:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        end
    end

    function ZoneCaptureCoalition:OnEnterCaptured()
        local Coalition = self:GetCoalition()
        self:E({Coalition = Coalition})
        if Coalition == coalition.side.BLUE then
            CommandCenter:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        else
            CommandCenter:MessageTypeToCoalition( string.format( "%s is captured by Russia, we lost it!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        end
        
        self:AddScore( "Captured", "Zone captured: Extra points granted.", 200 )    
        
        self:__Guard( 30 )
    end

    ZoneCaptureCoalition:__Guard(1)

    -- ZoneCaptureCoalition:Mark()
end

function ZonesMarkingRefresh()
    env.info("BTI: Refreshing Zones on the Map ")

    for keyIndex, zoneName in pairs(ZonesList) do
        local Zone = ZonesCaptureCoalition[keyIndex]
        Zone:Mark()

        local Coalition = Zone:GetCoalition()
        if Coalition == coalition.side.BLUE then
            CommandCenter:MessageTypeToCoalition( string.format( "Zone %s is ours", ZonesCaptureCoalition[keyIndex]:GetZoneName() ), MESSAGE.Type.Information )
        else
            CommandCenter:MessageTypeToCoalition( string.format( "Zone %s is captured by the Russians", ZonesCaptureCoalition[keyIndex]:GetZoneName() ), MESSAGE.Type.Information )
        end
    end
end

SCHEDULER:New(nil, ZonesMarkingRefresh, {}, 5, 30)
