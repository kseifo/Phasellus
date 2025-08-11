package.path = "src/?.lua;" .. package.path

local Hand = require("hand")
local hand = nil

local diceCoordinates = {}
local dice = love.graphics.newImage("/assets/die1.png")
local rollButton = {x = 50, y = 300, width = 100, height = 40}
local categories = {"Ones", "Twos", "Threes", "Fours", "Fives", "Sixes"}

function love.load()
    math.randomseed(os.time())
    local font = love.graphics.newFont(24)
    love.graphics.setFont(font)
    hand = Hand.new()
    local allDice = hand:getAllDice()


    for i, dice in ipairs(allDice) do
        diceCoordinates[dice] = {50 + (i - 1) * 70, 130} -- Set initial coordinates for each die
    end

    for k, v in ipairs(diceCoordinates) do
        print(k, v[1])
        print(k, v[2])
    end
end

local function rollDice()
    if hand then
        hand:rerollDice()
    end
end

local function changeDieY(die, newY)
    if not diceCoordinates[die] then return end
    diceCoordinates[die][2] = newY
end

local function moveDie(die)
    if not hand then return end
    
    if hand:isDieHeld(die) then
        hand:moveToReroll(die)
        changeDieY(die, 130) -- Reset Y position for reroll dice
        print("Moved die to reroll")
    else
        -- Die must be in reroll dice
        hand:moveToHold(die)
        changeDieY(die, 40) -- Move to held position
        print("Moved die to hold")
    end
end

function love.draw()
    if not hand then return end
    local heldDice = hand:getHeldDice()
    for _, die in ipairs(heldDice) do
        love.graphics.draw(dice, diceCoordinates[die][1], diceCoordinates[die][2])
    end

    local rrdice = hand:getRerollDice()
    for _, die in ipairs(rrdice) do
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
                if not hand then return end
                print("Clicked on die with value: " .. die:getValue())
                moveDie(die)
            end
        end
    end
end
