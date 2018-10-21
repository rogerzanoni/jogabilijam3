local Character = require 'character'
local Melee = require 'melee'
local EventManager = require 'eventmanager'
local Tank = require "tank"
local Gunner = require 'gunner'
local Medic = require 'medic'
local Projectile = require 'projectile'

local STATE_IDLE = "idle"
-- TODO: plan other states (gameover, victory, pause?)

-- cooldown constants
local COOLDOWN_MELEE = 3
local COOLDOWN_GUNNER = 10
local COOLDOWN_MEDIC = 15
local COOLDOWN_TANK = 35

-- UI constants
local PLACEMENT_WIDTH = CONF_SCREEN_WIDTH / 16
local PLACEMENT_HEIGHT = CONF_SCREEN_HEIGHT / 9
local PLACEMENT_ROWS = 4
local PLACEMENT_MOVE_INTERVAL = 0.1

-- Power bar
local BAR_WIDTH = 500
local BAR_HEIGHT = 80
local BAR_X = CONF_SCREEN_WIDTH / 2 - BAR_WIDTH / 2
local BAR_Y = 50

-- Unit constants
UNIT_TYPE_MELEE = 'melee'
UNIT_TYPE_GUNNER = 'gunner'
UNIT_TYPE_MEDIC = 'medic'
UNIT_TYPE_TANK = 'tank'

local COUNTDOWN_TIMER = 600.0

GameScene = Scene:extend()

gameworld_officers = {}
gameworld_demonstrators = {}
gameworld_projectiles = {}

gameworld_player_deaths = 0
gameworld_enemy_deaths = 0

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
   self.img_button_move = love.graphics.newImage('assets/images/xb_move.png')

   self.img_key_1 = love.graphics.newImage('assets/images/key_1.png')
   self.img_key_2 = love.graphics.newImage('assets/images/key_2.png')
   self.img_key_3 = love.graphics.newImage('assets/images/key_3.png')
   self.img_key_4 = love.graphics.newImage('assets/images/key_4.png')
   self.img_key_move = love.graphics.newImage('assets/images/key_move.png')

   self.img_tank_icon = love.graphics.newImage('assets/images/tank-icon.png')
   self.img_medic_icon = love.graphics.newImage('assets/images/medic-icon.png')
   self.img_gunner_icon = love.graphics.newImage('assets/images/gunner-icon.png')
   self.img_melee_icon = love.graphics.newImage('assets/images/melee-icon.png')

   self.background = love.graphics.newImage('assets/images/street.png')

   -- Cooldowns
   self.melee_cooldown = COOLDOWN_MELEE
   self.gunner_cooldown = COOLDOWN_GUNNER
   self.medic_cooldown = COOLDOWN_MEDIC
   self.tank_cooldown = COOLDOWN_TANK
   self.eventManager = EventManager(assets.scripts.events.gamescene)
end

function GameScene:init()
   gameworld_player_deaths = 0
   gameworld_enemy_deaths = 0

   soundManager:stopAll()
   soundManager:playLoop("battle")
   self.eventManager:init()
   self.clockFont = assets.fonts.hemi_head_bd_it(assets.config.fonts.creditsTitleSize)
   self.textColor = {1, 1, 1, 1}
end

function GameScene:update(dt)
    COUNTDOWN_TIMER = COUNTDOWN_TIMER - dt

    if COUNTDOWN_TIMER <= 0 then
        -- TODO end scene
    end

    self.eventManager:update(dt)

   -- remove gone officers
   for i=#gameworld_officers,1,-1 do
      if gameworld_officers[i]:isGone() then
         table.remove(gameworld_officers, i)
      end
   end

   -- remove gone demonstrators
   for i=#gameworld_demonstrators,1,-1 do
      if gameworld_demonstrators[i]:isGone() then
         table.remove(gameworld_demonstrators, i)
      end
   end

   -- remove landed projectiles
   for i=#gameworld_projectiles,1,-1 do
      if gameworld_projectiles[i]:hasLanded() then
         table.remove(gameworld_projectiles, i)
      end
   end

   for i, character in ipairs(gameworld_officers) do
      character:update(dt)
   end

   for i, character in ipairs(gameworld_demonstrators) do
      character:update(dt)
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

   self:drawBackground()
   self:drawUnits()
   self:drawProjectiles()

   self:drawPlacementCursor()

   self:drawPlacementInstructions()

   if gamepadConnected() then
      self:drawUnitButtons()
   else
      self:drawUnitButtonsKB()
   end

   self:drawPowerBar()
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
   if self.prevent_axis_movement then
       return
   end

   if axis == 'lefty' then
      self.down_pressed = value > 0.9
      self.up_pressed = value < -0.9
   elseif axis == 'leftx' then
      self.right_pressed = value > 0.9
      self.left_pressed = value < -0.9
   end
end

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
   self.prevent_axis_movement = self.up_pressed or self.down_pressed or self.left_pressed or self.right_pressed
end

function GameScene:gamepadreleased(joystick, button)
   if button == "dpup" then
      self.up_pressed = false
      self.prevent_axis_movement = false
   elseif button == "dpdown" then
      self.down_pressed = false
      self.prevent_axis_movement = false
   elseif button == "dpright" then
      self.right_pressed = false
      self.prevent_axis_movement = false
   elseif button == "dpleft" then
      self.left_pressed = false
      self.prevent_axis_movement = false
   end
end

function GameScene:changeState(state)
   self.state = state
end

function GameScene:placeUnit(unit_type)
   local x = self.placement_position.x + (PLACEMENT_WIDTH/2)
   local y = self.placement_position.y + (PLACEMENT_HEIGHT/2)

   if unit_type == UNIT_TYPE_MELEE then
      table.insert(gameworld_demonstrators, Melee(x, y, 250, 30, Character.LOYALTY_USER));
      self.melee_cooldown = COOLDOWN_MELEE
   elseif unit_type == UNIT_TYPE_GUNNER then
      table.insert(gameworld_demonstrators, Gunner(x, y, 200, 60, Character.LOYALTY_USER));
      self.gunner_cooldown = COOLDOWN_GUNNER
   elseif unit_type == UNIT_TYPE_MEDIC then
      table.insert(gameworld_demonstrators, Medic(x, y, 200, -20, Character.LOYALTY_USER));
      self.medic_cooldown = COOLDOWN_MEDIC
   elseif unit_type == UNIT_TYPE_TANK then
      table.insert(gameworld_demonstrators, Tank(x, y, 1000, 150, Character.LOYALTY_USER));
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
   new_pos.x = math.Clamp(new_pos.x,
                          CONF_SCREEN_WIDTH - (PLACEMENT_ROWS * PLACEMENT_WIDTH),
                          CONF_SCREEN_WIDTH - PLACEMENT_WIDTH)
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
function GameScene:drawBackground()
   local bgScaleX = CONF_SCREEN_WIDTH / self.background:getWidth()
   local bgScaleY = CONF_SCREEN_HEIGHT / self.background:getHeight()
   love.graphics.setColor({1,1,1,1})
   love.graphics.draw(self.background, 0, 0, 0, bgScaleX, bgScaleY)
end

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

function GameScene:drawPowerBar()
    local total_deaths = gameworld_player_deaths + gameworld_enemy_deaths
    local enemy_ratio = gameworld_player_deaths / total_deaths
    local enemy_pixels = BAR_WIDTH * enemy_ratio

    love.graphics.rectangle("fill", BAR_X, BAR_Y, BAR_WIDTH, BAR_HEIGHT)

    love.graphics.setColor(0, 0, 255)
    love.graphics.rectangle("fill", BAR_X, BAR_Y, enemy_pixels, BAR_HEIGHT)

    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle("fill", BAR_X + enemy_pixels, BAR_Y, BAR_WIDTH - enemy_pixels, BAR_HEIGHT)

    love.graphics.setColor(self.textColor)
    love.graphics.setFont(self.clockFont)
    love.graphics.print(seconds_to_clock(math.floor(COUNTDOWN_TIMER)), BAR_X + BAR_WIDTH + 20, BAR_Y)
end

function GameScene:drawPlacementInstructions()
   local left_anchor = 1200
   love.graphics.setColor(255,255,255, 1)
   love.graphics.setFont(self.unit_card_font)

   if gamepadConnected() then
      love.graphics.draw(self.img_button_move, 1200, 880)
   else
      love.graphics.draw(self.img_key_move, 900, 950)
   end
end

function GameScene:drawUnitButtons()
   local back_color = { 1, 1, 1, 1 }
   local outline_color = { 0.2, 0.2, 0.2, 1 }

   local percentage = 1 - (self.tank_cooldown/COOLDOWN_TANK)
   love.graphics.setColor(outline_color)
   love.graphics.circle("fill", 1610, 780, 60)
   love.graphics.setColor(back_color)
   love.graphics.circle("fill", 1610, 780, 60 * percentage)

   local percentage = 1 - (self.medic_cooldown/COOLDOWN_MEDIC)
   love.graphics.setColor(outline_color)
   love.graphics.circle("fill", 1510, 880, 60)
   love.graphics.setColor(back_color)
   love.graphics.circle("fill", 1510, 880, 60 * percentage)

   local percentage = 1 - (self.gunner_cooldown/COOLDOWN_GUNNER)
   love.graphics.setColor(outline_color)
   love.graphics.circle("fill", 1710, 880, 60)
   love.graphics.setColor(back_color)
   love.graphics.circle("fill", 1710, 880, 60 * percentage)

   local percentage = 1 - (self.melee_cooldown/COOLDOWN_MELEE)
   love.graphics.setColor(outline_color)
   love.graphics.circle("fill", 1610, 980, 60)
   love.graphics.setColor(back_color)
   love.graphics.circle("fill", 1610, 980, 60 * percentage)

   love.graphics.setColor(1,1,1,1)
   love.graphics.draw(self.img_tank_icon, 1548, 718)
   love.graphics.draw(self.img_medic_icon, 1448, 818)
   love.graphics.draw(self.img_gunner_icon, 1648, 818)
   love.graphics.draw(self.img_melee_icon, 1548, 918)

   if self:allowNewTank() then
      love.graphics.draw(self.img_button_y, 1590, 825)
   end

   if self:allowNewMedic() then
      love.graphics.draw(self.img_button_x, 1490, 925)
   end

   if self:allowNewGunner() then
      love.graphics.draw(self.img_button_b, 1695, 925)
   end

   if self:allowNewMelee() then
      love.graphics.draw(self.img_button_a, 1590, 1025)
   end
end

function GameScene:drawUnitButtonsKB()
   local back_color = { 1, 1, 1, 1 }
   local outline_color = { 0.2, 0.2, 0.2, 1 }

   local percentage = 1 - (self.melee_cooldown/COOLDOWN_MELEE)
   love.graphics.setColor(outline_color)
   love.graphics.circle("fill", 1110, 980, 60)
   love.graphics.setColor(back_color)
   love.graphics.circle("fill", 1110, 980, 60 * percentage)

   local percentage = 1 - (self.gunner_cooldown/COOLDOWN_GUNNER)
   love.graphics.setColor(outline_color)
   love.graphics.circle("fill", 1260, 980, 60)
   love.graphics.setColor(back_color)
   love.graphics.circle("fill", 1260, 980, 60 * percentage)

   local percentage = 1 - (self.medic_cooldown/COOLDOWN_MEDIC)
   love.graphics.setColor(outline_color)
   love.graphics.circle("fill", 1410, 980, 60)
   love.graphics.setColor(back_color)
   love.graphics.circle("fill", 1410, 980, 60 * percentage)

   local percentage = 1 - (self.tank_cooldown/COOLDOWN_TANK)
   love.graphics.setColor(outline_color)
   love.graphics.circle("fill", 1560, 980, 60)
   love.graphics.setColor(back_color)
   love.graphics.circle("fill", 1560, 980, 60 * percentage)

   love.graphics.setColor(1,1,1,1)
   love.graphics.draw(self.img_melee_icon, 1048, 918)
   love.graphics.draw(self.img_gunner_icon, 1198, 918)
   love.graphics.draw(self.img_medic_icon, 1348, 918)
   love.graphics.draw(self.img_tank_icon, 1498, 918)

   if self:allowNewMelee() then
      love.graphics.draw(self.img_key_1, 1092, 1025)
   end

   if self:allowNewGunner() then
      love.graphics.draw(self.img_key_2, 1242, 1025)
   end

   if self:allowNewMedic() then
      love.graphics.draw(self.img_key_3, 1392, 1025)
   end

   if self:allowNewTank() then
      love.graphics.draw(self.img_key_4, 1542, 1025)
   end
end

return GameScene
