local Character = require 'character'
local Officer = require 'officer'
local Demonstrator = require 'demonstrator'
local Tank = require "tank"
local Gunner = require 'gunner'
local Medic = require 'medic'
local Projectile = require 'projectile'

local STATE_IDLE = "idle"
local STATE_PLACEMENT = "placement"

-- cooldown constants
local COOLDOWN_MELEE = 3
local COOLDOWN_GUNNER = 5
local COOLDOWN_MEDIC = 10
local COOLDOWN_TANK = 30

-- UI constants
local PLACEMENT_SIZE = 100

-- Unit constants
UNIT_TYPE_MELEE = 'melee'
UNIT_TYPE_GUNNER = 'gunner'
UNIT_TYPE_MEDIC = 'medic'
UNIT_TYPE_TANK = 'tank'

GameScene = Scene:extend()

gameworld_officers = {}
gameworld_demonstrators = {}
gameworld_projectiles = {}

function GameScene:new()
   self.state = STATE_IDLE
   -- Fonts
   self.unit_card_font = assets.fonts.hemi_head_bd_it(18)

   -- Assets
   self.img_button_a = love.graphics.newImage('assets/images/xb_a.png')
   self.img_button_b = love.graphics.newImage('assets/images/xb_b.png')
   self.img_button_x = love.graphics.newImage('assets/images/xb_x.png')
   self.img_button_y = love.graphics.newImage('assets/images/xb_y.png')
   self.img_button_dpad = love.graphics.newImage('assets/images/xb_dpad.png')
   self.img_button_left_stick = love.graphics.newImage('assets/images/xb_left_stick.png')

   -- Cooldowns
   self.melee_cooldown = COOLDOWN_MELEE
   self.gunner_cooldown = COOLDOWN_GUNNER
   self.medic_cooldown = COOLDOWN_MEDIC
   self.tank_cooldown = COOLDOWN_TANK
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

   -- remove landed projectiles
   local n = #gameworld_projectiles
   for i=1,n do
      if gameworld_projectiles[i]:hasLanded() then
         gameworld_projectiles[i] = nil
      end
   end

   for i, proj in ipairs(gameworld_projectiles) do
      proj:update(dt)
   end

   self.melee_cooldown = math.max(0, self.melee_cooldown - dt)
   self.gunner_cooldown = math.max(0, self.gunner_cooldown - dt)
   self.medic_cooldown = math.max(0, self.medic_cooldown - dt)
   self.tank_cooldown = math.max(0, self.tank_cooldown - dt)
end

function GameScene:draw()
   love.graphics.clear(67/255, 139/255, 126/255)

   self:drawUnits()
   self:drawProjectiles()

   if self.state == STATE_PLACEMENT then
      self:drawPlacementCursor()
      self:drawPlacementInstructions()
   end

   if self.state == STATE_IDLE then
      self:drawUnitCards()
   end

   -- Mouse pointer rendering
   -- love.graphics.setColor(255, 255, 255)
   -- love.graphics.circle(self.mousePressed and 'fill' or 'line',
   -- self.mouseX, self.mouseY, self.circleRadius, 25)
end

function GameScene:keyPressed(key, code, isRepeat)
   print("Key pressed: " .. key)
   local button = key_to_joy(key)
   if (button ~= nil) then
      self:gamepadpressed(nil, button)
   end
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
      if button == "a" then
         if self:allowNewMelee() then
            self:changeState(STATE_PLACEMENT)
            self.placement_unit = UNIT_TYPE_MELEE
         end
      elseif button == "b" then
         if self:allowNewGunner() then
            self:changeState(STATE_PLACEMENT)
            self.placement_unit = UNIT_TYPE_GUNNER
         end
      elseif button == "x" then
         if self:allowNewMedic() then
            self:changeState(STATE_PLACEMENT)
            self.placement_unit = UNIT_TYPE_MEDIC
         end
      elseif button == "y" then
         if self:allowNewTank() then
            self:changeState(STATE_PLACEMENT)
            self.placement_unit = UNIT_TYPE_TANK
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
   table.insert(gameworld_officers, Officer(600, 400));
   table.insert(gameworld_officers, Officer(600, 600));
   table.insert(gameworld_officers, Officer(600, 800));
   table.insert(gameworld_officers, Tank(200, 500));
   table.insert(gameworld_officers, Gunner(400, 400));
   table.insert(gameworld_officers, Gunner(400, 600));
end

function GameScene:placeUnit()
   local x = self.placement_position.x + (PLACEMENT_SIZE/2)
   local y = self.placement_position.y + (PLACEMENT_SIZE/2)

   if self.placement_unit == UNIT_TYPE_MELEE then
      table.insert(gameworld_demonstrators, Demonstrator(x, y));
      self.melee_cooldown = COOLDOWN_MELEE
   elseif self.placement_unit == UNIT_TYPE_GUNNER then
      table.insert(gameworld_demonstrators, Gunner(x, y));
      self.gunner_cooldown = COOLDOWN_GUNNER
   elseif self.placement_unit == UNIT_TYPE_MEDIC then
      table.insert(gameworld_demonstrators, Medic(x, y));
      self.medic_cooldown = COOLDOWN_MEDIC
   elseif self.placement_unit == UNIT_TYPE_TANK then
      table.insert(gameworld_demonstrators, Tank(x, y));
      self.tank_cooldown = COOLDOWN_TANK
   end

   self:changeState(STATE_IDLE)
end

function GameScene:allowNewMelee()
   return self.melee_cooldown == 0
end

function GameScene:allowNewGunner()
   return self.gunner_cooldown == 0
end

function GameScene:allowNewMedic()
   return self.medic_cooldown == 0
end

function GameScene:allowNewTank()
   return self.tank_cooldown == 0
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

-- Drawing
function GameScene:drawUnits()
   for i, char in ipairs(gameworld_officers) do
      char:draw(0, 0)
   end

   for i, char in ipairs(gameworld_demonstrators) do
      char:draw(0, 0)
   end
end

function GameScene:drawProjectiles()
   for i, proj in ipairs(gameworld_projectiles) do
      proj:draw()
   end
end

function GameScene:drawPlacementCursor()
   love.graphics.setColor(0, 0, 255, 0.5)
   love.graphics.rectangle("fill",
                           self.placement_position.x,
                           self.placement_position.y,
                           PLACEMENT_SIZE, PLACEMENT_SIZE)
end

function GameScene:drawPlacementInstructions()
   local left_anchor = 60
   love.graphics.setColor(255,255,255)
   love.graphics.draw(self.img_button_left_stick, left_anchor, 980)
   love.graphics.draw(self.img_button_dpad, left_anchor + 70, 980)
   love.graphics.print("Mover", left_anchor + 140, 990)

   love.graphics.draw(self.img_button_a, left_anchor + 270, 980)
   love.graphics.print("Enviar", left_anchor + 330, 990)

   love.graphics.draw(self.img_button_b, left_anchor + 450, 980)
   love.graphics.print("Cancelar", left_anchor + 510, 990)
end

function GameScene:drawUnitCards()
   local left_anchor = 60
   local card_width = 200
   local card_height = 200
   local horizontal_spacing = 40

   -- Cards
   love.graphics.setColor(40/255, 40/255, 40/255, 0.9)
   love.graphics.rectangle("fill", left_anchor, 850, card_width, card_height)
   love.graphics.rectangle("fill", left_anchor + 240, 850, card_width, card_height)
   love.graphics.rectangle("fill", left_anchor + 480, 850, card_width, card_height)
   love.graphics.rectangle("fill", left_anchor + 720, 850, card_width, card_height)

   -- Nomes
   love.graphics.setFont(self.unit_card_font)
   love.graphics.setColor(255,255,255)
   love.graphics.print("Infantaria", left_anchor + 55, 860)
   love.graphics.print("Pistoleiro", left_anchor + 305, 860)
   love.graphics.print("Médico", left_anchor + 545, 860)
   love.graphics.print("Tanque", left_anchor + 785, 860)

   -- Atalhos
   if self:allowNewMelee() then
      love.graphics.draw(self.img_button_a,
                         left_anchor - 20,
                         825)
   end

   if self:allowNewGunner() then
      love.graphics.draw(self.img_button_b,
                         left_anchor + 240 - 20,
                         825)
   end

   if self:allowNewMedic() then
      love.graphics.draw(self.img_button_x,
                         left_anchor + 480 - 20,
                         825)
   end

   if self:allowNewTank() then
      love.graphics.draw(self.img_button_y,
                         left_anchor + 720 - 20,
                         825)
   end

   -- Cooldown
   love.graphics.setColor(0, 0, 0)
   love.graphics.rectangle("fill", 75, 1020, 170, 20)
   love.graphics.setColor(255, 127, 0)
   local percentage = 1 - (self.melee_cooldown/COOLDOWN_MELEE)
   love.graphics.rectangle("fill", 75, 1020, 170 * percentage , 20)

   love.graphics.setColor(0, 0, 0)
   love.graphics.rectangle("fill", 315, 1020, 170, 20)
   love.graphics.setColor(255, 127, 0)
   percentage = 1 - (self.gunner_cooldown/COOLDOWN_GUNNER)
   love.graphics.rectangle("fill", 315, 1020, 170 * percentage , 20)

   love.graphics.setColor(0, 0, 0)
   love.graphics.rectangle("fill", 555, 1020, 170, 20)
   love.graphics.setColor(255, 127, 0)
   percentage = 1 - (self.medic_cooldown/COOLDOWN_MEDIC)
   love.graphics.rectangle("fill", 555, 1020, 170 * percentage , 20)

   love.graphics.setColor(0, 0, 0)
   love.graphics.rectangle("fill", 795, 1020, 170, 20)
   love.graphics.setColor(255, 127, 0)
   percentage = 1 - (self.tank_cooldown/COOLDOWN_TANK)
   love.graphics.rectangle("fill", 795, 1020, 170 * percentage , 20)
end

return GameScene
