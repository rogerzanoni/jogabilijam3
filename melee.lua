local Character = require 'character'
local steer = require 'steer'

Melee = Character:extend()

-- States
local STATE_IDLE = 'idle'
local STATE_MOVING = 'moving'
local STATE_LOADING = 'loading'
local STATE_ATTACKING = 'attacking'
local STATE_DEAD = 'dead'

local LOAD_FRAMES = 20
local ATTACK_FRAMES = 40

function Melee:new(x, y, life, damage, loyalty)
   Melee.super.new(self, x, y, life, damage, loyalty)
   self.state = STATE_IDLE
   self.target = nil

   -- Motion
   self.velocity = vector(0, 0)
   self.max_velocity = 1.0

   -- Distances
   self.sight_distance = 2000
   self.attack_distance = 20

   -- Timers
   self.loading_timer = 0
   self.attacking_timer = 0

   -- sprite
   self.sprite = sodapop.newAnimatedSprite(x, y)
   self.sprite.flipX = self.loyalty == self.LOYALTY_USER

   local spritesheet = "assets/images/enemy_melee.png"

   if self.loyalty==self.LOYALTY_USER then
      spritesheet = "assets/images/player_melee.png"
   end

   self.sprite:addAnimation(STATE_IDLE,
       { image = love.graphics.newImage(spritesheet),
         frameWidth=120, frameHeight=120, stopAtEnd=false, frames={ {1, 1, 4, 1, .2} } })

   self.sprite:addAnimation(STATE_MOVING,
       { image = love.graphics.newImage(spritesheet),
         frameWidth=120, frameHeight=120, stopAtEnd=false, frames={ {1, 4, 4, 4, .2} } })

   self.sprite:addAnimation(STATE_LOADING,
       { image = love.graphics.newImage(spritesheet),
         frameWidth=120, frameHeight=120, stopAtEnd=false, frames={ {1, 1, 4, 1, .2} } })

   self.sprite:addAnimation(STATE_ATTACKING,
       { image = love.graphics.newImage(spritesheet),
         frameWidth=120, frameHeight=120, stopAtEnd=false, frames={ {1, 3, 4, 3, .2} } })

   self.sprite:addAnimation(STATE_DEAD,
       { image = love.graphics.newImage(spritesheet),
         frameWidth=120, frameHeight=120, stopAtEnd=true, frames={ {1, 2, 4, 2, .2} } })
end

function Melee:update(dt)
   Melee.super.update(self, dt)

   if self.state == STATE_IDLE then
      self:look()
   elseif self.state == STATE_MOVING then
      self:move()
   elseif self.state == STATE_LOADING then
      self:load()
   elseif self.state == STATE_ATTACKING then
      self:attack()
   elseif self.state == STATE_DEAD then
      self.dead_for = self.dead_for + dt
   end
end

function Melee:receiveDamage(damage)
   self.life = math.max(0, self.life - damage)
   if self:isDead() then
      self:changeState(STATE_DEAD)
   end
end

function Melee:look()
   self:seek_target()
   if not (self.target == nil) then
      self:changeState(STATE_MOVING)
      self.sprite.flipX = self.target.position.x < self.position.x
   end
end

function Melee:move()
   self:seek_target()
   if not (self.target==nil) then
      local distance = self.position:dist(self.target.position)
      if distance > self.attack_distance then
         local desired_velocity = steer.seek(self.position, self.target.position) * self.max_velocity
         local steering = desired_velocity - self.velocity
         self.velocity = self.velocity + steering
         self.position = self.position + self.velocity
      else
         self:changeState(STATE_LOADING)
      end
   end
end

function Melee:load()
   if self.loading_timer >= LOAD_FRAMES then
      self.loading_timer = 0
      self:changeState(STATE_ATTACKING)
   else
      self.loading_timer = self.loading_timer + 1
   end
end

function Melee:attack()
   if self.attacking_timer >= ATTACK_FRAMES then
      self.attacking_timer = 0
      self.target:receiveDamage(self.damage)
      self:changeState(STATE_IDLE)
      soundManager:play("melee")
   else
      self.attacking_timer = self.attacking_timer + 1
   end
end

function Melee:seek_target()
   self.target = nil
   local closer = self.sight_distance

   local enemy_list = gameworld_demonstrators
   if self.loyalty == Character.LOYALTY_USER then
       enemy_list = gameworld_officers
   end

   for i, enemy in ipairs(enemy_list) do
      local distance = self.position:dist(enemy.position)
      if distance < closer and (not enemy:isDead()) then
         closer = distance
         self.target = enemy
         print("Target found!" .. distance)
      end
   end
end


return Melee
