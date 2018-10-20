SceneManager = Object:extend()

function SceneManager:new()
   self.scenes = {}
end

function SceneManager:add(sceneName, scene)
   self.scenes[sceneName] = scene
end

function SceneManager:remove(sceneName)
   if self.scenes[sceneName] == nil then
      return
   end
end

function SceneManager:setCurrent(sceneName)
   local scene = self.scenes[sceneName]
   scene:init()
   SceneManager.current = scene
end

function SceneManager:update(dt)
   if SceneManager.current == nil then
      return
   end
   SceneManager.current:update(dt)
end

function SceneManager:draw()
   if SceneManager.current == nil then
      return
   end
   SceneManager.current:draw()
end

function SceneManager:keyPressed(key, scancode, isRepeat)
   SceneManager.current:keyPressed(key, scancode, isRepeat)
end

function SceneManager:mousepressed(x, y, button, istouch, presses)
    SceneManager.current:mousepressed(x, y, button, istouch, presses)
end

function SceneManager:mousereleased(x, y, button, istouch, presses)
    SceneManager.current:mousereleased(x, y, button, istouch, presses)
end

function SceneManager:mousemoved(x, y, dx, dy, istouch)
    SceneManager.current:mousemoved(x, y, dx, dy, istouch)
end

function SceneManager:wheelmoved(dx, dy)
    SceneManager.current:wheelmoved(dx, dy)
end

function SceneManager:gamepadpressed(joystick, button)
    SceneManager.current:gamepadpressed(joystick, button)
end

function SceneManager:gamepadreleased(joystick, button)
    SceneManager.current:gamepadreleased(joystick, button)
end

function SceneManager:gamepadaxis(joystick, axis, value)
    SceneManager.current:gamepadaxis(joystick, axis, value)
end

sceneManager = SceneManager()
