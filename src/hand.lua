local dice = require("dice")
local hand = {}
hand.__index = hand

-- Constructor
function hand.new()
    local self = setmetatable({}, hand)
    self.hold = {}
    self.reroll = {}

    for i = 1, 5 do
        local d = dice.new()
        table.insert(self.reroll, d)
    end
    
    return self
end