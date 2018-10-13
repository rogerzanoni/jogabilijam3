local Object = require 'libs/classic/classic'

GameScene = Object:extend()

function GameScene:new()
end

function GameScene:init()
end

function GameScene:update(dt)
end

function GameScene:draw()
   love.graphics.print("GAME SCENE", 200, 200)
end

function GameScene:keyPressed(key, code, isRepeat)
end

function GameScene:mousepressed(x, y, button, istouch, presses)
    print("Mouse pressed", x, y, button, istouch, presses)
end

function GameScene:mousereleased(x, y, button, istouch, presses)
    print("Mouse released", x, y, button, istouch, presses)
end

function GameScene:mousemoved(x, y, dx, dy, istouch)
    print("Mouse moved", x, y, dx, dy, istouch)
end

function GameScene:wheelmoved(dx, dy)
    print("Mouse wheel moved", x, y)
end

return GameScene
