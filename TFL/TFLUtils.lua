
TFL = {
  color = {
    blue = {0,0,1},
    red = {1,0,0},
    green = {0,1,0},
    black = {0,0,0},
    white = {1,1,1},
    grey = {0.5,0.5,0.5},
    contested = {1,1,0},
    yellow = {1,1,0},
    turquoise = {0,1,1},
    magenta = {1,0,1}
  },

  ternary = function( cond , T , F )
    if cond then return T else return F end
  end,

  filter = function(list, test)
    local result = {}
    for index, value in ipairs(list) do
        if test(value, index) then
            result[#result + 1] = value
        end
    end
    return result
  end,

  tableLength = function (T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end,

  tableReverse = function(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
  end
}


function TFLZoneStateColor(state)
  if state == -1 then
    return TFL.color.contested
  elseif state == 0 then
    return TFL.color.grey
  elseif state == 1 then
    return TFL.color.red
  elseif state == 2 then
    return TFL.color.blue
  end
end

function TFLZoneStateText(state, zoneName)
  if state == -1 then
    return zoneName .. " is contested"
  elseif state == 0 then
    return zoneName .. " is empty"
  elseif state == 1 then
    return zoneName .. " is controlled by Red"
  elseif state == 2 then
    return zoneName .. " is controlled by Blue"
  end
end

function TFLMiddleCoordinate(a, b)
  local distance = a:Get2DDistance(b)
  local vector = a:GetDirectionVec3(b)
  local angle = COORDINATE:GetAngleDegrees(vector)
  return a:Translate(distance / 2, angle)
end

function TFLFindEmptyContestedZone(zones, side)
  local oppositeSide = TFL.ternary(side == 1, 2, 1)
  local levels = TFL.ternary(side == 2, zones, TFL.tableReverse(zones))

  for i, l in ipairs(levels) do
    local contested = TFL.filter(l.conflictZones, function(e) return e.state == -1 end)
    if #contested > 0 then return contested[math.random(#contested)] end

    local enemy = TFL.filter(l.conflictZones, function(e) return e.state == oppositeSide end)
    if #enemy > 0 then return enemy[math.random(#enemy)] end

    local empty = TFL.filter(l.conflictZones, function(e) return e.state == 0 end)
    if #empty > 0 then return empty[math.random(#empty)] end
  end
end

function TFLGenerateMissionGroup(warehouse)
  --Basic
  local groupType = warehouse[math.random(#warehouse)]
  if groupType.amount > groupType.groupBy then
    groupType.amount = groupType.amount - groupType.groupBy
    return groupType
  else return end
end