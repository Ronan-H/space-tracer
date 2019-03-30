local push = require "push"

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")

  gameWidth, gameHeight = 256, 256
  windowWidth, windowHeight = love.window.getDesktopDimensions()

  push:setupScreen(
      gameWidth, gameHeight,
      windowWidth, windowHeight,
      { resizable = false, pixelperfect = true, fullscreen = true})
  
  squareX = 20
  squareY = 20
  squareSize = 1
  squareVelX = 2
  squareVelY = 0
  gravity = 0.02
  terminalVel = 15
end

function love.update(dt)
  squareX = squareX + squareVelX
  squareY = squareY + squareVelY
  
  squareVelY = squareVelY + gravity
  squareVelY = math.min(squareVelY, terminalVel)
  
  if squareY + squareSize >= gameHeight then
    squareVelY = -squareVelY
    squareY = gameHeight - squareSize - 1
  end
  
  if squareX + squareSize >= gameWidth then
    squareVelX = -squareVelX
    squareX = gameWidth - squareSize - 1
  end
  
  if squareX <= 0 then
    squareVelX = -squareVelX
    squareX = 1
  end
end

function love.draw()
  push:start()
  
  love.graphics.setColor(0, 0, 0.2)
  love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)
  
  love.graphics.setColor(1, 0, 0)
  love.graphics.rectangle("fill", math.floor(squareX), math.floor(squareY), squareSize, squareSize)
  
  push:finish()
end
