local HC = require 'HC'
local push = require 'push.push'

local Ship = require "ship"
local EnemyShip = require "enemy_ship"
local PlayerShip = require "player_ship"

function reset()
  player = PlayerShip:new(halfGameWidth - halfShipWidth, halfGameHeight - halfShipWidth)
  score = 0
  
  enemySpawnRate = 4
  minEnemySpawnRate = 2
  spawnRateInc = -0.05
  lastEnemySpawn = enemySpawnRate
  
  ships = {player}
  
  scorePerEnemy = 5
  
  maxSpawnTime = 30
  
  cutoutPoints = {}
  
  ticks = 0
end

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
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789#.!?: ", 2)
    
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
  
  shipImage = love.graphics.newImage("images/ship.png")
  
  shipWidth = shipImage:getWidth()
  halfShipWidth = shipWidth / 2
  
  explosion = love.audio.newSource("sfx/explosion.ogg", "static")
  hit = love.audio.newSource("sfx/hit.ogg", "static")
  
  friction = 0.95
  
  directions = {"up", "down", "left", "right"}
  inputTable = {}
  inputTable["up"] = {0, -1}
  inputTable["down"] = {0, 1}
  inputTable["left"] = {-1, 0}
  inputTable["right"] = {1, 0}
  
  spawnDist = math.sqrt(halfGameWidth * halfGameWidth * 2) + math.sqrt(halfShipWidth * halfShipWidth * 2) + 2
end

function spawnEnemy()
  local spawnAngle = love.math.random() * (2 * math.pi)
  local spawnX = halfGameWidth + math.cos(spawnAngle) * spawnDist
  local spawnY = halfGameHeight + math.sin(spawnAngle) * spawnDist
  local strength = math.min((love.math.random() * (ticks / maxSpawnTime) + 0.3), 1.5)
  
  table.insert(ships, EnemyShip:new(spawnX, spawnY, strength))
end

function cutout()
  collider = HC.new()
  
  local cutoutPolygon = nil
  
  cutoutPolygon = collider:polygon(unpack(cutoutPoints))
  
  local toRemove = {}
  
  for i = 2, #ships do
    local enemy = ships[i]
    local enemyRect = collider:rectangle(
      enemy.x,
      enemy.y,
      shipWidth,
      shipWidth)
    
    if cutoutPolygon:collidesWith(enemyRect) then
      table.insert(toRemove, i)
    end
  end
  
  if #toRemove > 0 then
    explosion:play()
    
    score = score + (#toRemove * scorePerEnemy)
    
    -- remove enemies
    for i = #toRemove, 1, -1 do
      table.remove(ships, toRemove[i])
    end
  end
end

function playerTouchingEnemy()
  collider = HC.new()
  
  local toRemove = {}
  
  local playerRect = collider:rectangle(
      player.x,
      player.y,
      shipWidth,
      shipWidth)
  
  for i = 2, #ships do
    local enemy = ships[i]
    local enemyRect = collider:rectangle(
      enemy.x,
      enemy.y,
      shipWidth,
      shipWidth)
    
    if playerRect:collidesWith(enemyRect) then
      return true
    end
  end
  
  return false
end

function playerOutOfBounds()
  return player.x <= 0
    or player.x + shipWidth >= gameWidth
    or player.y <= 0
    or player.y + shipWidth >= gameHeight
end

function love.update(dt)
  if score == nil then
    reset()
  end
  
  ticks = ticks + dt
  lastEnemySpawn = lastEnemySpawn + dt
  enemySpawnRate = math.max(enemySpawnRate + (spawnRateInc * dt), 1)
  
  if playerTouchingEnemy() or playerOutOfBounds() then
    hit:play()
    reset()
  end
  
  if lastEnemySpawn >= enemySpawnRate then
    spawnEnemy()
    lastEnemySpawn = 0
  end
  
  if love.keyboard.isDown("z") then
    table.insert(cutoutPoints, player.x + halfShipWidth)
    table.insert(cutoutPoints, player.y + halfShipWidth)
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
      shipImage,
      ship.x + halfShipWidth,
      ship.y + halfShipWidth,
      ship.angle,
      1, 1,
      halfShipWidth, halfShipWidth)
  end
  
  push:finish()
end
