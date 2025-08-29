local DiceHandler = {}
DiceHandler.__index = DiceHandler
local lg = love.graphics


function DiceHandler.new(hand)
    local self = setmetatable({
        hand = hand,
        coordinates = {},
        dieW = 50, dieH = 50,
        heldY = 40, rerollY = 130,
        startX = 50, stepX = 70,
        diceImages = {},
    }, DiceHandler)

    local allDice = hand:getAllDice()
    for i, die in ipairs(allDice) do
        self.coordinates[die] = { self.startX + (i - 1) * self.stepX, self.rerollY }
    end

    for i = 1, 6 do
        self.diceImages[i] = lg.newImage("assets/die" .. i .. ".png")
    end

    return self
end

function DiceHandler:getDiceImage(value)
    return self.diceImages[value]
end

function DiceHandler:getCoordinates()
    return self.coordinates
end

function DiceHandler:setPos(die, x, y)
    if self.coordinates[die] then
        self.coordinates[die][1] = x
        self.coordinates[die][2] = y
    end
end

function DiceHandler:fixHeldPositions()
    local held = self.hand:getHeldDice()
    for i, die in ipairs(held) do
        self:setPos(die, self.startX + (i - 1) * self.stepX, self.heldY)
    end
end

function DiceHandler:fixRerollPositions()
    local reroll = self.hand:getRerollDice()
    for i, die in ipairs(reroll) do
        self:setPos(die, self.startX + (i - 1) * self.stepX, self.rerollY)
    end
end

function DiceHandler:moveDie(die)
    if not die or not self.hand then return end
    if self.hand:isDieHeld(die) then
        self.hand:moveToReroll(die)
    else
        self.hand:moveToHold(die)
    end
    self:fixHeldPositions()
    self:fixRerollPositions()
end

function DiceHandler:dieAt(x, y)
    for die, pos in pairs(self.coordinates) do
        local dx, dy = pos[1], pos[2]
        if x > dx and x < dx + self.dieW and y > dy and y < dy + self.dieH then
            return die
        end
    end
    return nil
end

function DiceHandler:onClick(x, y)
    local die = self:dieAt(x, y)
    if die then
        self:moveDie(die)
        return true
    end
    return false
end

return DiceHandler