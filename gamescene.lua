local Character = require 'character'
local Officer = require 'officer'
local Demonstrator = require 'demonstrator'
local EventManager = require 'eventmanager'
local Tank = require "tank"
local Gunner = require 'gunner'
local Medic = require 'medic'
local Projectile = require 'projectile'

local STATE_IDLE = "idle"
-- TODO: plan other states (gameover, victory, pause?)

-- cooldown constants
local COOLDOWN_MELEE = 3
local COOLDOWN_GUNNER = 5
local COOLDOWN_MEDIC = 10
local COOLDOWN_TANK = 30

-- UI constants
local PLACEMENT_WIDTH = CONF_SCREEN_WIDTH / 16
local PLACEMENT_HEIGHT = CONF_SCREEN_HEIGHT / 9
local PLACEMENT_MOVE_INTERVAL = 0.1

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
   self.placement_position = vector(CONF_SCREEN_WIDTH - PLACEMENT_WIDTH,
                                    CONF_SCREEN_HEIGHT / PLACEMENT_HEIGHT / 2 * PLACEMENT_HEIGHT)
   -- Fonts
   self.unit_card_font = assets.fonts.hemi_head_bd_it(18)
   self.up_pressed = false
   self.down_pressed = false
   self.left_pressed = false
   self.right_pressed = false
   self.placement_elapsed = 0.0

   -- Assets
   self.img_button_a = love.graphics.newImage('assets/images/xb_a.png')
   self.img_button_b = love.graphics.newImage('assets/images/xb_b.png')
   self.img_button_x = love.graphics.newImage('assets/images/xb_x.png')
   self.img_button_y = love.graphics.newImage('assets/images/xb_y.png')
   self.img_button_dpad = love.graphics.newImage('assets/images/xb_dpad.png')
   self.img_button_left_stick = love.graphics.newImage('assets/images/xb_left_stick.png')

   self.img_key_z = love.graphics.newImage('assets/images/key_z.png')
   self.img_key_x = love.graphics.newImage('assets/images/key_x.png')
   self.img_key_a = love.graphics.newImage('assets/images/key_a.png')
   self.img_key_s = love.graphics.newImage('assets/images/key_s.png')
   self.img_key_arrows = love.graphics.newImage('assets/images/key_arrows.png')

   self.img_tank_icon = love.graphics.newImage('assets/images/tank-icon.png')
   self.img_medic_icon = love.graphics.newImage('assets/images/medic-icon.png')
   self.img_gunner_icon = love.graphics.newImage('assets/images/gunner-icon.png')
   self.img_melee_icon = love.graphics.newImage('assets/images/melee-icon.png')

   -- Cooldowns
   self.melee_cooldown = COOLDOWN_MELEE
   self.gunner_cooldown = COOLDOWN_GUNNER
   self.medic_cooldown = COOLDOWN_MEDIC
   self.tank_cooldown = COOLDOWN_TANK
   self.eventManager = EventManager(assets.scripts.events.gamescene)
end

function GameScene:init()
    soundManager:stopAll()
    soundManager:playLoop("battle")
    self.eventManager:init()
end

function GameScene:update(dt)
    self.eventManager:update(dt)

   for i, character in ipairs(gameworld_officers) do
      character:update(dt)
   end

   for i, character in ipairs(gameworld_demonstrators) do
      character:update(dt)
   end

   -- remove landed projectiles
   local n = #gameworld_projectiles
   for i=1,n do
      if gameworld_projectiles[i] ~= nil and gameworld_projectiles[i]:hasLanded() then
         gameworld_projectiles[i] = nil
      end
   end

   for i, proj in ipairs(gameworld_projectiles) do
      proj:update(dt)
   end

   self:updatePlacement(dt)

   self.melee_cooldown = math.max(0, self.melee_cooldown - dt)
   self.gunner_cooldown = math.max(0, self.gunner_cooldown - dt)
   self.medic_cooldown = math.max(0, self.medic_cooldown - dt)
   self.tank_cooldown = math.max(0, self.tank_cooldown - dt)
end

function GameScene:draw()
   love.graphics.clear(67/255, 139/255, 126/255)

   self:drawUnits()
   self:drawProjectiles()

   self:drawPlacementCursor()

   self:drawPlacementInstructions()

   -- self:drawUnitCards()
   self:drawUnitButtons()

   -- Mouse pointer rendering
   -- love.graphics.setColor(255, 255, 255)
   -- love.graphics.circle(self.mousePressed and 'fill' or 'line',
   -- self.mouseX, self.mouseY, self.circleRadius, 25)
end

function GameScene:keyPressed(key, code, isRepeat)
   local button = key_to_joy(key)
   if (button ~= nil) then
      self:gamepadpressed(nil, button)
   end
end

function GameScene:keyReleased(key, code, isRepeat)
   local button = key_to_joy(key)
   if (button ~= nil) then
      self:gamepadreleased(nil, button)
   end
end

function GameScene:gamepadaxis(joystick, axis, value)
   if axis == 'lefty' then
      if value == 1 then
         self:movePlacementDown()
      elseif value == -1 then
         self:movePlacementUp()
      end
   elseif axis == 'leftx' then
      if value == 1 then
         self:movePlacementRight()
      elseif value == -1 then
         self:movePlacementLeft()
      end
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

function GameScene:updatePlacement(dt)
    self.placement_elapsed = self.placement_elapsed + dt

    if self.placement_elapsed >= PLACEMENT_MOVE_INTERVAL then
        self.placement_elapsed = 0.0

        if self.up_pressed then
            self:movePlacementUp()
        elseif self.down_pressed then
            self:movePlacementDown()
        elseif self.left_pressed then
            self:movePlacementLeft()
        elseif self.right_pressed then
            self:movePlacementRight()
        end
    end
end

function GameScene:gamepadpressed(joystick, button)
   if button == "a" then
      if self:allowNewMelee() then
         self:placeUnit(UNIT_TYPE_MELEE)
      end
   elseif button == "b" then
      if self:allowNewGunner() then
         self:placeUnit(UNIT_TYPE_GUNNER)
      end
   elseif button == "x" then
      if self:allowNewMedic() then
         self:placeUnit(UNIT_TYPE_MEDIC)
      end
   elseif button == "y" then
      if self:allowNewTank() then
         self:placeUnit(UNIT_TYPE_TANK)
      end
   end

   if button == "dpup" then
      self.up_pressed = true
   elseif button == "dpdown" then
      self.down_pressed = true
   elseif button == "dpright" then
      self.right_pressed = true
   elseif button == "dpleft" then
      self.left_pressed = true
   end
end

function GameScene:gamepadreleased(joystick, button)
   if button == "dpup" then
      self.up_pressed = false
   elseif button == "dpdown" then
      self.down_pressed = false
   elseif button == "dpright" then
      self.right_pressed = false
   elseif button == "dpleft" then
      self.left_pressed = false
   end
end

function GameScene:changeState(state)
   self.state = state
end

function GameScene:placeUnit(unit_type)
   local x = self.placement_position.x + (PLACEMENT_WIDTH/2)
   local y = self.placement_position.y + (PLACEMENT_HEIGHT/2)

   if unit_type == UNIT_TYPE_MELEE then
      table.insert(gameworld_demonstrators, Demonstrator(x, y, 100, 30));
      self.melee_cooldown = COOLDOWN_MELEE
   elseif unit_type == UNIT_TYPE_GUNNER then
      table.insert(gameworld_demonstrators, Gunner(x, y, 100, 70));
      self.gunner_cooldown = COOLDOWN_GUNNER
   elseif unit_type == UNIT_TYPE_MEDIC then
      table.insert(gameworld_demonstrators, Medic(x, y, 100, -20));
      self.medic_cooldown = COOLDOWN_MEDIC
   elseif unit_type == UNIT_TYPE_TANK then
      table.insert(gameworld_demonstrators, Tank(x, y, 1000, 150));
      self.tank_cooldown = COOLDOWN_TANK
   end
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

function GameScene:clampPlacement(increment)
   local new_pos = self.placement_position + increment
   new_pos.x = math.Clamp(new_pos.x, CONF_SCREEN_WIDTH - (3*PLACEMENT_WIDTH) , CONF_SCREEN_WIDTH - PLACEMENT_WIDTH)
   new_pos.y = math.Clamp(new_pos.y, 0, CONF_SCREEN_HEIGHT - PLACEMENT_HEIGHT)
   self.placement_position = new_pos
end

function GameScene:movePlacementDown()
   self:clampPlacement(vector(0, PLACEMENT_HEIGHT))
end

function GameScene:movePlacementUp()
   self:clampPlacement(vector(0, -PLACEMENT_HEIGHT))
end

function GameScene:movePlacementRight()
   self:clampPlacement(vector(PLACEMENT_WIDTH, 0))
end

function GameScene:movePlacementLeft()
   self:clampPlacement(vector(-PLACEMENT_WIDTH), 0)
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
   love.graphics.setColor(1, 0, 0, 1)
   love.graphics.setLineWidth(2)

   local corner_x = self.placement_position.x
   local corner_y = self.placement_position.y
   love.graphics.line(corner_x, corner_y, corner_x + 40, corner_y)
   love.graphics.line(corner_x, corner_y, corner_x, corner_y + 40)

   corner_x = self.placement_position.x + PLACEMENT_WIDTH
   corner_y = self.placement_position.y
   love.graphics.line(corner_x, corner_y, corner_x - 40, corner_y)
   love.graphics.line(corner_x, corner_y, corner_x, corner_y + 40)

   corner_x = self.placement_position.x
   corner_y = self.placement_position.y + PLACEMENT_HEIGHT
   love.graphics.line(corner_x, corner_y, corner_x + 40, corner_y)
   love.graphics.line(corner_x, corner_y, corner_x, corner_y - 40)

   corner_x = self.placement_position.x + PLACEMENT_WIDTH
   corner_y = self.placement_position.y + PLACEMENT_HEIGHT
   love.graphics.line(corner_x, corner_y, corner_x - 40, corner_y)
   love.graphics.line(corner_x, corner_y, corner_x, corner_y - 40)
end

function GameScene:drawPlacementInstructions()
   local left_anchor = 1200
   love.graphics.setColor(255,255,255, 1)
   love.graphics.setFont(self.unit_card_font)

   if gamepadConnected() then
      love.graphics.draw(self.img_button_left_stick, left_anchor, 880)
      love.graphics.draw(self.img_button_dpad, left_anchor + 70, 880)
   else
      love.graphics.draw(self.img_key_arrows, left_anchor + 70, 880)
   end
   love.graphics.print("Mover", left_anchor + 140, 890)
end

function GameScene:drawUnitButtons()
   love.graphics.setColor(0.4, 0.4, 0.4, 1)
   love.graphics.circle("fill", 1600, 800, 40)
   love.graphics.circle("fill", 1500, 900, 40)
   love.graphics.circle("fill", 1700, 900, 40)
   love.graphics.circle("fill", 1600, 1000, 40)

   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.draw(self.img_tank_icon, 1573, 770, 0, 0.4)
   love.graphics.draw(self.img_medic_icon, 1483, 875, 0, 0.4)
   love.graphics.draw(self.img_gunner_icon, 1685, 875, 0, 0.4)
   love.graphics.draw(self.img_melee_icon, 1585, 975, 0, 0.4)

   if self:allowNewTank() then
      if gamepadConnected() then
         love.graphics.draw(self.img_button_y, 1578, 825)
      else
         love.graphics.draw(self.img_key_s, 1578, 825)
      end
   end

   if self:allowNewMedic() then
      if gamepadConnected() then
         love.graphics.draw(self.img_button_x, 1478, 925)
      else
         love.graphics.draw(self.img_key_a, 1478, 925)
      end
   end

   if self:allowNewGunner() then
      if gamepadConnected() then
         love.graphics.draw(self.img_button_b, 1678, 925)
      else
         love.graphics.draw(self.img_key_x, 1678, 925)
      end
   end

   if self:allowNewMelee() then
      if gamepadConnected() then
         love.graphics.draw(self.img_button_a, 1578, 1025)
      else
         love.graphics.draw(self.img_key_z, 1578, 1025)
      end
   end
end

function GameScene:drawUnitCards()
   local left_anchor = 60
   local card_width = 200
   local card_height = 200
   local horizontal_spacing = 40

   -- Cards
   love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
   love.graphics.rectangle("fill", left_anchor, 850, card_width, card_height)
   love.graphics.rectangle("fill", left_anchor + 240, 850, card_width, card_height)
   love.graphics.rectangle("fill", left_anchor + 480, 850, card_width, card_height)
   love.graphics.rectangle("fill", left_anchor + 720, 850, card_width, card_height)

   -- Nomes
   love.graphics.setFont(self.unit_card_font)
   love.graphics.setColor(1, 1, 1)
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
   love.graphics.setColor(1, 0.5, 0)
   local percentage = 1 - (self.melee_cooldown/COOLDOWN_MELEE)
   love.graphics.rectangle("fill", 75, 1020, 170 * percentage , 20)

   love.graphics.setColor(0, 0, 0)
   love.graphics.rectangle("fill", 315, 1020, 170, 20)
   love.graphics.setColor(1, 0.5, 0)
   percentage = 1 - (self.gunner_cooldown/COOLDOWN_GUNNER)
   love.graphics.rectangle("fill", 315, 1020, 170 * percentage , 20)

   love.graphics.setColor(0, 0, 0)
   love.graphics.rectangle("fill", 555, 1020, 170, 20)
   love.graphics.setColor(1, 0.5, 0)
   percentage = 1 - (self.medic_cooldown/COOLDOWN_MEDIC)
   love.graphics.rectangle("fill", 555, 1020, 170 * percentage , 20)

   love.graphics.setColor(0, 0, 0)
   love.graphics.rectangle("fill", 795, 1020, 170, 20)
   love.graphics.setColor(1, 0.5, 0)
   percentage = 1 - (self.tank_cooldown/COOLDOWN_TANK)
   love.graphics.rectangle("fill", 795, 1020, 170 * percentage , 20)
end

return GameScene
