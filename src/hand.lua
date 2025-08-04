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

function hand:reroll()
    for _, die in ipairs(self.reroll) do
        die:roll()
    end
end

function hand:getAllDice()
    local allDice = {}

    for _, die in ipairs(self.hold) do
        table.insert(allDice, die)
    end

    for _, die in ipairs(self.reroll) do
        table.insert(allDice, die)
    end

    return allDice
end

function hand:sumAllDice()
    local allDice = self:getAllDice()
    local total = 0 

    for _, die in ipairs(allDice) do
        total = total + die:getValue()
    end
    return total
end

return hand