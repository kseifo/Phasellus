package.path = "src/?.lua;" .. package.path

local Hand = require("hand")
local hand = nil
local allDice = nil

local diceCoordinates = {}
local dice = love.graphics.newImage("/assets/die1.png")
local rollButton = {x = 50, y = 300, width = 100, height = 40}
local categories = {"Ones", "Twos", "Threes", "Fours", "Fives", "Sixes", "Bonus", "3 of a Kind", "4 of a Kind", "Full House", "Small Straight", "Large Straight", "Yahtzee", "Chance"}

local numRerolls = 0

function love.load()
    math.randomseed(os.time())
    local font = love.graphics.newFont(16)
    love.graphics.setFont(font)
    hand = Hand.new()
    allDice = hand:getAllDice()

    for i, dice in ipairs(allDice) do
        diceCoordinates[dice] = {50 + (i - 1) * 70, 130} -- Set initial coordinates for each die
    end

    numRerolls = 3
end

local function rollDice()
    if not hand then return end
    numRerolls = numRerolls - 1
    if numRerolls < 0 then
        print("No rerolls left!")
        return
    end
    hand:rerollDice()
end

local function changeDiePos(die, newX, newY)
    if not diceCoordinates[die] then return end
    diceCoordinates[die][1] = newX
    diceCoordinates[die][2] = newY
end

local function fixHeldDicePositions()
    if not hand then return end
    local heldDice = hand:getHeldDice()
    for i, die in ipairs(heldDice) do
        changeDiePos(die, 50 + (i - 1) * 70, 40)
    end
end

local function fixRerollDicePositions()
    if not hand then return end
    local rerollDice = hand:getRerollDice()
    for i, die in ipairs(rerollDice) do
        changeDiePos(die, 50 + (i - 1) * 70, 130)
    end
end

local function moveDie(die)
    if not hand then return end
    
    if hand:isDieHeld(die) then
        hand:moveToReroll(die)
    else
        hand:moveToHold(die)
    end
    
    -- Fix all dice positions 
    fixHeldDicePositions()
    fixRerollDicePositions()
end

function love.draw()
    if not hand then return end
    for _, die in ipairs(allDice) do
        love.graphics.rectangle("line", diceCoordinates[die][1], diceCoordinates[die][2], 50, 50)
        love.graphics.printf(die:getValue(), diceCoordinates[die][1], diceCoordinates[die][2] + 15, 50, "center")
    end

    love.graphics.rectangle("line", rollButton.x, rollButton.y, rollButton.width, rollButton.height)
    love.graphics.printf("Roll", rollButton.x, rollButton.y + 10, rollButton.width, "center")

    for i, name in ipairs(categories) do
        love.graphics.printf(name, 500, 50 + (i - 1) * 40, 200, "left")
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then -- left mouse click
        if x > rollButton.x and x < rollButton.x + rollButton.width and
           y > rollButton.y and y < rollButton.y + rollButton.height then
            rollDice()
        end

        for die, coords in pairs(diceCoordinates) do
            if x > coords[1] and x < coords[1] + 50 and y > coords[2] and y < coords[2] + 50 then
                moveDie(die)
                break
            end
        end
    end
end
