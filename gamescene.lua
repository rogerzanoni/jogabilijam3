local Character = require 'character'
local Officer = require 'officer'
local Demonstrator = require 'demonstrator'
local Tank = require "tank"

GameScene = Scene:extend()

gameworld_officers = {}
gameworld_demonstrators = {}

function GameScene:new()
   table.insert(gameworld_officers, Officer(600, 200));
   table.insert(gameworld_officers, Officer(600, 250));
   table.insert(gameworld_officers, Tank(434, 350));
   table.insert(gameworld_officers, Officer(600, 300));
   table.insert(gameworld_officers, Officer(600, 350));

   table.insert(gameworld_demonstrators, Demonstrator(1300,130));
   table.insert(gameworld_demonstrators, Demonstrator(1300,230));
   table.insert(gameworld_demonstrators, Demonstrator(1300,330));
   table.insert(gameworld_demonstrators, Demonstrator(1300,430));
   table.insert(gameworld_demonstrators, Demonstrator(1300,530));
   table.insert(gameworld_demonstrators, Demonstrator(1300,630));
   table.insert(gameworld_demonstrators, Demonstrator(1300,730));
   table.insert(gameworld_demonstrators, Demonstrator(1300,830));
   table.insert(gameworld_demonstrators, Demonstrator(1300,930));

   self.mouseX = 0
   self.mouseY = 0
   self.mousePressed = false
   self.circleRadius = 10
end

function GameScene:init()
    soundManager:stopAll()
    soundManager:playLoop("battle")
end

function GameScene:update(dt)
   for i, character in ipairs(gameworld_officers) do
      character:update(dt)
   end

   for i, character in ipairs(gameworld_demonstrators) do
      character:update(dt)
   end
end

function GameScene:draw()
   love.graphics.clear(67/255, 139/255, 126/255)

   for i, char in ipairs(gameworld_officers) do
      char:draw(0, 0)
   end

   for i, char in ipairs(gameworld_demonstrators) do
      char:draw(0, 0)
   end

   -- Mouse pointer rendering
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

function GameScene:gamepadpressed(joystick, button)
    print("Gamepad pressed", button)
end

function GameScene:gamepadreleased(joystick, button)
    print("Gamepad released", button)
end

return GameScene
