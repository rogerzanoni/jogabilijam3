vector = require "libs/hump/vector"
assets = require("libs/cargo/cargo").init("assets")
sodapop = require "libs/sodapop/sodapop"

CONF_SCREEN_WIDTH = 1920
CONF_SCREEN_HEIGHT = 1080

Object = require "libs/classic/classic"
Scene = require "scene"

require "steer"
require "utils"
-- require "entitymanager"
require "scenemanager"
require "settings"
require "soundmanager"

local MenuScene = require "menuscene"
local IntroScene = require "introscene"
local PrologueScene = require "prologuescene"
-- local Map = require "libs/Simple-Tiled-Implementation/sti"
-- local Camera = require "camera"
local GameScene = require "gamescene"
-- local EndScene = require "endscene"
-- local DialogScene = require "dialogscene"
local SettingsScene = require "settingsscene"
-- local CreditsScene = require "creditsscene"

local debugMode = true

function love.load()
   math.randomseed(os.time())
   soundManager:add("battle", "assets/sounds/battle.ogg")
   soundManager:add("menu", "assets/sounds/menu.mp3")
   soundManager:add("menuselect", "assets/sounds/menuselect.wav", true)
   soundManager:add("accept", "assets/sounds/accept.mp3", true)
   soundManager:playLoop("menu")

   -- local map = Map("assets/maps/green_valley.lua")
   sceneManager:add("menu", MenuScene())
   sceneManager:add("intro", IntroScene())
   sceneManager:add("prologue", PrologueScene())
   -- sceneManager:add("prologue", DialogScene('prologue', "battle"))
   -- sceneManager:add("battle", GameScene(Camera(), map))
   sceneManager:add("game", GameScene())
   -- sceneManager:add("PlayerWon", EndScene("Jogador"))
   -- sceneManager:add("EnemyWon", EndScene("Inimigo"))
   sceneManager:add("settings", SettingsScene())
   -- sceneManager:add("credits", CreditsScene())
   sceneManager:setCurrent("menu")
end

function love.update(dt)
   if dt < 1/30 then
      love.timer.sleep(1/30 - dt)
   end
   sceneManager:update(dt)
end

function love.draw()
   love.graphics.scale(settings:screenScaleFactor())
   sceneManager:draw()
   if debugMode then
      drawDebugInfo()
   end
end

-- keyboard

function love.keypressed(key, scancode, isRepeat)
   sceneManager:keyPressed(key, scancode, isRepeat)
end

-- mouse

function love.mousepressed(x, y, button, istouch, presses)
    sceneManager:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    sceneManager:mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
    sceneManager:mousemoved(x, y, dx, dy, istouch)
end

function love.wheelmoved(dx, dy)
    sceneManager:wheelmoved(dx, dy)
end

-- gamepad

function love.gamepadpressed(joystick, button)
    sceneManager:gamepadpressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
    sceneManager:gamepadreleased(joystick, button)
end

function love.gamepadaxis(joystick, axis, value)
   sceneManager:gamepadaxis(joystick, axis, value)
end
--

function drawDebugInfo()
   love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end
