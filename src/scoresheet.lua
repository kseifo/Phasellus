local Scoresheet = {}
Scoresheet.__index = Scoresheet

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
    return -1
end



