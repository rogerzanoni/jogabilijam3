local Character = require 'character'

Officer = Character:extend()

local IDLE, MOVING, LOADING, SHOOTING = 0, 1, 2, 3

function Officer:new(x, y)
   Officer.super.new(self, x, y)
   self.state = IDLE
   self.sight_distance = 200
   self.attack_distance = 100
   self.velocity = vector(1.0, 1.0)
   self.target = nil
end

function Officer:update(dt)
   if self.state == IDLE then
      self:look()
   elseif self.state == MOVING then
      self:move()
   elseif self.state == LOADING then
      self:load()
   elseif self.state == SHOOTING then
      self:shoot()
   end
end

function Officer:look()
   self:seek_target()
   if not (self.target == nil) then
      print("[state] from IDLE to MOVING")
      self.state = MOVING
   end
end

function Officer:move()
   if not (self.target==nil) then
      local distance = self.position:dist(self.target.position)
      if distance < self.attack_distance then
         print("[state] from MOVING to LOADING")
         self.state = LOADING
      else
         local desired_velocity = (self.target.position - self.position):normalized()
         self.position = self.position + desired_velocity
         -- TODO: move towards target
         -- local desired_velocity = normalize_vector(sub_vectors(chosen_target.position, self.x, self.y))
         -- +                        * self.max_velocity;
         -- +                let steering = desired_velocity - self.velocity;
         -- +                self.velocity = self.velocity + steering;
         -- +
         -- +                self.position = sum_vectors(self.position, self.velocity);
      end
   end
end

function Officer:load()
end

function Officer:shoot()
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
