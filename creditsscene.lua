CreditsScene = Scene:extend()

function CreditsScene:new()
end

function CreditsScene:init()
   self.titleFont = assets.fonts.hemi_head_bd_it(assets.config.fonts.creditsTitleSize)
   self.subtitleFont = assets.fonts.hemi_head_bd_it(assets.config.fonts.creditsSubtitleSize)
   self.textFont = assets.fonts.hemi_head_bd_it(assets.config.fonts.creditsTextSize)
   self.keystrokeCount = 0
   self.background = love.graphics.newImage('assets/images/bg_intro.png')
   self.titleColor = {255, 255, 255, 255}
   self.subtitleColor = {255, 255, 255, 255}
   self.textColor = {0, 0, 107, 255}
end

function CreditsScene:update(dt)
end

function CreditsScene:draw()
   local first_column = 400
   local second_column = 1100
   -- background --
   local bgXScale = CONF_SCREEN_WIDTH/self.background:getWidth()
   local bgYScale = CONF_SCREEN_HEIGHT/self.background:getHeight()
   love.graphics.setColor({1,1,1,1})
   love.graphics.draw(self.background, 0, 0, 0, bgXScale, bgYScale)

   -- render static credits --
   love.graphics.setColor(unpack(self.titleColor))
   love.graphics.setFont(self.titleFont)

   local title = "CRÉDITOS"
   local titleWidth = self.titleFont:getWidth(title)
   local titleX = (CONF_SCREEN_WIDTH/2) - (titleWidth/2)
   local titleY = CONF_SCREEN_HEIGHT * 0.1
   love.graphics.print(title, titleX, titleY)

   -- Programação
   love.graphics.setColor(self.subtitleColor)
   love.graphics.setFont(self.subtitleFont)
   love.graphics.print("PROGRAMAÇÃO", first_column, 300)

   love.graphics.setColor(self.textColor)
   love.graphics.setFont(self.textFont)
   love.graphics.print("EMILIANO FIRMINO", first_column, 350)
   love.graphics.print("FELIPE FONSECA", first_column, 390)
   love.graphics.print("LUIZ CAVALCANTI", first_column, 430)
   love.graphics.print("ROGER ZANONI", first_column, 470)

   -- Arte & UI Design
   love.graphics.setColor(self.subtitleColor)
   love.graphics.setFont(self.subtitleFont)
   love.graphics.print("ARTE & DESIGN DE INTERFACE", first_column, 600)

   love.graphics.setColor(self.textColor)
   love.graphics.setFont(self.textFont)
   love.graphics.print("FABIANO MARINHO", first_column, 650)

   -- Musica
   love.graphics.setColor(self.subtitleColor)
   love.graphics.setFont(self.subtitleFont)
   love.graphics.print("MÚSICA & EFEITOS", first_column, 800)

   love.graphics.setColor(self.textColor)
   love.graphics.setFont(self.textFont)
   love.graphics.print("OPENGAMEART.ORG", first_column, 850)

   -- Game design
   love.graphics.setColor(self.subtitleColor)
   love.graphics.setFont(self.subtitleFont)
   love.graphics.print("GAME DESIGN", second_column, 300)

   love.graphics.setColor(self.textColor)
   love.graphics.setFont(self.textFont)
   love.graphics.print("EMILIANO FIRMINO", second_column, 350)
   love.graphics.print("FABIANO MARINHO", second_column, 390)
   love.graphics.print("FELIPE FONSECA", second_column, 430)
   love.graphics.print("LUIZ CAVALCANTI", second_column, 470)
   love.graphics.print("ROGER ZANONI", second_column, 510)

   -- Roteiro
   love.graphics.setColor(self.subtitleColor)
   love.graphics.setFont(self.subtitleFont)
   love.graphics.print("ROTEIRO", second_column, 700)

   love.graphics.setColor(self.textColor)
   love.graphics.setFont(self.textFont)
   love.graphics.print("FABIANO MARINHO", second_column, 750)
   love.graphics.print("LUIZ CAVALCANTI", second_column, 790)
end

function CreditsScene:keyPressed(key, code, isRepeat)
   if not isRepeat then
      self.keystrokeCount = self.keystrokeCount + 1
   end
   if (self.keystrokeCount == 2) then
      sceneManager:setCurrent("menu")
   end
end

function Scene:gamepadpressed(joystick, button)
   sceneManager:setCurrent("menu")
end

return CreditsScene
