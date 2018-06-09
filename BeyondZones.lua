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
    "Test Capture"
}

HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )


for _, zoneName in pairs(ZonesList) do
    CaptureZone = ZONE:New( zoneName )
    ZoneCaptureCoalition = ZONE_CAPTURE_COALITION:New( CaptureZone, coalition.side.BLUE ) 
    ZoneCaptureCoalition:Start( 5, 30 )

    function ZoneCaptureCoalition:OnEnterGuarded( From, Event, To )
        if From ~= To then
            local Coalition = self:GetCoalition()
            self:E( { Coalition = Coalition } )
            if Coalition == coalition.side.BLUE then
                ZoneCaptureCoalition:Smoke( SMOKECOLOR.Blue )
                HQ:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
            else
                ZoneCaptureCoalition:Smoke( SMOKECOLOR.Red )
                HQ:MessageTypeToCoalition( string.format( "%s is under protection of Russia", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
            end
        end
    end

    function ZoneCaptureCoalition:OnEnterEmpty()
        ZoneCaptureCoalition:Smoke( SMOKECOLOR.Green )
        HQ:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    end

    function ZoneCaptureCoalition:OnEnterAttacked()
        ZoneCaptureCoalition:Smoke( SMOKECOLOR.White )
        local Coalition = self:GetCoalition()
        self:E({Coalition = Coalition})
        if Coalition == coalition.side.BLUE then
            HQ:MessageTypeToCoalition( string.format( "%s is under attack by Russia", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        else
            HQ:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        end
    end

    function ZoneCaptureCoalition:OnEnterCaptured()
        local Coalition = self:GetCoalition()
        self:E({Coalition = Coalition})
        if Coalition == coalition.side.BLUE then
            HQ:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        else
            HQ:MessageTypeToCoalition( string.format( "%s is captured by Russia, we lost it!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        end
        
        self:AddScore( "Captured", "Zone captured: Extra points granted.", 200 )    
        
        self:__Guard( 30 )
    end
    
    ZoneCaptureCoalition:__Guard(1)
    ZoneCaptureCoalition:Mark()
end


-- CaptureZone = ZONE:New( "Palm Jebel Ali" )
-- ZoneCaptureCoalition = ZONE_CAPTURE_COALITION:New( CaptureZone, coalition.side.BLUE ) 
-- ZoneCaptureCoalition:Start( 5, 30 )

-- local tacanScheduler = SCHEDULER:New( nil, 
-- function()
--     env.info("we here")
--     local toto = ZoneCaptureCoalition:IsGuarded()
--     local tata = ZoneCaptureCoalition:IsAttacked()
--     env.info("we also here")
--     if ZoneCaptureCoalition:IsGuarded() then
--          env.info("is guarded is true")
--     end
--     if ZoneCaptureCoalition:IsAttacked() then
--         env.info("is Attacked is true")
--     end
--     env.info("we down here")
-- end, {}, 32, 30
-- )

-- ZoneCaptureCoalition:__Guard(1)
-- ZoneCaptureCoalition:Mark()

-- env.info("BTI: Zones set")
