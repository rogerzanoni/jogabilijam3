local Object = require 'libs/classic/classic'

Character = Object:extend()

function Character:new(x, y)
   self.position = vector(x, y)
end

function Character:update(dt)
end

return Character
