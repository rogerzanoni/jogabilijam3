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

return GameScene
