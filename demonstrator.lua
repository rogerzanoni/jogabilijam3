local Character = require 'character'
local steer = require 'steer'

Demonstrator = Character:extend()

local STATE_IDLE = "idle"
local STATE_MOVING = "moving"
local STATE_RUNNING = "running"
local STATE_DEAD = "dead"

local STATE_IDLE_FRAMES = 5
local STATE_MOVING_FRAMES = 20
local STATE_RUNNING_FRAMES = 30

local WANDER_DISTANCE = 40
local WANDER_RADIUS = 10
local WANDER_MIN_PROXIMITY = 5

function Demonstrator:new(x, y, life, damage, loyalty)
   Demonstrator.super.new(self, x, y, life, damage, loyalty)
   self.state = STATE_IDLE
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
   self.sprite.flipX = self.loyalty == self.LOYALTY_USER

   self.sprite:addAnimation(STATE_IDLE,
       { image = love.graphics.newImage 'assets/images/demonstrator-spritesheet.png',
         frameWidth=115, frameHeight=115, stopAtEnd=false, frames={ {1, 1, 4, 1, .2} } })

   self.sprite:addAnimation(STATE_MOVING,
       { image = love.graphics.newImage 'assets/images/demonstrator-spritesheet.png',
         frameWidth=115, frameHeight=115, stopAtEnd=false, frames={ {1, 3, 4, 3, .2} } })

   self.sprite:addAnimation(STATE_RUNNING,
       { image = love.graphics.newImage 'assets/images/demonstrator-spritesheet.png',
         frameWidth=115, frameHeight=115, stopAtEnd=false, frames={ {1, 3, 4, 3, .2} } })

   self.sprite:addAnimation(STATE_DEAD,
       { image = love.graphics.newImage 'assets/images/demonstrator-spritesheet.png',
         frameWidth=115, frameHeight=115, stopAtEnd=true, frames={ {1, 2, 4, 2, .2} } })
end

function Demonstrator:update(dt)
   Demonstrator.super.update(self, dt)
   if self.state == STATE_IDLE then
      self:think()
   elseif self.state == STATE_MOVING then
      self:move()
   elseif self.state == STATE_RUNNING then
      self:running()
   end

   self:clamp()
end

function Demonstrator:receiveDamage(damage)
   self.life = math.max(0, self.life - damage)
   if self:isDead() then
      self:changeState(STATE_DEAD)
   end
end

function Demonstrator:think()
   self:look_for_menace()
   if self.menace == nil then
      if self.idle_timer >= STATE_IDLE_FRAMES then
         self.target_position = steer.wander(self.position, self.velocity, WANDER_DISTANCE, WANDER_RADIUS)
         self:changeState(STATE_MOVING)
      else
         self.idle_timer = self.idle_timer + 1
      end
   else
      self:changeState(STATE_RUNNING)
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

         local polar = self.velocity:toPolar()
         if (polar.x ~= nil) then
            self.sprite.flipX = math.sin(polar.x) >= 0
         end
      else
         self:changeState(STATE_IDLE)
         self.target_position = nil
      end
   else
      self:changeState(STATE_RUNNING)
      local polar = self.velocity:toPolar()
      if (polar.x ~= nil) then
         self.sprite.flipX = math.sin(polar.x) >= 0
      end
      self.target_position = nil
   end
end

function Demonstrator:running()
   if self.running_timer >= STATE_RUNNING_FRAMES then
      self.running_timer = 0

      self:changeState(STATE_IDLE)
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
   for i, officer in ipairs(self:getEnemiesList()) do
      local distance = self.position:dist(officer.position)
      if distance < closer then
         closer = distance
         self.menace = officer
      end
   end
end


return Demonstrator
