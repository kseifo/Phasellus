local Scoresheet = {}
Scoresheet.__index = Scoresheet

-- Constructor
function Scoresheet.new()
    local self = setmetatable({}, Scoresheet)
    self.scores = {["Ones"] = nil, ["Twos"] = nil, ["Threes"] = nil, ["Fours"] = nil, ["Fives"] = nil, ["Sixes"] = nil,
                   ["Three of a Kind"] = nil, ["Four of a Kind"] = nil, ["Full House"] = nil,
                   ["Small Straight"] = nil, ["Large Straight"] = nil, ["Yahtzee"] = nil, ["Chance"] = nil}
    return self
end

function Scoresheet:calculateMultiples(hand, face)
    local dice = hand:getAllDice()
    local count = 0
    for _, die in ipairs(dice) do
        if die:getValue() == face then
            count = count + 1
        end
    end
    return count * face
end

-- Checking for a 3 of a kind, 4 of a kind, or Yahtzee
function Scoresheet:hasNofAKind(hand, n)
    local dice = hand:getAllDice()
    local count = {}

    for _, dice in ipairs(dice) do
        local val = dice:getValue()
        count[val] = (count[val] or 0) + 1
    end

    for _, v in pairs(count) do
        if v >= n then
            return n*v
        end
    end
    return 0
end

-- Checking for a full house
function Scoresheet:hasFullHouse(hand)
    local dice = hand:getAllDice()
    local count = {}

    for _, dice in ipairs(dice) do
        local val = dice:getValue()
        count[val] = (count[val] or 0) + 1
    end

    local hasThree = false
    local hasTwo = false

    for _, v in ipairs(count) do
        if v == 3 then
            hasThree = true
        elseif v == 2 then
            hasTwo = true
        end
    end
    
    return hasThree and hasTwo and 25 or 0
end

-- Calculating the score for small and large straights
function Scoresheet:hasStraight(hand, length)
    local dice = hand:getAllDice()
    local uniqueValues = {}

    for _, die in ipairs(dice) do
        uniqueValues[die:getValue()] = true
    end

    local sortedValues = {}
    for value in pairs(uniqueValues) do
        table.insert(sortedValues, value)
    end
    table.sort(sortedValues)

    local consecutiveCount = 1
    for i = 2, #sortedValues do
        if sortedValues[i] == sortedValues[i - 1] + 1 then
            consecutiveCount = consecutiveCount + 1
            if consecutiveCount >= length then
                if length == 4 then return 30 end
                if length == 5 then return 40 end
                return 0
            end
        else
            consecutiveCount = 1
        end
    end

    return 0
end

-- Calculating the score for Chance (the sum)
function Scoresheet:calculateChance(hand)
    local dice = hand:getAllDice()
    local total = 0

    for _, die in ipairs(dice) do
        total = total + die:getValue()
    end

    return total
end

