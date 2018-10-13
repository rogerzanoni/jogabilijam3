local Object = require 'libs/classic/classic'

GameScene = Object:extend()

function GameScene:new()
    self.mouseX = 0
    self.mouseY = 0
    self.mousePressed = false
    self.circleRadius = 10
end

function GameScene:init()
end

function GameScene:update(dt)
end

function GameScene:draw()
   love.graphics.print("GAME SCENE", 200, 200)

   love.graphics.setColor(255, 255, 255)
   love.graphics.circle(self.mousePressed and 'fill' or 'line',
    self.mouseX, self.mouseY, self.circleRadius, 25)
end

function GameScene:keyPressed(key, code, isRepeat)
end

function GameScene:mousepressed(x, y, button, istouch, presses)
    -- print("Mouse pressed", x, y, button, istouch, presses)
    if button == 1 then
        self.mousePressed = true
    end
end

function GameScene:mousereleased(x, y, button, istouch, presses)
    -- print("Mouse released", x, y, button, istouch, presses)
    if button == 1 then
        self.mousePressed = false
    end
end

function GameScene:mousemoved(x, y, dx, dy, istouch)
    -- print("Mouse moved", x, y, dx, dy, istouch)
    self.mouseX = x
    self.mouseY = y
end

function GameScene:wheelmoved(dx, dy)
    -- print("Mouse wheel moved", x, y)
    self.circleRadius = self.circleRadius + dy
    if self.circleRadius < 5 then
        self.circleRadius = 5
    elseif self.circleRadius > 50 then
        self.circleRadius = 50
    end
end

return GameScene
