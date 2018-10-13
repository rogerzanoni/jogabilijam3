local Object = require 'libs/classic/classic'

GameWorld = Object:extend()

function GameWorld:new()
   self.officers = {}
   self.demonstrators = {}
end

return GameWorld
