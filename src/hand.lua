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

function hand:rerollDice()
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

function hand:getRerollDice()
    return self.reroll
end

function hand:getHeldDice()
    return self.hold
end

function hand:moveToReroll(index)
    if index >= 1 and index <= #self.hold then
        local die = table.remove(self.hold, index)
        table.insert(self.reroll, die)
    end
end

function hand:moveToHold(index)
    if index >= 1 and index <= #self.reroll then
        local die = table.remove(self.reroll, index)
        table.insert(self.hold, die)
    end
end

return hand