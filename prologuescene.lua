local Timer = require 'libs/knife/knife/timer'

PrologueScene = Scene:extend()

local title_font = nil

function PrologueScene:new()
end

function PrologueScene:init()
   -- Fonts
   title_font = assets.fonts.hemi_head_bd_it(36)

   self.drawFunction = nil
   self:startTimers()
end

function PrologueScene:update(dt)
   Timer.update(dt)
end

function PrologueScene:draw()
   if not (self.drawFunction == nil) then
      self:drawFunction()
   end
end

function PrologueScene:startTimers()
   Timer.after(1, function() self.drawFunction = self.hideo end)
   Timer.after(4, function() self.drawFunction = self.not_hideo end)
   Timer.after(7, function() self.drawFunction = self.place end)
   Timer.after(9, function() self.drawFunction = self.place_and_time end)
   Timer.after(12, function() self:endScene() end)
end

function PrologueScene:hideo()
   love.graphics.setFont(title_font)
   love.graphics.setColor(255, 255, 255)
   love.graphics.print("A HIDEO KOJIMA GAME", 1400, 800)
end

function PrologueScene:not_hideo()
   love.graphics.setFont(title_font)
   love.graphics.setColor(255, 255, 255)
   love.graphics.print("NOT", 1320, 800)
   love.graphics.print("A HIDEO KOJIMA GAME", 1400, 800)
end

function PrologueScene:place()
   local text = "SÃO PAULO, BRASIL DO SUL"
   local text_width = love.graphics.getFont():getWidth(text)
   love.graphics.setFont(title_font)
   love.graphics.setColor(255, 255, 255)
   love.graphics.print(text,
                       (CONF_SCREEN_WIDTH - text_width)/2,
                       CONF_SCREEN_HEIGHT/2)
end

function PrologueScene:place_and_time()
   local text = "SÃO PAULO, BRASIL DO SUL"
   local text_width = love.graphics.getFont():getWidth(text)
   love.graphics.setFont(title_font)
   love.graphics.setColor(255, 255, 255)
   love.graphics.print(text,
                       (CONF_SCREEN_WIDTH - text_width)/2,
                       CONF_SCREEN_HEIGHT/2)
   local text = "1 DE MAIO, 2077"
   local text_width = love.graphics.getFont():getWidth(text)
   love.graphics.setColor(255, 0, 0)
   love.graphics.print(text,
                       (CONF_SCREEN_WIDTH - text_width)/2,
                       (CONF_SCREEN_HEIGHT/2) + 45)
end

function PrologueScene:endScene()
   sceneManager:setCurrent('game')
end

return PrologueScene
