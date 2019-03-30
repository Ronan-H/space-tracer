local class = require 'middleclass'

local Ship = require "ship"

local EnemyShip = class("EnemyShip", Ship)

function EnemyShip:initialize(initialX, initialY)
  Ship.initialize(self, initialX, initialY)
  
  self.maxSpeed = self.maxSpeed / 4
  self.maxAngVel = self.maxAngVel / 2
  
  self.updateInputInterval = 0.5
  self.timeSinceInputUpdate = 0
end

function EnemyShip:update(dt)
  -- ai code
  local inMagX = 0
  local inMagY = -1
  
  self.timeSinceInputUpdate = self.timeSinceInputUpdate + dt
  
  local angleTo = math.atan2(player.y - self.y, player.x - self.x)
  self.angle = angleTo
  self.timeSinceInputUpdate = 0
  
  Ship.update(self, dt, inMagX, inMagY)
end

return EnemyShip