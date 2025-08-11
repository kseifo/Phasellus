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

function hand:moveToReroll(die)
    for i, heldDie in ipairs(self.hold) do
        if heldDie == die then
            table.remove(self.hold, i)
            table.insert(self.reroll, die)
            return true -- Successfully moved
        end
    end
    return false -- Die not found in hold
end

function hand:moveToHold(die)
    for i, rerollDie in ipairs(self.reroll) do
        if rerollDie == die then
            table.remove(self.reroll, i)
            table.insert(self.hold, die)
            return true -- Successfully moved
        end
    end
    return false -- Die not found in reroll
end

function hand:isDieHeld(die)
    for _, heldDie in ipairs(self.hold) do
        if heldDie == die then
            return true
        end
    end
    return false
end

function hand:isDieInReroll(die)
    for _, rerollDie in ipairs(self.reroll) do
        if rerollDie == die then
            return true
        end
    end
    return false
end

return hand