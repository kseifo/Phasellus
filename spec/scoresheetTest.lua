package.path = "../?.lua;../src/?.lua;src/?.lua;?.lua;" .. package.path

local luaunit = require('luaunit')

local hand = require('hand')
local scoresheet = require('scoresheet')

function testCalculateMultiples()
    local h = hand.new()
    h.reroll[1]:setValue(1)
    h.reroll[2]:setValue(1)
    h.reroll[3]:setValue(2)
    h.reroll[4]:setValue(3)
    h.reroll[5]:setValue(4)

    local sheet = scoresheet.new()
    luaunit.assertEquals(sheet:calculateMultiples(h, 1), 2)
    luaunit.assertEquals(sheet:calculateMultiples(h, 2), 2)
    luaunit.assertEquals(sheet:calculateMultiples(h, 3), 3)
    luaunit.assertEquals(sheet:calculateMultiples(h, 4), 4)
end

function testThreeofAKind()
    local h = hand.new()
    h.reroll[1]:setValue(2)
    h.reroll[2]:setValue(2)
    h.reroll[3]:setValue(2)
    h.reroll[4]:setValue(3)
    h.reroll[5]:setValue(4)

    local sheet = scoresheet.new()
    luaunit.assertEquals(sheet:hasNofAKind(h, 3), 13)
    luaunit.assertEquals(sheet:hasNofAKind(h, 4), 0)
end

function testFourofAKind()
    local h = hand.new()
    h.reroll[1]:setValue(3)
    h.reroll[2]:setValue(3)
    h.reroll[3]:setValue(3)
    h.reroll[4]:setValue(3)
    h.reroll[5]:setValue(4)

    local sheet = scoresheet.new()
    luaunit.assertEquals(sheet:hasNofAKind(h, 4), 16)
end

function testYahtzee()
    local h = hand.new()
    for i = 1, 5 do
        h.reroll[i]:setValue(6)
    end

    local sheet = scoresheet.new()
    luaunit.assertEquals(sheet:hasNofAKind(h, 5), 50)
end

function testFullHouse()
    local h = hand.new()
    h.reroll[1]:setValue(2)
    h.reroll[2]:setValue(2)
    h.reroll[3]:setValue(3)
    h.reroll[4]:setValue(3)
    h.reroll[5]:setValue(3)

    local sheet = scoresheet.new()
    luaunit.assertEquals(sheet:hasFullHouse(h), 25)

    -- Test without full house
    h.reroll[5]:setValue(4)
    luaunit.assertEquals(sheet:hasFullHouse(h), 0)
end

function testSmallStraight()
    local h = hand.new()
    h.reroll[1]:setValue(1)
    h.reroll[2]:setValue(2)
    h.reroll[3]:setValue(3)
    h.reroll[4]:setValue(4)
    h.reroll[5]:setValue(6)

    local sheet = scoresheet.new()
    luaunit.assertEquals(sheet:hasStraight(h, 4), 30)

    -- Test without small straight
    h.reroll[4]:setValue(5)
    luaunit.assertEquals(sheet:hasStraight(h, 4), 0)
end

function testLargeStraight()
    local h = hand.new()
    h.reroll[1]:setValue(2)
    h.reroll[2]:setValue(3)
    h.reroll[3]:setValue(4)
    h.reroll[4]:setValue(5)
    h.reroll[5]:setValue(6)

    local sheet = scoresheet.new()
    luaunit.assertEquals(sheet:hasStraight(h, 5), 40)

    -- Test without large straight
    h.reroll[5]:setValue(5)
    luaunit.assertEquals(sheet:hasStraight(h, 5), 0)
end

os.exit(luaunit.LuaUnit.run())