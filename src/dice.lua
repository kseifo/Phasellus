local Dice = {}
Dice.__index = Dice

-- Constructor
function Dice.new()
    local self = setmetatable({}, Dice)
    self.value = math.random(1, 6)
    return self
end

-- Setters and Getters
function Dice:setValue(value)
    self.value = value
end

function Dice:getValue()
    return self.value
end

-- Roll dice function
function Dice:roll()
    self.value = math.random(1, 6) -- Roll the die to get a new random value
end

return Dice