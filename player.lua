local Player = {}
Player.__index = Player

-- Turn semantics here
function Player:playTurn()
    print(self.name .. "'s turn.")
end

-- Constructor
function Player.new(name)
    local self = setmetatable({}, Player)
    self.name = name
    self.score = 0
    return self
end

return Player
