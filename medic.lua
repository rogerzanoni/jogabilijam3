local Character = require 'character'
local steer = require 'steer'

Medic = Character:extend()

-- States
local STATE_IDLE = 'idle'
local STATE_MOVING = 'moving'
local STATE_HEALING = 'loading'
local STATE_DEAD = 'dead'

local HEALING_FRAMES = 60

function Medic:new(x, y, life, damage, loyalty)
   Medic.super.new(self, x, y, life, damage, loyalty)
   self.state = STATE_IDLE
   self.patient = nil

   -- Motion
   self.velocity = vector(0, 0)
   self.max_velocity = 2.5

   -- Distances
   self.sight_distance = 1000
   self.healing_distance = 20

   -- Timers
   self.healing_timer = 0

   -- sprite
   self.sprite = sodapop.newAnimatedSprite(x, y)
   self.sprite.flipX = self.loyalty == self.LOYALTY_USER

   local spritesheet = "assets/images/enemy_medic.png"

   if self.loyalty==self.LOYALTY_USER then
      spritesheet = "assets/images/player_medic.png"
   end

   self.sprite:addAnimation(STATE_IDLE,
       { image = love.graphics.newImage(spritesheet),
         frameWidth=120, frameHeight=120, stopAtEnd=false, frames={ {1, 1, 4, 1, .2} } })

   self.sprite:addAnimation(STATE_MOVING,
       { image = love.graphics.newImage(spritesheet),
         frameWidth=120, frameHeight=120, stopAtEnd=false, frames={ {1, 4, 4, 4, .2} } })

   self.sprite:addAnimation(STATE_HEALING,
       { image = love.graphics.newImage(spritesheet),
         frameWidth=120, frameHeight=120, stopAtEnd=false, frames={ {1, 3, 4, 3, .2} } })

   self.sprite:addAnimation(STATE_DEAD,
       { image = love.graphics.newImage(spritesheet),
         frameWidth=120, frameHeight=120, stopAtEnd=true, frames={ {1, 2, 4, 2, .2} } })
end

function Medic:update(dt)
   Medic.super.update(self, dt)

   if self:isDead() then
       return
   end

   if self.state == STATE_IDLE then
      self:look()
   elseif self.state == STATE_MOVING then
      self:move()
   elseif self.state == STATE_HEALING then
      self:heal()
   elseif self.state == STATE_DEAD then
      self.dead_for = self.dead_for + dt
   end

   self:clamp()
end

function Medic:receiveDamage(damage)
   self.life = math.max(0, self.life - damage)
   if self:isDead() then
      self:changeState(STATE_DEAD)
   end
end

function Medic:look()
   self:seek_patient()
   if not (self.patient == nil) then
      self:changeState(STATE_MOVING)
      self.sprite.flipX = self.patient.position.x < self.position.x
   end
end

function Medic:move()
   if not (self.patient==nil) then
      local distance = self.position:dist(self.patient.position)
      if distance > self.healing_distance then
         local desired_velocity = steer.seek(self.position, self.patient.position) * self.max_velocity
         local steering = desired_velocity - self.velocity
         self.velocity = self.velocity + steering
         self.position = self.position + self.velocity
      else
         self:changeState(STATE_HEALING)
      end
   end
end

function Medic:heal()
   if self.healing_timer >= HEALING_FRAMES then
      self.healing_timer = 0
      self.patient:receiveDamage(self.damage)
      self:changeState(STATE_IDLE)
   else
      self.healing_timer = self.healing_timer + 1
   end
end

function Medic:seek_patient()
   self.patient = nil
   local closer = self.sight_distance
   for i, char in ipairs(self:getFriendsList()) do
      local distance = self.position:dist(char.position)
      if not(char==self) and distance < closer and not char:isDead() and char:isHurt() and char:isHealable() then
         closer = distance
         self.patient = char
         print("Patient found: " .. distance)
      end
   end
end

return Medic
