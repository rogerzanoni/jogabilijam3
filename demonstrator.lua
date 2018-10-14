local Character = require 'character'

Demonstrator = Character:extend()

local IDLE, MOVING, LOADING, RUNNING = 0, 1, 2, 3
local LOAD_FRAMES = 100
local RUNNING_FRAMES = 30

function Demonstrator:new(x, y)
   Demonstrator.super.new(self, x, y)
   self.state = IDLE
   self.target = nil

   -- Motion
   self.velocity = vector(0, 0)
   self.max_velocity = 1.0

   -- Distances
   self.sight_distance = 40
   self.running_distance = 20

   -- Timers
   self.loading_timer = 0
   self.running_timer = 0
end

function Demonstrator:update(dt)
   if self.state == IDLE then
      self:look()
   elseif self.state == MOVING then
      self:move()
   elseif self.state == LOADING then
      self:load()
   elseif self.state == RUNNING then
      self:running()
   end
end

function Demonstrator:look()
   self:seek_target()
   if not (self.target == nil) then
      print("[state] IDLE -> MOVING")
      self.state = MOVING
   end
end

function Demonstrator:move()
   if not (self.target==nil) then
      local distance = self.position:dist(self.target.position)
      if distance > self.running_distance then
         local desired_velocity = (self.position - self.target.position):normalized() * self.max_velocity
         local steering = desired_velocity - self.velocity
         self.velocity = self.velocity + steering
         self.position = self.position + self.velocity
      else
         print("[state] MOVING -> LOADING")
         self.state = LOADING
      end
   end
end

function Demonstrator:load()
   if self.loading_timer >= LOAD_FRAMES then
      self.loading_timer = 0
      print("[state] LOADING -> RUNNING")
      self.state = RUNNING
   else
      self.loading_timer = self.loading_timer + 1
   end
end

function Demonstrator:running()
   if self.running_timer >= RUNNING_FRAMES then
      self.running_timer = 0
      -- TODO: cause damage
      print("[state] RUNNING -> IDLE")
      self.state = IDLE
   else
      self.running_timer = self.running_timer + 1
   end
end

function Demonstrator:seek_target()
   local closer = self.sight_distance
   for i, officer in ipairs(gameworld_officers) do
      local distance = self.position:dist(officer.position)
      if distance < closer then
         closer = distance
         self.target = officer
      end
   end
end


return Demonstrator
