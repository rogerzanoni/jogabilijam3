local Character = require 'character'
local Officer = require 'officer'
local Demonstrator = require 'demonstrator'
local Tank = require "tank"
local Gunner = require 'gunner'
local Medic = require 'medic'

local STATE_IDLE = "idle"
local STATE_PLACEMENT = "placement"

-- other constants
local PLACEMENT_SIZE = 50
local COOLDOWN_DEMONSTRATOR = 300
local COOLDOWN_MEDIC = 300

GameScene = Scene:extend()

gameworld_officers = {}
gameworld_demonstrators = {}

function GameScene:new()
   self.state = STATE_IDLE

   -- Cooldowns
   self.medic_cooldown = 0
   self.demonstrator_cooldown = 0
end

function GameScene:init()
    soundManager:stopAll()
    soundManager:playLoop("battle")
    self:placeInitialTroops()
end

function GameScene:update(dt)
   for i, character in ipairs(gameworld_officers) do
      character:update(dt)
   end

   for i, character in ipairs(gameworld_demonstrators) do
      character:update(dt)
   end
end

function GameScene:draw()
   love.graphics.clear(67/255, 139/255, 126/255)

   love.graphics.print(self.state, 200, 10)

   for i, char in ipairs(gameworld_officers) do
      char:draw(0, 0)
   end

   for i, char in ipairs(gameworld_demonstrators) do
      char:draw(0, 0)
   end

   -- GUI + Overlay
   if self.state == STATE_PLACEMENT then
      love.graphics.setColor(0, 0, 255, 0.5)
      love.graphics.rectangle("fill",
                              self.placement_position.x,
                              self.placement_position.y,
                              PLACEMENT_SIZE, PLACEMENT_SIZE)
   end

   -- Mouse pointer rendering
   -- love.graphics.setColor(255, 255, 255)
   -- love.graphics.circle(self.mousePressed and 'fill' or 'line',
   -- self.mouseX, self.mouseY, self.circleRadius, 25)
end

function GameScene:keyPressed(key, code, isRepeat)
   print("Key pressed: " .. key)
end

-- function GameScene:mousepressed(x, y, button, istouch, presses)
    -- print("Mouse pressed", x, y, button, istouch, presses)
    -- if button == 1 then
        -- self.mousePressed = true
    -- end
-- end

-- function GameScene:mousereleased(x, y, button, istouch, presses)
    -- print("Mouse released", x, y, button, istouch, presses)
    -- if button == 1 then
        -- self.mousePressed = false
    -- end
-- end

-- function GameScene:mousemoved(x, y, dx, dy, istouch)
    -- print("Mouse moved", x, y, dx, dy, istouch)
    -- self.mouseX = x
    -- self.mouseY = y
-- end

-- function GameScene:wheelmoved(dx, dy)
    -- print("Mouse wheel moved", x, y)
    -- self.circleRadius = self.circleRadius + dy
    -- if self.circleRadius < 5 then
        -- self.circleRadius = 5
    -- elseif self.circleRadius > 50 then
        -- self.circleRadius = 50
    -- end
-- end

function GameScene:gamepadpressed(joystick, button)
   print("Gamepad released: " ..  button)
   if self.state == STATE_IDLE then
      if button == "x" then
         if self:allowNewDemonstrator() then
            self:changeState(STATE_PLACEMENT)
            self.placement_unit = Demonstrator
         end
      elseif button == "y" then
         if self:allowNewMedic() then
            self:changeState(STATE_PLACEMENT)
            self.placement_unit = Medic
         end
      end
   elseif self.state == STATE_PLACEMENT then
      if button == "a" then
         self:placeUnit()
      elseif button == "b" then
         self:changeState(STATE_IDLE)
      elseif button == "dpup" then
         self:movePlacementUp()
      elseif button == "dpdown" then
         self:movePlacementDown()
      elseif button == "dpright" then
         self:movePlacementRight()
      elseif button == "dpleft" then
         self:movePlacementLeft()
      end
   end
end

function GameScene:gamepadreleased(joystick, button)
   print("Gamepad pressed: " .. button)
end

function GameScene:changeState(state)
   self.state = state

   if self.state == STATE_IDLE then
      self.placement_position = nil
      self.placement_unit = nil
   elseif self.state == STATE_PLACEMENT then
      self.placement_position = vector(0,0)
   end
end

function GameScene:placeInitialTroops()
   table.insert(gameworld_officers, Officer(600, 200));
   table.insert(gameworld_officers, Officer(600, 250));
   table.insert(gameworld_officers, Tank(434, 350));
   table.insert(gameworld_officers, Officer(600, 300));
   table.insert(gameworld_officers, Officer(600, 350));
   table.insert(gameworld_officers, Gunner(600, 400));
   table.insert(gameworld_officers, Gunner(650, 450));
end

function GameScene:placeUnit()
   local x = self.placement_position.x + (PLACEMENT_SIZE/2)
   local y = self.placement_position.y + (PLACEMENT_SIZE/2)
   table.insert(gameworld_demonstrators, self.placement_unit(x, y));
   self:changeState(STATE_IDLE)
end

function GameScene:allowNewDemonstrator()
   return self.demonstrator_cooldown <= 0
end

function GameScene:allowNewMedic()
   return self.medic_cooldown <= 0
end

function GameScene:movePlacementDown()
   self.placement_position = self.placement_position + vector(0, PLACEMENT_SIZE)
end

function GameScene:movePlacementUp()
   self.placement_position = self.placement_position + vector(0, -PLACEMENT_SIZE)
end

function GameScene:movePlacementRight()
   self.placement_position = self.placement_position + vector(PLACEMENT_SIZE, 0)
end

function GameScene:movePlacementLeft()
   self.placement_position = self.placement_position + vector(-PLACEMENT_SIZE, 0)
end

return GameScene
