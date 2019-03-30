local class = require 'middleclass'

local Ship = require "ship"

local EnemyShip = class("EnemyShip", Ship)

function EnemyShip:initialize(initialX, initialY, strength)
  Ship.initialize(self, initialX, initialY)
  
  self.maxSpeed = self.maxSpeed / 4
  self.maxAngVel = self.maxAngVel / 2
  
  self.strength = strength
  
  self.maxSpeed = self.maxSpeed * strength
  self.angAccel = self.angAccel * strength
end

function EnemyShip:update(dt)
  -- ai code
  local inMagX = 0
  local inMagY = -1
  
  local angleTo = math.atan2(player.y - self.y, player.x - self.x)
  self.angle = angleTo
  self.timeSinceInputUpdate = 0
  
  Ship.update(self, dt, inMagX, inMagY)
end

return EnemyShip