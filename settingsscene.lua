SettingsScene = Scene:extend()

function SettingsScene:new()
   self.items = settings:currentSettings()
   table.insert(self.items, {"Voltar"})
   self.line = 1
end

function SettingsScene:init()
   self.buttonOnImage = love.graphics.newImage('assets/images/button_on.png')
   self.buttonOffImage = love.graphics.newImage('assets/images/button_off.png')
   self.background = love.graphics.newImage('assets/images/bg_menu.png')
end

function SettingsScene:draw()
   local oldFont = love.graphics.getFont()
   local r, g, b, a = love.graphics.getColor()

   local bgScaleX = CONF_SCREEN_WIDTH / self.background:getWidth()
   local bgScaleY = CONF_SCREEN_HEIGHT / self.background:getHeight()
   love.graphics.draw(self.background, 0, 0, 0, bgScaleX, bgScaleY)

   fontHeight = assets.config.fonts.menuItemHeight * settings:menuScaleFactor()
   menuFont = assets.fonts.hemi_head_bd_it(fontHeight)
   menuWidth = math.min(CONF_SCREEN_WIDTH * 0.4 * settings:menuScaleFactor(), CONF_SCREEN_WIDTH * 0.8)
   menuItemHeight = fontHeight * 2
   menuHeight = menuItemHeight * #self.items
   x = CONF_SCREEN_WIDTH / 2 - menuWidth / 2
   y = CONF_SCREEN_HEIGHT / 2 - menuHeight / 2
   buttonScaleX = menuWidth / self.buttonOnImage:getWidth()
   buttonScaleY = menuItemHeight / self.buttonOnImage:getHeight()

   for i, setting in pairs(self.items) do
      love.graphics.setColor(r, g, b, a)
      local button = nil
      if i == self.line then
         button = self.buttonOnImage
      else
         button = self.buttonOffImage
      end

      love.graphics.draw(button, x, y + (i - 1) * menuItemHeight, 0, buttonScaleX, buttonScaleY)

      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.setFont(menuFont)
      love.graphics.printf(settings:toString(setting), x,
                        y + (i - 1) * menuItemHeight + menuItemHeight / 2 - fontHeight / 2,
                        menuWidth, 'center')

   end

   love.graphics.setFont(oldFont)
   love.graphics.setColor(r, g, b, a)
end

function SettingsScene:keyPressed(key, scancode, isRepeat)
   if key=="up" and not isRepeat then
      self:moveUp()
   elseif key=="down" and not isRepeat then
      self:moveDown()
   elseif key=="escape" and not isRepeat then
      self:back()
   elseif key=="return" and not isRepeat then
      self:selectItem()
   elseif key=="left" and not isRepeat then
      self:previousValue()
   elseif key=="right" and not isRepeat then
      self:nextValue()
   end
end

function SettingsScene:gamepadpressed(joystick, button)
   if button == "dpup" then
      self:moveUp()
   elseif button == "dpdown" then
      self:moveDown()
   elseif button == "dpleft" then
      self:previousValue()
   elseif button == "dpright" then
      self:nextValue()
   elseif button == "a" then
      self:selectItem()
   elseif button == "b" then
      self:back()
   end
end

function SettingsScene:gamepadaxis(joystick, axis, value)
   if axis == 'lefty' then
      if value == 1 then
         self:moveDown()
      elseif value == -1 then
         self:moveUp()
      end
   elseif axis == "leftx" then
      if value == 1 then
         self:nextValue()
      elseif value == -1 then
         self:previousValue()
      end
   end
end

function SettingsScene:moveUp()
   self.line = (self.line - 2) % #self.items + 1
   soundManager:stop("menuselect")
   soundManager:play("menuselect")
end

function SettingsScene:moveDown()
   self.line = self.line % #self.items + 1
   soundManager:stop("menuselect")
   soundManager:play("menuselect")
end

function SettingsScene:back()
   sceneManager:setCurrent("menu")
end

function SettingsScene:selectItem()
   if self.items[self.line][1] == "Voltar" then -- XXX this is ugly, I know
      self:back()
   else
      self:nextValue()
   end
end

function SettingsScene:previousValue()
   settings:previousSetting(self.line)
end

function SettingsScene:nextValue()
   settings:nextSetting(self.line)
   soundManager:stop("menuselect")
   soundManager:play("menuselect")
end

return SettingsScene
