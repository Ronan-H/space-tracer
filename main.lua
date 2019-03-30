local push = require "push"

local Ship = require "ship"
local EnemyShip = require "enemy_ship"

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")

  gameWidth, gameHeight = 160, 144
  halfGameWidth = gameWidth / 2
  halfGameHeight = gameHeight / 2
  windowWidth, windowHeight = love.window.getDesktopDimensions()

  push:setupScreen(
      gameWidth, gameHeight,
      windowWidth, windowHeight,
      { resizable = false, pixelperfect = true, fullscreen = true})
  
  palette = {}
  palette[1] = {155, 188, 15}
  palette[2] = {139, 172, 15}
  palette[3] = {48, 98, 48}
  palette[4] = {15, 56, 15}
  
  for i = 1, 4 do
    for j = 1, 3 do
      palette[i][j] = palette[i][j] / 255
    end
  end
  
  spritesheet = love.graphics.newImage("spritesheet.png")
  
  friction = 0.3
  
  directions = {"up", "down", "left", "right"}
  inputTable = {}
  inputTable["up"] = {0, -1}
  inputTable["down"] = {0, 1}
  inputTable["left"] = {-1, 0}
  inputTable["right"] = {1, 0}
  
  player = Ship:new(halfGameWidth - 4, halfGameHeight - 4)
  
  enemies = {}
  enemies[1] = EnemyShip:new(10, 10)
  
  ships = {player}
  
  for i = 1, #enemies do
    ships[i + 1] = enemies[i]
  end
  
  ticks = 0
end

function love.update(dt)
  -- update player's angle/speed based on keyboard input
  local inMagX, inMagY = 0, 0
  for i = 1, #directions do
    if love.keyboard.isDown(directions[i]) then
      inMagX = inMagX + inputTable[directions[i]][1]
      inMagY = inMagY + inputTable[directions[i]][2]
    end
  end
  
  for i = 1, #ships do
    ships[i]:update(dt, inMagX, inMagY)
  end
  
  ticks = ticks + dt
end

function love.draw()
  push:start()
  
  love.graphics.setColor(palette[1])
  love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)
  
  for i = 1, #ships do
    local ship = ships[i]
    love.graphics.draw(
      spritesheet,
      math.floor(ship.x),
      math.floor(ship.y),
      ship.angle,
      1, 1,
      4, 4)
  end
  
  push:finish()
end
