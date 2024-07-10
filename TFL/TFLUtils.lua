
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
    magenta = {1,0,1},
    orange = {1,0.647,0},
    purple = {0.627, 0.125, 0.941}
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
  end,

  split = function(str, sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
        table.insert(result, each)
    end
    return result
  end,

  centerVec2s = function(vec2A, vec2B)
    local newX = (vec2A.x + vec2B.x) / 2
    local newY = (vec2A.y + vec2B.y) / 2
    return {x = newX, y = newY}
  end,

  drawMenu = function(coord, lines, unitSize, fontSize, noArrow)
    local unitSize = unitSize or 300
    local lineHeight = unitSize / 4
    local fontSize = fontSize or 14
    local noArrow = noArrow or false

    local markIds = {}
    local buttonsCoords = {}

    local originPoint = coord
    if noArrow == false then
      originPoint = coord:Translate(1000, 135)
      local arrowId = originPoint:ArrowToAll(coord, coalition.side.BLUE, TFL.color.orange, 0.7, TFL.color.orange, 0.2, 1)
      table.insert(markIds, arrowId)
    end

    for i, line in ipairs(lines) do
      local lineOrigin = originPoint
      for i, column in ipairs(line) do
        local size = column.size or 1
        local color = column.color or TFL.color.purple
        local type = column.type or "text"
        local text = column.text

        local contentOriginPoint = originPoint:Translate(lineHeight / 3, 135)
        local nextOriginPoint = originPoint:Translate(unitSize * size, 090)
        local endColumnPoint = nextOriginPoint:Translate(lineHeight, 180)

        local cellId = originPoint:RectToAll(endColumnPoint, coalition.side.BLUE, color, 0.7, color, 0.2, 7)
        table.insert(markIds, cellId)

        if type == "text" and text ~= nil then
          local textOriginPoint = contentOriginPoint:Translate(lineHeight / 4, 180)
          local contentId = textOriginPoint:TextToAll(text, coalition.side.BLUE, TFL.color.white, 0.8, nil, 0.0, fontSize)
          table.insert(markIds, contentId)
        elseif type == "button" then
          local centerVec2 = TFL.centerVec2s(originPoint:GetVec2(), endColumnPoint:GetVec2())
          local centerCoord = COORDINATE:NewFromVec2(centerVec2)
          local contentId = centerCoord:CircleToAll((lineHeight * 0.8) / 2, coalition.side.BLUE, TFL.color.green, 0.9, TFL.color.green, 0.2, 5)

          table.insert(markIds, contentId)
          table.insert(buttonsCoords, centerCoord)
        end

        originPoint = nextOriginPoint
      end
      local newLineOrigin = lineOrigin:Translate(lineHeight, 180)
      originPoint = newLineOrigin
    end
    return markIds, buttonsCoords, originPoint
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

function ccw(a,b,c)
  return (b.x - a.x) * (c.y - a.y) > (b.y - a.y) * (c.x - a.x)
end
function TFLNewConvexHull(pl)
  if #pl == 0 then
      return {}
  end
  table.sort(pl, function(left,right)
      return left.x < right.x
  end)

  local h = {}

  -- lower hull
  for i,pt in pairs(pl) do
      while #h >= 2 and not ccw(h[#h-1], h[#h], pt) do
          table.remove(h,#h)
      end
      table.insert(h,pt)
  end

  -- upper hull
  local t = #h + 1
  for i=#pl, 1, -1 do
      local pt = pl[i]
      while #h >= t and not ccw(h[#h-1], h[#h], pt) do
          table.remove(h,#h)
      end
      table.insert(h,pt)
  end

  table.remove(h,#h)
  return h
end