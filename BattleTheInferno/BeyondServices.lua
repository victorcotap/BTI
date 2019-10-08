env.info("BTI: Starting Services")

HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )

MFAC = MISSION:New( CommandCenter, "Operation Save Vegas",
"A2G", "Attack targets north of Vegas", coalition.side.BLUE )

MGCI = MISSION:New( CommandCenter, "Operation Clear Vegas Skies",
"A2A", "Our new and improved automated GCI service.\nPick up an A2A task based on the situation (easy to communicate over 254AM). It will also assign you directly when you get within 30nm of bandits.\nUse the settings menu to customize reports format and interval", coalition.side.BLUE )

MCSAR = MISSION:New( CommandCenter, "Broken Arrow",
"CSAR", "Go retrieve your fallen comrades", coalition.side.BLUE )


A2ATaskingAvailableGroups = SET_GROUP:New():FilterCoalitions("blue"):FilterPrefixes("Player A2A"):FilterStart()
TaskingAvailableGroups = SET_GROUP:New():FilterCoalitions("blue"):FilterPrefixes("Player A2G"):FilterStart()
HeloAvailableGroups = SET_GROUP:New():FilterCoalitions("blue"):FilterPrefixes("Player Helo"):FilterCategoryHelicopter():FilterStart()

-- Detection
local FACSet = SET_GROUP:New():FilterCoalitions("blue"):FilterPrefixes("BLUE FAC"):FilterStart()
local FACAreas = DETECTION_AREAS:New(FACSet, 1000)
FACAreas:SetRefreshTimeInterval(30)
FACAreas:SetAlphaAngleProbability(1)
FACAreas:SetDistanceProbability(1)
FACAreas:SetAcceptRange( 35000 )
FACAreas:FilterCategories(Unit.Category.GROUND_UNIT)
env.info('BTI: FAC ready');

-- EWR
local EWRSet = SET_GROUP:New():FilterPrefixes( "BLUE EWR" ):FilterCoalitions("blue"):FilterStart()
local EWRDetection = DETECTION_AREAS:New( EWRSet, 21000 )
EWRDetection:SetFriendliesRange( 8000 )
EWRDetection:SetRefreshTimeInterval(60)
env.info('BTI: EWR Ready')

A2GTaskDispatcher = TASK_A2G_DISPATCHER:New(MFAC, TaskingAvailableGroups, FACAreas)

-- Setup the A2A dispatcher, and initialize it.
A2ADispatcher = TASK_A2A_DISPATCHER:New( MGCI, A2ATaskingAvailableGroups, EWRDetection )
A2ADispatcher:SetEngageRadius(45000)
env.info('BTI: Dynamic GCI ready')

-- CSAR
CSARHospital = ZONE:New("BLUE CSAR Nellis")
CSARDispatcher = TASK_CARGO_DISPATCHER:New(MCSAR, HeloAvailableGroups)
CSARDispatcher:StartCSARTasks( "Rescue Pilot", { CSARHospital }, "Go and retrieve one of your comrade that had to eject\nThen bring them to the field hospital")
env.info('BTI: CSAR Dispatcher Ready')

-- DOES NOT WORK BELOW
-- local DesignatorAvailableGroups = TaskingAvailableGroups
-- designator = DESIGNATE:New(CommandCenter, FACAreas, DesignatorAvailableGroups)
-- designator:SetFlashStatusMenu(false)
-- designator:SetThreatLevelPrioritization(true)
-- designator:SetMaximumDistanceDesignations(15000)
-- designator:SetMaximumMarkings(4)
-- -- designator:GenerateLaserCodes()
-- designator:SetLaserCodes(1686)
-- designator:SetMission(MFAC)
-- -- designator:AddMenuLaserCode(1688, "Mirage Laser code to 1688")
-- -- designator:AddMenuLaserCode(1113, "Su-25 Laser code to 1113")
-- designator:SetAutoLase(false, false)

-- env.info('BTI: Designation ready');