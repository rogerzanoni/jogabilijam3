local Timer = require 'libs/knife/knife/timer'

PrologueScene = Scene:extend()

local title_font = nil
local scaleFactor = nil

function PrologueScene:new()
end

function PrologueScene:init()
   -- Fonts
   title_font = assets.fonts.hemi_head_bd_it(36 * settings:screenScaleFactor())

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
   love.graphics.print("A HIDEO KOJIMA GAME", 400, 500)
end

function PrologueScene:not_hideo()
   love.graphics.setFont(title_font)
   love.graphics.setColor(255, 255, 255)
   love.graphics.print("NOT", 350, 500)
   love.graphics.print("A HIDEO KOJIMA GAME", 400, 500)
end

function PrologueScene:place()
   love.graphics.setFont(title_font)
   love.graphics.setColor(255, 255, 255)
   love.graphics.print("SÃO PAULO, BRASIL DO SUL", 250, 200)
end

function PrologueScene:place_and_time()
   love.graphics.setFont(title_font)
   love.graphics.setColor(255, 255, 255)
   love.graphics.print("SÃO PAULO, BRASIL DO SUL", 250, 200)
   love.graphics.setColor(255, 0, 0)
   love.graphics.print("1 DE MAIO, 2077", 320, 225)
end

function PrologueScene:endScene()
   sceneManager:setCurrent('game')
end

return PrologueScene
