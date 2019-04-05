local class = require 'middleclass.middleclass'

local Ship = require "ship"

local PlayerShip = class("PlayerShip")

function PlayerShip:initialize(initialX, initialY)
  Ship.initialize(self, initialX, initialY)
  self.maxSpeed = 10
end

function PlayerShip:update(dt, inMagX, inMagY)
  local frictionDecay = math.pow(1 - friction, dt)
  local accel = 5
  
  -- value is 1 if any movement button is held down, 0 otherwise
  local inputMag = math.max(math.abs(inMagX), math.abs(inMagY))
  
  local inputDirection = math.atan2(inMagY, inMagX)
  local inputForceX = math.cos(inputDirection) * accel * inputMag
  local inputForceY = math.sin(inputDirection) * accel * inputMag
  
  local velX = math.cos(self.angle) * self.speed
  local velY = math.sin(self.angle) * self.speed
  
  velX = (velX + (inputForceX * dt)) * frictionDecay
  velY = (velY + (inputForceY * dt)) * frictionDecay
  
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