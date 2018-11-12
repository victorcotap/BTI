_SETTINGS:SetPlayerMenuOff()
----------------------------------------------------------------------------
----------------------------------------------------------------------------
do
    -- declare local variables
    --// exportstring( string )
    --// returns a "Lua" portable version of the string
    local function exportstring( s )
       return string.format("%q", s)
    end
 
    --// The Save Function
    function table.save(  tbl,filename )
       local charS,charE = "   ","\n"
       local file,err = io.open( filename, "wb" )
       if err then return err end
 
       -- initiate variables for save procedure
       local tables,lookup = { tbl },{ [tbl] = 1 }
       file:write( "return {"..charE )
 
       for idx,t in ipairs( tables ) do
          file:write( "-- Table: {"..idx.."}"..charE )
          file:write( "{"..charE )
          local thandled = {}
 
          for i,v in ipairs( t ) do
             thandled[i] = true
             local stype = type( v )
             -- only handle value
             if stype == "table" then
                if not lookup[v] then
                   table.insert( tables, v )
                   lookup[v] = #tables
                end
                file:write( charS.."{"..lookup[v].."},"..charE )
             elseif stype == "string" then
                file:write(  charS..exportstring( v )..","..charE )
             elseif stype == "number" then
                file:write(  charS..tostring( v )..","..charE )
             end
          end
 
          for i,v in pairs( t ) do
             -- escape handled values
             if (not thandled[i]) then
             
                local str = ""
                local stype = type( i )
                -- handle index
                if stype == "table" then
                   if not lookup[i] then
                      table.insert( tables,i )
                      lookup[i] = #tables
                   end
                   str = charS.."[{"..lookup[i].."}]="
                elseif stype == "string" then
                   str = charS.."["..exportstring( i ).."]="
                elseif stype == "number" then
                   str = charS.."["..tostring( i ).."]="
                end
             
                if str ~= "" then
                   stype = type( v )
                   -- handle value
                   if stype == "table" then
                      if not lookup[v] then
                         table.insert( tables,v )
                         lookup[v] = #tables
                      end
                      file:write( str.."{"..lookup[v].."},"..charE )
                   elseif stype == "string" then
                      file:write( str..exportstring( v )..","..charE )
                   elseif stype == "number" then
                      file:write( str..tostring( v )..","..charE )
                   end
                end
             end
          end
          file:write( "},"..charE )
       end
       file:write( "}" )
       file:close()
    end
    
    --// The Load Function
    function table.load( sfile )
       local ftables,err = loadfile( sfile )
       if err then return _,err end
       local tables = ftables()
       for idx = 1,#tables do
          local tolinki = {}
          for i,v in pairs( tables[idx] ) do
             if type( v ) == "table" then
                tables[idx][i] = tables[v[1]]
             end
             if type( i ) == "table" and tables[i[1]] then
                table.insert( tolinki,{ i,tables[i[1]] } )
             end
          end
          -- link indices
          for _,v in ipairs( tolinki ) do
             tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
          end
       end
       return tables[1]
    end
 -- close do
 end
----------------------------------------------------------------------------
----------------------------------------------------------------------------


----------------------------------------------------------------------------
----------------------------------------------------------------------------

----------------------------------------------------------------------------
----------------------------------------------------------------------------

BeyondPersistedStore = {}
local zoneFileName = "Frontlines.lua"
local zoneFilePath = lfs.writedir() .. zoneFileName
env.info(string.format("BTI: Persisted path %s", zoneFilePath))


local someTable = {
    ["Coast"] = {
        [1] = {
            ["ZoneName"] = "Kessel",
            ["Coalition"] = 1,
            ["SideMissions"] = 1
        },
        [2] = {
            ["ZoneName"] = "Felucia",
            ["Coalition"] = 1,
            ["SideMissions"] = 2
        },
        [3] = {
            ["ZoneName"] = "Yavin",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [4] = {
            ["ZoneName"] = "Onderon",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [5] = {
            ["ZoneName"] = "Wobani",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [6] = {
            ["ZoneName"] = "Malachor",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [7] = {
            ["ZoneName"] = "Bespin",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [8] = {
            ["ZoneName"] = "Vardos",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [9] = {
            ["ZoneName"] = "Abafar",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [10] = {
            ["ZoneName"] = "Rishi",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [11] = {
            ["ZoneName"] = "Devaron",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [12] = {
            ["ZoneName"] = "Atollon",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [13] = {
            ["ZoneName"] = "Ando",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [14] = {
            ["ZoneName"] = "Shili",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [15] = {
            ["ZoneName"] = "Cantonica",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [16] = {
            ["ZoneName"] = "Scarif",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [17] = {
            ["ZoneName"] = "Eadu",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [18] = {
            ["ZoneName"] = "Batuu",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [19] = {
            ["ZoneName"] = "Maridun",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [20] = {
            ["ZoneName"] = "Endor",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [21] = {
            ["ZoneName"] = "Mustafar",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [22] = {
            ["ZoneName"] = "Dathomir",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [23] = {
            ["ZoneName"] = "Jedha",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [24] = {
            ["ZoneName"] = "Lego",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
        [25] = {
            ["ZoneName"] = "Mortis",
            ["Coalition"] = 1,
            ["SideMissions"] = 4
        },
    },
    ["AAAAA"] = 3,
    ["Resources"] = {
        ["tank"] = 10,
        ["arty"] = 10,
        ["apc"] = 10,
        ["repair"] = 10,
        ["result"] = 234356
    },
    ["Support"] = {
        ["Helos"] = 2
    }
}


--------------------------------------------------------------------------------------------
-- Persistence engine write -----------------------------------------------------------------
function PERSISTENCERemoveSideMission(ZoneName)
    local zones = BeyondPersistedStore["Coast"]
    for key, zone in pairs(zones) do
        local persistedZoneName = zone["ZoneName"]
        if ZoneName == persistedZoneName then
            local zoneSideMissions = zone["SideMissions"]
            zone["SideMissions"] = zoneSideMissions - 1
            return zone["SideMissions"]
        end
    end
end

--------------------------------------------------------------------------------------------
-- Persistence engine core -----------------------------------------------------------------
function readOrCreateZoneFile(stopLoop)
    local zoneFileTable,error = table.load( zoneFilePath )
    if not zoneFileTable and not stopLoop then
        env.info(string.format("BTI: no file error %s, creating one from source", error))
        saveZoneFile(someTable)

        return readOrCreateZoneFile(true)
    else
        env.info(string.format("BTI: We found a persisted table, using it "))
    end
    return zoneFileTable
end
function saveZoneFile(zoneTableToSave)
    table.save(zoneTableToSave, zoneFilePath)
    env.info("BTI: Persistence Save file complete")
end

function startPersistenceEngine(something)
    local persistedTable = readOrCreateZoneFile(false)
    if not persistedTable then
        env.info(string.format("BTI: ERROR can't read or create persisted file"))
        return
    end
    BeyondPersistedStore = persistedTable
end

function savePersistenceEngine(something)
    saveZoneFile(BeyondPersistedStore)
end
SCHEDULER:New(nil, startPersistenceEngine, {"something"}, 1)
SCHEDULER:New(nil, savePersistenceEngine, {"something"}, 30, 160)