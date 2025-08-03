package.path = "../?.lua;../src/?.lua;src/?.lua;?.lua;" .. package.path

local luaunit = require('luaunit')

local hand = require('hand')

function testNewHand()
    local h = hand.new()
    luaunit.assertEquals(#h.reroll, 5)
    luaunit.assertEquals(#h.hold, 0)
end

function testGetAllDice()
    local h = hand.new()
    luaunit.assertEquals(#h:getAllDice(), 5)
end

os.exit(luaunit.LuaUnit.run())