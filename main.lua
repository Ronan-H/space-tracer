local push = require "push"

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")

  gameWidth, gameHeight = 256, 256
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
  
  player = {
    x = halfGameWidth,
    y = halfGameHeight,
    angle = 0,
    angVel = 0,
    angAccel = 1,
    maxAngVel = math.pi,
    speed = 0,
    accel = 0,
    maxSpeed = 10
  }
  
  friction = 0.5
  
  directions = {"up", "down", "left", "right"}
  inputTable = {}
  inputTable["up"] = {0, -1}
  inputTable["down"] = {0, 1}
  inputTable["left"] = {-1, 0}
  inputTable["right"] = {1, 0}
  
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
  
  player.angVel = player.angVel + (player.angVel * player.angAccel * inMagX * dt)
  player.speed = player.speed + (player.accel * inMagY * dt)
  
  player.angle = player.angle + player.angVel
  player.angVel = math.min(player.angVel, player.maxAngVel)
  player.angVel = math.max(player.angVel, -player.maxAngVel)
  
  -- TODO account for delta value in friction?
  -- player.speed = player.speed * friction
  player.speed = math.min(player.angVel, player.maxSpeed)
  player.speed = math.max(player.angVel, -player.maxSpeed)
  
  player.x = player.x + (math.cos(player.angle) * player.speed) * dt
  player.y = player.y + (math.sin(player.angle) * player.speed) * dt
  
  ticks = ticks + dt
end

function love.draw()
  push:start()
  
  love.graphics.setColor(palette[1])
  love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)
  
  love.graphics.draw(spritesheet, math.floor(player.x), math.floor(player.y), player.angle, 1, 1, 4, 4)
  
  push:finish()
end
