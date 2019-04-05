local class = require 'middleclass.middleclass'

local Ship = require "ship"

local PlayerShip = class("PlayerShip")

function PlayerShip:initialize(initialX, initialY)
  Ship.initialize(self, initialX, initialY)
  self.maxSpeed = 8
end

function PlayerShip:update(dt, inMagX, inMagY)
  local frictionDecay = math.pow(1 - friction, dt)
  
  local accel = 4
  
  local velX = math.cos(self.angle) * self.speed
  local velY = math.sin(self.angle) * self.speed
  
  velX = (velX + (inMagX * accel * dt)) * frictionDecay
  velY = (velY + (inMagY * accel * dt)) * frictionDecay
  
  self.x = self.x + velX
  self.y = self.y + velY
  
  self.angle = math.atan2(velY, velX)
  self.speed = math.sqrt(math.pow(velX, 2) + math.pow(velY, 2))
  
  if self.speed > self.maxSpeed then
    self.speed = self.maxSpeed
  end
  
  if self.speed < -self.maxSpeed then
    self.speed = -self.maxSpeed
  end
end

return PlayerShip