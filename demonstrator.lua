local Character = require 'character'
local steer = require 'steer'

Demonstrator = Character:extend()

local IDLE, MOVING, RUNNING = 0, 1, 2

local IDLE_FRAMES = 5
local MOVING_FRAMES = 20
local RUNNING_FRAMES = 30

local WANDER_DISTANCE = 40
local WANDER_RADIUS = 10
local WANDER_MIN_PROXIMITY = 5

function Demonstrator:new(x, y)
   Demonstrator.super.new(self, x, y)
   self.state = IDLE
   self.menace = nil
   self.target_position = nil
   self.max_life = 100
   self.life = self.max_life
   self.box_height = 32
   self.box_width = 32

   -- Motion
   self.velocity = vector(0, 0)
   self.max_velocity = 1.0

   -- Distances
   self.sight_distance = 40
   self.running_distance = 20

   -- Timers
   self.idle_timer = 0
   self.moving_timer = 0
   self.running_timer = 0

   -- sprite
   self.sprite = sodapop.newAnimatedSprite(x, y)
   self.sprite.color = {255,0,0,255}

   self.sprite:addAnimation(IDLE,
       { image = love.graphics.newImage 'assets/images/officer-spritesheet.png',
         frameWidth=32, frameHeight=32, stopAtEnd=false, frames={ {1, 1, 7, 1, .1} } })

   self.sprite:addAnimation(MOVING,
       { image = love.graphics.newImage 'assets/images/officer-spritesheet.png',
         frameWidth=32, frameHeight=32, stopAtEnd=false, frames={ {1, 2, 7, 2, .2} } })

   self.sprite:addAnimation(RUNNING,
       { image = love.graphics.newImage 'assets/images/officer-spritesheet.png',
         frameWidth=32, frameHeight=32, stopAtEnd=false, frames={ {1, 3, 7, 3, .2} } })
end

function Demonstrator:update(dt)
   Demonstrator.super.update(self, dt)
   if self.state == IDLE then
      self:think()
   elseif self.state == MOVING then
      self:move()
   elseif self.state == RUNNING then
      self:running()
   end
end

function Demonstrator:changeState(state)
   self.sprite:switch(state)
   self.state = state
end

function Demonstrator:think()
   self:look_for_menace()
   if self.menace == nil then
      if self.idle_timer >= IDLE_FRAMES then
         self.target_position = steer.wander(self.position, self.velocity, WANDER_DISTANCE, WANDER_RADIUS)
         self:changeState(MOVING)
      else
         self.idle_timer = self.idle_timer + 1
      end
   else
      self:changeState(RUNNING)
      self.sprite.flipX = self.menace.position.x < self.position.x
   end
end

function Demonstrator:move()
   self:look_for_menace()
   if self.menace == nil then
      local distance = self.position:dist(self.target_position)

      if (distance > WANDER_MIN_PROXIMITY) then
         local desired_velocity = steer.seek(self.position, self.target_position) * self.max_velocity
         local steering = desired_velocity - self.velocity

         self.velocity = self.velocity + steering
         self.position = self.position + self.velocity
      else
         self:changeState(IDLE)
         self.target_position = nil
      end
   else
      self:changeState(RUNNING)
      self.sprite.flipX = self.menace.position.x < self.position.x
      self.target_position = nil
   end
end

function Demonstrator:running()
   if self.running_timer >= RUNNING_FRAMES then
      self.running_timer = 0

      self:changeState(IDLE)
      self.menace = nil
   else
      self.running_timer = self.running_timer + 1

      local desired_velocity = steer.flee(self.position, self.menace.position) * self.max_velocity
      local steering = desired_velocity - self.velocity

      self.velocity = self.velocity + steering
      self.position = self.position + self.velocity
   end
end

function Demonstrator:look_for_menace()
   local closer = self.sight_distance
   for i, officer in ipairs(gameworld_officers) do
      local distance = self.position:dist(officer.position)
      if distance < closer then
         closer = distance
         self.menace = officer
      end
   end
end


return Demonstrator
