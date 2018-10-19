MenuScene = Scene:extend()

function MenuScene:new()
   self.items = {
      "Jogar",
      "Configurações",
      "Créditos",
      "Sair",
   }
   self.line = 1
end

function MenuScene:init()
   self.fontHeight = assets.config.fonts.menuItemHeight * settings:menuScaleFactor()
   self.menuFont = assets.fonts.hemi_head_bd_it(self.fontHeight)
   self.menuWidth = math.min(CONF_SCREEN_WIDTH * 0.4 * settings:menuScaleFactor(), CONF_SCREEN_WIDTH * 0.8)
   self.menuItemHeight = self.fontHeight * 2
   self.menuHeight = self.menuItemHeight * #self.items
   self.x = CONF_SCREEN_WIDTH / 2 - self.menuWidth / 2
   self.y = CONF_SCREEN_HEIGHT / 2 - self.menuHeight / 2
   self.background = love.graphics.newImage('assets/images/bg_menu.png')
   self.buttonOnImage = love.graphics.newImage('assets/images/button_on.png')
   self.buttonOffImage = love.graphics.newImage('assets/images/button_off.png')
   self.buttonScaleX = self.menuWidth / self.buttonOnImage:getWidth()
   self.buttonScaleY = self.menuItemHeight / self.buttonOnImage:getHeight()
end

function MenuScene:draw()
   local oldFont = love.graphics.getFont()
   local r, g, b, a = love.graphics.getColor()

   local bgScaleX = CONF_SCREEN_WIDTH / self.background:getWidth()
   local bgScaleY = CONF_SCREEN_HEIGHT / self.background:getHeight()
   love.graphics.draw(self.background, 0, 0, 0, bgScaleX, bgScaleY)

   for i, option in pairs(self.items) do
      love.graphics.setColor(r, g, b, a)
      local button = nil
      if i == self.line then
         button = self.buttonOnImage
      else
         button = self.buttonOffImage
      end

      love.graphics.draw(button, self.x, self.y + (i - 1) * self.menuItemHeight, 0, self.buttonScaleX, self.buttonScaleY)

      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.setFont(self.menuFont)
      love.graphics.printf(option, self.x,
                        self.y + (i - 1) * self.menuItemHeight + self.menuItemHeight / 2 - self.fontHeight / 2,
                        self.menuWidth, 'center')

   end

   love.graphics.setFont(oldFont)
   love.graphics.setColor(r, g, b, a)
end

function MenuScene:itemSelected(item)
   if item == 1 then
      sceneManager:setCurrent("intro")
   elseif item == 2 then
      sceneManager:setCurrent("settings")
   elseif item == 3 then
      sceneManager:setCurrent("credits")
   elseif item == 4 then
      love.event.quit(0)
   end
end

function MenuScene:keyPressed(key, scancode,  isRepeat)
   if key=="up" and not isRepeat then
      self:moveUp()
   elseif key=="down" and not isRepeat then
      self:moveDown()
   elseif key=="return" and not isRepeat then
      self:selectItem()
   end
end

function MenuScene:gamepadpressed(joystick, button)
   if button == "dpup" then
      self:moveUp()
   elseif button == "dpdown" then
      self:moveDown()
   elseif button == "a" then
      self:selectItem()
   end
end

function MenuScene:gamepadaxis(joystick, axis, value)
   if axis == 'lefty' then
      if value == 1 then
         self:moveDown()
      elseif value == -1 then
         self:moveUp()
      end
   end
end

function MenuScene:moveUp()
   self.line = (self.line - 2) % #self.items + 1
   soundManager:stop("menuselect")
   soundManager:play("menuselect")
end

function MenuScene:moveDown()
   self.line = self.line % #self.items + 1
   soundManager:stop("menuselect")
   soundManager:play("menuselect")
end

function MenuScene:selectItem()
   self:itemSelected(self.line)
   soundManager:play("accept")
end

return MenuScene
