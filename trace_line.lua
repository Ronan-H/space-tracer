local class = require 'middleclass.middleclass'

local HC = require 'HC'

local TraceLine = class("TraceLine")

function TraceLine:initialize(maxPoints)
    self:resetPoints()
    self.maxPoints = maxPoints
    self.polygon = nil
end

function TraceLine:createPolygon()
    local polyPoints = {}
    
    for i = 1, self:numPoints() do
        local row = self.pointsList[i]
        table.insert(polyPoints, row[1])
        table.insert(polyPoints, row[2])
    end
    
    self.polygon = collider:polygon(unpack(polyPoints))
end

function TraceLine:killShipsInsidePolygon(ships)
    local toRemove = {}
  
    for i = 2, #ships do
        local enemy = ships[i]
        local enemyRect = collider:rectangle(
        enemy.x,
        enemy.y,
        shipWidth,
        shipWidth)
    
        if self.polygon:collidesWith(enemyRect) then
            table.insert(toRemove, i)
        end
    end
  
    if #toRemove > 0 then
        explosion:play()
    
        score = score + (#toRemove * scorePerEnemy)
    
        -- remove enemies
        for i = #toRemove, 1, -1 do
            table.remove(ships, toRemove[i])
        end
    end
end

function TraceLine.static:getPointAsString(x, y)
    return table.concat(
        {
            math.floor(x),
            math.floor(y)
        }
    )
end

function TraceLine:numPoints()
    return #self.pointsList
end

function TraceLine:resetPoints()
    self.pointsList = {}
    self.pointsSet = {}
end

function TraceLine:addPoint(x, y)
    local pointString = TraceLine:getPointAsString(x, y)
    
    if self.pointsSet[pointString] == nil then
        self.pointsSet[pointString] = true
        table.insert(self.pointsList, {x, y})
        
        if self:numPoints() > self.maxPoints then
            self:removePoint(1)
        end
    end
end

function TraceLine:removePoint(index)
    local pointRemovedStr = TraceLine:getPointAsString(unpack(self.pointsList[index]))
    table.remove(self.pointsList, index)
    self.pointsSet[pointRemovedStr] = nil
end

function TraceLine:removeLastPoint()
    self:removePoint(self:numPoints())
end

function TraceLine:hasPoint(x, y)
    return self.pointsSet[getPointAsString(x, y)] ~= nil
end

function TraceLine:update(player, ships)
    self:addPoint(player.x + halfShipWidth, player.y + halfShipWidth)
    
    if self:numPoints() >= 3 then
        local success, errorMessage = pcall(function() self:createPolygon() end)
        
        if not success and string.match(errorMessage, "Polygon may not intersect itself") then
            -- print("Error: " .. errorMessage)
            
            self:removeLastPoint()
            self:createPolygon()
            self:killShipsInsidePolygon(ships)
            self:resetPoints()
        end
    end
end

function TraceLine:draw()
    if self:numPoints() >= 2 then
        love.graphics.setColor(palette[3])
        for i = 1, self:numPoints() - 1 do
            love.graphics.line(self.pointsList[i][1],
                               self.pointsList[i][2],
                               self.pointsList[i + 1][1],
                               self.pointsList[i + 1][2])
        end
    end
end

return TraceLine