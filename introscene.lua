local Timer = require 'libs/knife/knife/timer'

IntroScene = Scene:extend()

local DEFAULT_INTERVAL = 3

function IntroScene:new()
end

function IntroScene:init()
   soundManager:stopAll()
   self.currentSlide = 0
   self.slides = {}
   table.insert(self.slides, {})
   largato_logo = love.graphics.newImage('assets/images/largato_logo_white.png')
   table.insert(self.slides, largato_logo)
   love_logo = love.graphics.newImage('assets/images/love_logo.png')
   table.insert(self.slides, love_logo)
   self:nextSlide()
end

function IntroScene:update(dt)
   Timer.update(dt)
end

function IntroScene:draw()
   if self.currentSlide > 0 then
      local logo = self.slides[self.currentSlide]
      if type(logo) == "userdata" then
         local x = (CONF_SCREEN_WIDTH / 2) - (logo:getWidth()/2)
         local y = (CONF_SCREEN_HEIGHT / 2) - (logo:getHeight()/2)
         love.graphics.draw(logo, x, y)
      end
   end
end

function IntroScene:startTimer()
   Timer.after(DEFAULT_INTERVAL, function() self:nextSlide() end)
end

function IntroScene:nextSlide()
   if self.currentSlide < #self.slides then
      self.currentSlide = self.currentSlide+1
      self:startTimer()
   else
      sceneManager:setCurrent('prologue')
   end
end

return IntroScene
