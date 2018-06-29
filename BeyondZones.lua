env.info("BTI: Starting Zones")

ZonesList = {
    -- "Palm Jebel Ali",
    -- "Palm Jumeirah",
    "Dubai Intl",
    "Al Minhad AB",
    "Sharjah Intl",
    "Maritime City",
    "Racetrack",
    "Test Capture 2",
}

HQ = GROUP:FindByName("BLUE CC")
-- Cavalry = GROUP:FindByName("BLUE Cavalry")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )

ZonesCaptureCoalition = {}

function InitZoneCoalition(keyIndex, zoneName)
    env.info(string.format("BTI: Creating new Coalition Zone with index %d and name %s", keyIndex, zoneName))
    CaptureZone = ZONE:New( zoneName )
    local ZoneCaptureCoalition = ZONE_CAPTURE_COALITION:New( CaptureZone, coalition.side.BLUE ) 
    ZoneCaptureCoalition:Start( 5, 60 )

    ZonesCaptureCoalition[keyIndex] = ZoneCaptureCoalition

    function ZoneCaptureCoalition:OnEnterGuarded( From, Event, To )
        if From ~= To then
            local Coalition = self:GetCoalition()
            self:E( { Coalition = Coalition } )
            if Coalition == coalition.side.BLUE then
                -- ZoneCaptureCoalition:Smoke( SMOKECOLOR.Blue )
                CommandCenter:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
            else
                -- ZoneCaptureCoalition:Smoke( SMOKECOLOR.Red )
                CommandCenter:MessageTypeToCoalition( string.format( "%s is under protection of Iran", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
            end
        end
    end

    function ZoneCaptureCoalition:OnEnterEmpty()
        ZoneCaptureCoalition:Smoke( SMOKECOLOR.Green )
        CommandCenter:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        local coordinate = ZoneCaptureCoalition:GetZone():GetCoordinate()
        local newTrucks = TruckSpawn:Spawn()
        newTrucks:RouteGroundOnRoad(coordinate, 40)
        -- Cavalry:RouteGroundOnRoad(coordinate, 35)
    end

    function ZoneCaptureCoalition:OnEnterAttacked()
        -- ZoneCaptureCoalition:Smoke( SMOKECOLOR.White )
        local Coalition = self:GetCoalition()
        self:E({Coalition = Coalition})
        if Coalition == coalition.side.BLUE then
            CommandCenter:MessageTypeToCoalition( string.format( "%s is under attack by Iran", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        else
            CommandCenter:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        end
    end

    function ZoneCaptureCoalition:OnEnterCaptured()
        local Coalition = self:GetCoalition()
        self:E({Coalition = Coalition})
        if Coalition == coalition.side.BLUE then
            CommandCenter:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
            ZoneCaptureCoalition:FlareZone( FLARECOLOR.White, 4 )
        else
            CommandCenter:MessageTypeToCoalition( string.format( "%s is captured by Iran, we lost it!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        end
        
        -- self:AddScore( "Captured", "Zone captured: Extra points granted.", 200 )    
        self:__Guard( 30 )
    end

    ZoneCaptureCoalition:__Guard(1)

    function ZoneMarkingRefresh(keyIndex)
        local Zone = ZonesCaptureCoalition[keyIndex]
        Zone:Mark()
    end

    function ZoneIntelRefresh(keyIndex)
        local Zone = ZonesCaptureCoalition[keyIndex]

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

    SCHEDULER:New(nil, ZoneMarkingRefresh, {keyIndex, zoneName}, 2, 300)
    SCHEDULER:New(nil, ZoneIntelRefresh, {keyIndex, zoneName}, 600, 600)
end

local interval = 5
for keyIndex, zoneName in pairs(ZonesList) do
    local seconds = keyIndex * interval
    SCHEDULER:New(nil, InitZoneCoalition, {keyIndex, zoneName}, seconds)
end

function IntelBriefing()
    CommandCenter:MessageTypeToCoalition("Intel Report to follow\n. Use F10 map markers to find coordinates for each zone.\nCapture them by escorting the convoy that spawns when the zone is undefended.")
end

SCHEDULER:New(nil, IntelBriefing, nil, 600, 600)



























-- for keyIndex, zoneName in pairs(ZonesList) do
--     env.info("BTI: Creating new Coalition Zone with index ")
--     CaptureZone = ZONE:New( zoneName )
--     local ZoneCaptureCoalition = ZONE_CAPTURE_COALITION:New( CaptureZone, coalition.side.BLUE ) 
--     ZoneCaptureCoalition:Start( 5, 30 )

--     ZonesCaptureCoalition[keyIndex] = ZoneCaptureCoalition

--     function ZoneCaptureCoalition:OnEnterGuarded( From, Event, To )
--         if From ~= To then
--             local Coalition = self:GetCoalition()
--             self:E( { Coalition = Coalition } )
--             if Coalition == coalition.side.BLUE then
--                 ZoneCaptureCoalition:Smoke( SMOKECOLOR.Blue )
--                 CommandCenter:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
--             else
--                 -- ZoneCaptureCoalition:Smoke( SMOKECOLOR.Red )
--                 CommandCenter:MessageTypeToCoalition( string.format( "%s is under protection of Russia", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
--             end
--         end
--     end

--     function ZoneCaptureCoalition:OnEnterEmpty()
--         ZoneCaptureCoalition:Smoke( SMOKECOLOR.Green )
--         CommandCenter:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
--         local coordinate = ZoneCaptureCoalition:GetZone():GetCoordinate()
--         local newTrucks = TruckSpawn:Spawn()
--         newTrucks:RouteGroundOnRoad(coordinate)
--         Cavalry:RouteGroundOnRoad(coordinate)
--     end

--     function ZoneCaptureCoalition:OnEnterAttacked()
--         -- ZoneCaptureCoalition:Smoke( SMOKECOLOR.White )
--         local Coalition = self:GetCoalition()
--         self:E({Coalition = Coalition})
--         if Coalition == coalition.side.BLUE then
--             CommandCenter:MessageTypeToCoalition( string.format( "%s is under attack by Russia", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
--         else
--             CommandCenter:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
--         end
--     end

--     function ZoneCaptureCoalition:OnEnterCaptured()
--         local Coalition = self:GetCoalition()
--         self:E({Coalition = Coalition})
--         if Coalition == coalition.side.BLUE then
--             CommandCenter:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
--             ZoneCaptureCoalition:FlareZone( FLARECOLOR.White, 4 )
--         else
--             CommandCenter:MessageTypeToCoalition( string.format( "%s is captured by Russia, we lost it!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
--         end
        
--         self:AddScore( "Captured", "Zone captured: Extra points granted.", 200 )    
        
--         self:__Guard( 30 )
--     end

--     ZoneCaptureCoalition:__Guard(1)

--     -- ZoneCaptureCoalition:Mark()
-- end

-- function ZonesMarkingRefresh()
--     env.info("BTI: Refreshing Zones on the Map ")

--     for keyIndex, zoneName in pairs(ZonesList) do
--         local Zone = ZonesCaptureCoalition[keyIndex]
--         Zone:Mark()


--     end
-- end

-- SCHEDULER:New(nil, ZonesMarkingRefresh, {}, 5, 600)

-- function ZonesIntelRefresh()
--     env.info("BTI: Sending Intel to players ")
--     for keyIndex, zoneName in pairs(ZonesList) do
--         local Zone = ZonesCaptureCoalition[keyIndex]

--         local Coalition = Zone:GetCoalition()
--         if Coalition == coalition.side.BLUE then
--             if Zone:IsGuarded() then
--                 CommandCenter:MessageTypeToCoalition( string.format( " %s is guarded by BLUFOR", ZonesCaptureCoalition[keyIndex]:GetZoneName() ), MESSAGE.Type.Information )
--             elseif Zone:IsAttacked() then
--                 CommandCenter:MessageTypeToCoalition( string.format( " %s is attacked by REDFOR, go help!", ZonesCaptureCoalition[keyIndex]:GetZoneName() ), MESSAGE.Type.Information )
--             elseif Zone:IsEmpty() then
--                 CommandCenter:MessageTypeToCoalition( string.format( " %s is BLUEFOR but empty", ZonesCaptureCoalition[keyIndex]:GetZoneName() ), MESSAGE.Type.Information )
--             elseif Zone:IsCaptured() then
--                 CommandCenter:MessageTypeToCoalition( string.format( " %s is captured by BLUEFOR", ZonesCaptureCoalition[keyIndex]:GetZoneName() ), MESSAGE.Type.Information )
--             end
--         else
--             if Zone:IsGuarded() then
--                 CommandCenter:MessageTypeToCoalition( string.format( " %s is captured by the Russians", ZonesCaptureCoalition[keyIndex]:GetZoneName() ), MESSAGE.Type.Information )
--             elseif Zone:IsAttacked() then
--                 CommandCenter:MessageTypeToCoalition( string.format( " %s is attacked by BLUEFOR. Go help them!", ZonesCaptureCoalition[keyIndex]:GetZoneName() ), MESSAGE.Type.Information )
--             elseif Zone:IsEmpty() then
--                 CommandCenter:MessageTypeToCoalition( string.format( " %s is empty! Go Capture it!", ZonesCaptureCoalition[keyIndex]:GetZoneName() ), MESSAGE.Type.Information )
--             elseif Zone:IsCaptured() then
--                 CommandCenter:MessageTypeToCoalition( string.format( " %s is being captured by Russians! You lost it", ZonesCaptureCoalition[keyIndex]:GetZoneName() ), MESSAGE.Type.Information )
--             end
--         end
--     end
-- end

-- SCHEDULER:New(nil, ZonesIntelRefresh, {}, 20, 300)
