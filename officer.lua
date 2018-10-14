local Character = require 'character'

Officer = Character:extend()

local IDLE, MOVING, LOADING, ATTACKING = 0, 1, 2, 3
local LOAD_FRAMES = 100
local ATTACK_FRAMES = 30

function Officer:new(x, y)
   Officer.super.new(self, x, y)
   self.state = IDLE
   self.target = nil

   -- Motion
   self.velocity = vector(0, 0)
   self.max_velocity = 1.0

   -- Distances
   self.sight_distance = 200
   self.attack_distance = 20

   -- Timers
   self.loading_timer = 0
   self.attacking_timer = 0
end

function Officer:update(dt)
   if self.state == IDLE then
      self:look()
   elseif self.state == MOVING then
      self:move()
   elseif self.state == LOADING then
      self:load()
   elseif self.state == ATTACKING then
      self:attack()
   end
end

function Officer:look()
   self:seek_target()
   if not (self.target == nil) then
      print("[state] IDLE -> MOVING")
      self.state = MOVING
   end
end

function Officer:move()
   if not (self.target==nil) then
      local distance = self.position:dist(self.target.position)
      if distance > self.attack_distance then
         local desired_velocity = (self.target.position - self.position):normalized() * self.max_velocity
         local steering = desired_velocity - self.velocity
         self.velocity = self.velocity + steering
         self.position = self.position + self.velocity
      else
         print("[state] MOVING -> LOADING")
         self.state = LOADING
      end
   end
end

function Officer:load()
   if self.loading_timer >= LOAD_FRAMES then
      self.loading_timer = 0
      print("[state] LOADING -> ATTACKING")
      self.state = ATTACKING
   else
      self.loading_timer = self.loading_timer + 1
   end
end

function Officer:attack()
   if self.attacking_timer >= ATTACK_FRAMES then
      self.attacking_timer = 0
      -- TODO: cause damage
      print("[state] ATTACKING -> IDLE")
      self.state = IDLE
   else
      self.attacking_timer = self.attacking_timer + 1
   end
end

function Officer:seek_target()
   local closer = self.sight_distance
   for i, dem in ipairs(gameworld_demonstrators) do
      local distance = self.position:dist(dem.position)
      if distance < closer then
         closer = distance
         self.target = dem
         print("Target found!" .. distance)
      end
   end
end


return Officer
