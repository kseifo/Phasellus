local Scoresheet = {}
Scoresheet.__index = Scoresheet

local categories = {
  "Ones","Twos","Threes","Fours","Fives","Sixes",
  "3 of a Kind","4 of a Kind","Full House",
  "Small Straight","Large Straight","Yahtzee","Chance","Bonus"
}

-- Constructor
function Scoresheet.new()
    local self = setmetatable({}, Scoresheet)
    self.scores = {}
    for _, category in ipairs(categories) do
        self.scores[category] = nil
    end
    print("scores size: " .. #self.scores)
    return self
end

function Scoresheet:sumDice(dice)
    local total = 0
    for _, die in ipairs(dice) do
        total = total + die:getValue()
    end
    return total
end

function Scoresheet:numsScored()
    if self.scores["Ones"] and self.scores["Twos"] and self.scores["Threes"] and
       self.scores["Fours"] and self.scores["Fives"] and self.scores["Sixes"] then
        return true
    end
    return false
end

-- Calculate the score for ones to sixes
function Scoresheet:calculateMultiples(dice, face)
    local count = 0

    for _, die in ipairs(dice) do
        if die:getValue() == face then
            count = count + 1
        end
    end

    return count * face
end

-- Checking for a 3 of a kind, 4 of a kind, or Yahtzee
function Scoresheet:hasNofAKind(dice, n)
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
            return self:sumDice(dice)
        end
    end
    return 0
end

-- Checking for a full house
function Scoresheet:hasFullHouse(dice)
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
function Scoresheet:hasStraight(dice, length)
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
function Scoresheet:calculateChance(dice)
    return self:sumDice(dice)
end

function Scoresheet:bonusReached()
    if self:numsScored() then
        local total = self.scores["Ones"] + self.scores["Twos"] + self.scores["Threes"] + self.scores["Fours"] + self.scores["Fives"] + self.scores["Sixes"]
        return total >= 63 and 35 or 0
    end
    return 0
end

function Scoresheet:setScore(dice, category)
    if self.scores[category] ~= nil then
        return self.scores[category] -- Already scored
    end

    if category == "Ones" then
        self.scores["Ones"] = self:calculateMultiples(dice, 1)
    elseif category == "Twos" then
        self.scores["Twos"] = self:calculateMultiples(dice, 2)
    elseif category == "Threes" then
        self.scores["Threes"] = self:calculateMultiples(dice, 3)
    elseif category == "Fours" then
        self.scores["Fours"] = self:calculateMultiples(dice, 4)
    elseif category == "Fives" then
        self.scores["Fives"] = self:calculateMultiples(dice, 5)
    elseif category == "Sixes" then
        self.scores["Sixes"] = self:calculateMultiples(dice, 6)
    elseif category == "3 of a Kind" then
        self.scores["3 of a Kind"] = self:hasNofAKind(dice, 3)
    elseif category == "4 of a Kind" then
        self.scores["4 of a Kind"] = self:hasNofAKind(dice, 4)
    elseif category == "Full House" then
        self.scores["Full House"] = self:hasFullHouse(dice)
    elseif category == "Small Straight" then
        self.scores["Small Straight"] = self:hasStraight(dice, 4)
    elseif category == "Large Straight" then
        self.scores["Large Straight"] = self:hasStraight(dice, 5)
    elseif category == "Yahtzee" then
        self.scores["Yahtzee"] = self:hasNofAKind(dice, 5)
    elseif category == "Chance" then
        self.scores["Chance"] = self:calculateChance(dice)
    elseif category == "Bonus" then
        self.scores["Bonus"] = self:bonusReached()
    end

    return self.scores[category]
end

function Scoresheet:calculateScore(dice, category)
    if category == "Ones" then
        return self:calculateMultiples(dice, 1)
    elseif category == "Twos" then
        return self:calculateMultiples(dice, 2)
    elseif category == "Threes" then
        return self:calculateMultiples(dice, 3)
    elseif category == "Fours" then
        return self:calculateMultiples(dice, 4)
    elseif category == "Fives" then
        return self:calculateMultiples(dice, 5)
    elseif category == "Sixes" then
        return self:calculateMultiples(dice, 6)
    elseif category == "3 of a Kind" then
        return self:hasNofAKind(dice, 3)
    elseif category == "4 of a Kind" then
        return self:hasNofAKind(dice, 4)
    elseif category == "Full House" then
        return self:hasFullHouse(dice)
    elseif category == "Small Straight" then
        return self:hasStraight(dice, 4)
    elseif category == "Large Straight" then
        return self:hasStraight(dice, 5)
    elseif category == "Yahtzee" then
        return self:hasNofAKind(dice, 5)
    elseif category == "Chance" then
        return self:calculateChance(dice)
    elseif category == "Bonus" then
        return self:bonusReached()
    end

    return 0 -- Invalid category
end

function Scoresheet:getScore(category)
    if category == "Ones" then
        return self.scores["Ones"] or 0
    elseif category == "Twos" then
        return self.scores["Twos"] or 0
    elseif category == "Threes" then
        return self.scores["Threes"] or 0
    elseif category == "Fours" then
        return self.scores["Fours"] or 0
    elseif category == "Fives" then
        return self.scores["Fives"] or 0
    elseif category == "Sixes" then
        return self.scores["Sixes"] or 0
    elseif category == "3 of a Kind" then
        return self.scores["3 of a Kind"] or 0
    elseif category == "4 of a Kind" then
        return self.scores["4 of a Kind"] or 0
    elseif category == "Full House" then
        return self.scores["Full House"] or 0
    elseif category == "Small Straight" then
        return self.scores["Small Straight"] or 0
    elseif category == "Large Straight" then
        return self.scores["Large Straight"] or 0
    elseif category == "Yahtzee" then
        return self.scores["Yahtzee"] or 0
    elseif category == "Chance" then
        return self.scores["Chance"] or 0
    elseif category == "Bonus" then
        return self.scores["Bonus"] or 0
    end

    return 0 -- Invalid category
end

function Scoresheet:getTotalScore()
    local total = 0
    for _, category in ipairs(categories) do
        if self.scores[category] then
            total = total + self.scores[category]
        end
    end
    return total
end

function Scoresheet:isSheetCompleted()
    for _, category in ipairs(categories) do
        if self.scores[category] == nil then
            return false -- At least one category is not scored
        end
    end
    return true -- All categories are scored
end

return Scoresheet