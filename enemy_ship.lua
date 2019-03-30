local class = require 'middleclass'

local Ship = require "ship"

local EnemyShip = class("EnemyShip", Ship)

function EnemyShip:initialize(initialX, initialY)
  Ship.initialize(self, initialX, initialY)
end

function EnemyShip:update(dt)
  -- ai code
  local inMagX = 1
  local inMagY = 0
  
  Ship.update(self, dt, inMagX, inMagY)
end

return EnemyShip