local HC = require 'HC'
local push = require 'push'

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
  
  -- load font
  font = love.graphics.newImageFont("images/font.png",
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789#.!?: ")
    
  love.graphics.setFont(font)
  
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
  
  spritesheet = love.graphics.newImage("images/spritesheet.png")
  
  explosion = love.audio.newSource("sfx/explosion.ogg", "static")
  
  friction = 0.2
  
  directions = {"up", "down", "left", "right"}
  inputTable = {}
  inputTable["up"] = {0, -1}
  inputTable["down"] = {0, 1}
  inputTable["left"] = {-1, 0}
  inputTable["right"] = {1, 0}
  
  player = Ship:new(halfGameWidth - 4, halfGameHeight - 4)
  
  spawnDist = math.sqrt(halfGameWidth * halfGameWidth * 2) + 5
  enemySpawnRate = 1
  lastEnemySpawn = enemySpawnRate
  
  ships = {player}
  
  score = 0
  lastScoreInc = 0
  secPerScore = 0.25
  scorePerEnemy = 5
  
  maxSpawnTime = 30
  
  cutoutPoints = {}
  
  ticks = 0
end

function spawnEnemy()
  local spawnAngle = love.math.random() * (2 * math.pi)
  local spawnX = halfGameWidth + math.cos(spawnAngle) * spawnDist
  local spawnY = halfGameHeight + math.sin(spawnAngle) * spawnDist
  local strength = math.min((love.math.random() * (ticks / maxSpawnTime) + 0.3), 1.5)
  
  table.insert(ships, EnemyShip:new(spawnX, spawnY, strength))
end

function cutoutRemoval()
  
end

function cutout()
  collider = HC.new()
  
  local cutoutPolygon = nil
  
  cutoutPolygon = collider:polygon(unpack(cutoutPoints))
  
  local toRemove = {}
  
  for i = 2, #ships do
    local enemy = ships[i]
    local enemyRect = collider:rectangle(
      math.floor(enemy.x) - 5,
      math.floor(enemy.y) - 5,
      enemy.size + 2,
      enemy.size + 2)
    
    if cutoutPolygon:collidesWith(enemyRect) then
      table.insert(toRemove, i)
    end
  end
  
  if #toRemove > 0 then
    explosion:play()
    
    score = score + (#toRemove * scorePerEnemy)
    
    -- remove enemies
    for i = 1, #toRemove do
      print("Removing at index " .. toRemove[i])
      table.remove(ships, toRemove[i])
    end
  end
end

function love.update(dt)
  ticks = ticks + dt
  lastEnemySpawn = lastEnemySpawn + dt
  lastScoreInc = lastScoreInc + dt
  
  if lastScoreInc >= secPerScore then
    score = score + 1
    lastScoreInc = 0
  end
  
  if lastEnemySpawn >= enemySpawnRate then
    spawnEnemy()
    lastEnemySpawn = 0
  end
  
  if love.keyboard.isDown("z") then
    table.insert(cutoutPoints, math.floor(player.x))
    table.insert(cutoutPoints, math.floor(player.y))
  else
    if #cutoutPoints >= 6 then
      pcall(cutout)
    end
    cutoutPoints = {}
  end
  
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
end

function love.draw()
  push:start()
  
  love.graphics.setColor(palette[1])
  love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)
  
  -- draw cutout line
  love.graphics.setColor(palette[3])
  if #cutoutPoints >= 6 then
    love.graphics.polygon("fill", cutoutPoints)
  end
  
  -- draw score
  love.graphics.setColor(palette[3])
  love.graphics.print(score, halfGameWidth - font:getWidth(score) / 2, 1)
  
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
