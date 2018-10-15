local Object = require 'libs/classic/classic'

Camera = require "hump.camera"
Scene = Object:extend()

function Scene:new(map)
    self.map = map
end

function Scene:init()
   self.camera = Camera(0, 0)
   if self.map ~= nil then
       self.map:resize(love.graphics.getWidth(), love.graphics.getHeight())
   end
end

function Scene:update(dt)
    if self.map ~= nil then
       self.map:update(dt)
   end
end

function Scene:draw()
   if self.map ~= nil then
       self.map:draw(0, 0, 1, 1)
   end
end

function Scene:keyPressed(key, scancode, isRepeat)
end

function Scene:mousepressed(x, y, button, istouch, presses)
end

function Scene:mousereleased(x, y, button, istouch, presses)
end

function Scene:mousemoved(x, y, dx, dy, istouch)
end

function Scene:wheelmoved(dx, dy)
end

function Scene:gamepadpressed(joystick, button)
end

function Scene:gamepadreleased(joystick, button)
end

return Scene
