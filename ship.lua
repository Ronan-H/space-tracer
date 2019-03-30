local class = require 'middleclass'

local Ship = class("Ship")

function Ship:initialize(initialX, initialY)
  self.x = initialX
  self.y = initialY
  self.angle = 0
  self.angVel = 0
  self.angAccel = 30
  self.maxAngVel = 3
  self.speed = 0
  self.accel = 150
  self.maxSpeed = 100
  self.size = 8
end

function Ship:update(dt, inMagX, inMagY)
  local frictionDecay = math.pow(friction, dt)
  
  self.angVel = self.angVel + (self.angAccel * inMagX * dt)
  
  self.angle = (self.angle + self.angVel * dt) % (math.pi * 2)
  self.angVel = self.angVel * frictionDecay
  self.angVel = math.min(self.angVel, self.maxAngVel)
  self.angVel = math.max(self.angVel, -self.maxAngVel)
  
  self.speed = self.speed + (self.accel * -inMagY * dt)
  -- TODO account for delta value in friction?
  self.speed = self.speed * frictionDecay
  self.speed = math.min(self.speed, self.maxSpeed)
  self.speed = math.max(self.speed, -self.maxSpeed)
  
  self.x = self.x + (math.cos(self.angle) * self.speed) * dt
  self.y = self.y + (math.sin(self.angle) * self.speed) * dt
end

return Ship