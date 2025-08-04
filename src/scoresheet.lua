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

-- Calculate the score for ones to sixes
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

    for _, die in ipairs(dice) do
        local val = die:getValue()
        count[val] = (count[val] or 0) + 1
    end

    for _, v in pairs(count) do
        if v == 5 then
            return 50
        end
        if v >= n then
            return hand:sumAllDice()
        end
    end
    return 0
end

-- Checking for a full house
function Scoresheet:hasFullHouse(hand)
    local dice = hand:getAllDice()
    local count = {}

    for _, die in ipairs(dice) do
        local val = die:getValue()
        count[val] = (count[val] or 0) + 1
    end

    local hasThree = false
    local hasTwo = false

    for _, v in pairs(count) do
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
                if length == 4 then
                    return 30
                elseif length == 5 then
                    return 40
                end
            end
        else
            consecutiveCount = 1
        end
    end

    return 0
end

-- Calculating the score for Chance (the sum of all dice)
function Scoresheet:calculateChance(hand)
    return hand:sumAllDice()
end

function Scoresheet:setScore(hand, category)
    if self.scores[category] ~= nil then
        return self.scores[category] -- Already scored
    end

    if category == "Ones" then
        self.scores["Ones"] = self:calculateMultiples(hand, 1)
    elseif category == "Twos" then
        self.scores["Twos"] = self:calculateMultiples(hand, 2)
    elseif category == "Threes" then
        self.scores["Threes"] = self:calculateMultiples(hand, 3)
    elseif category == "Fours" then
        self.scores["Fours"] = self:calculateMultiples(hand, 4)
    elseif category == "Fives" then
        self.scores["Fives"] = self:calculateMultiples(hand, 5)
    elseif category == "Sixes" then
        self.scores["Sixes"] = self:calculateMultiples(hand, 6)
    elseif category == "Three of a Kind" then
        self.scores["Three of a Kind"] = self:hasNofAKind(hand, 3)
    elseif category == "Four of a Kind" then
        self.scores["Four of a Kind"] = self:hasNofAKind(hand, 4)
    elseif category == "Full House" then
        self.scores["Full House"] = self:hasFullHouse(hand)
    elseif category == "Small Straight" then
        self.scores["Small Straight"] = self:hasStraight(hand, 4)
    elseif category == "Large Straight" then
        self.scores["Large Straight"] = self:hasStraight(hand, 5)
    elseif category == "Yahtzee" then
        self.scores["Yahtzee"] = self:hasNofAKind(hand, 5)
    elseif category == "Chance" then
        self.scores["Chance"] = self:calculateChance(hand)
    end

    return self.scores[category]
end

function Scoresheet:getTotalScore()
    local total = 0
    for _, value in pairs(self.scores) do
        if value then
            total = total + value
        end
    end
    return total
end
return Scoresheet