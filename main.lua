package.path = "src/?.lua;" .. package.path

local lg = love.graphics

local Hand = require("hand")
local Scoresheet = require("scoresheet")
local sheet = nil

local hand = nil
local allDice = nil

local diceCoordinates = {}

local d1 = lg.newImage("/assets/die1.png")
local d2 = lg.newImage("/assets/die2.png")
local d3 = lg.newImage("/assets/die3.png")
local d4 = lg.newImage("/assets/die4.png")
local d5 = lg.newImage("/assets/die5.png")
local d6 = lg.newImage("/assets/die6.png")

local diceImages = {[1] = d1, [2] = d2, [3] = d3, [4] = d4, [5] = d5, [6] = d6}

local rollButton = {x = 50, y = 300, width = 100, height = 40}

local categories = {"Ones", "Twos", "Threes", "Fours", "Fives", "Sixes", "Bonus", "3 of a Kind", "4 of a Kind", "Full House", "Small Straight", "Large Straight", "Yahtzee", "Chance"}
local catLocations = {}

local scoredCategories = {}

local handCursor = love.mouse.getSystemCursor("hand")
local defaultCursor = love.mouse.getSystemCursor("arrow")

local numRerolls = 0
local hoveredCategory = nil

function love.load()
    math.randomseed(os.time())
    local font = lg.newFont(16)
    lg.setFont(font)

    hand = Hand.new()
    allDice = hand:getAllDice()
    sheet = Scoresheet.new()
    
    for i, dice in ipairs(allDice) do
        diceCoordinates[dice] = {50 + (i - 1) * 70, 130} -- Set initial coordinates for each die
    end

    for i, name in ipairs(categories) do
        local y = 50 + (i - 1) * 40
        catLocations[i] = { x = 500, y = y, w = 250, h = 30, name = name }
    end

    numRerolls = 2
end

function love.update(dt)
    if hoveredCategory then
        love.mouse.setCursor(handCursor)
    else
        love.mouse.setCursor(defaultCursor)
    end
end


local function rollDice()
    if not hand then return end
    if numRerolls > 0 then
        numRerolls = numRerolls - 1
        hand:rerollDice()
    end
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
    if not hand or not sheet then return end
    
    -- End screen
    if sheet:isSheetCompleted()==true then
        love.graphics.printf("Game Over! Total Score: " .. sheet:getTotalScore(), 100, 200, 700, "left")
        for i, name in ipairs(categories) do
            local categoryY = 50 + (i - 1) * 40

            lg.printf(name, 500, categoryY, 200, "left")
            lg.printf(sheet:getScore(name), 550, categoryY, 200, "right")
        end
        return
    end

    -- Draw dice
    for _, die in ipairs(allDice) do
        lg.draw(diceImages[die:getValue()], diceCoordinates[die][1], diceCoordinates[die][2])
    end

    -- Roll button 
    lg.rectangle("line", rollButton.x, rollButton.y, rollButton.width, rollButton.height)
    lg.printf("Roll", rollButton.x, rollButton.y + 10, rollButton.width, "center")

    for i, loc in ipairs(catLocations) do
         
        -- Draw hover background if this category is being hovered
        if hoveredCategory == i and loc.name~="Bonus" then
            lg.setColor(0.3, 0.3, 0.3, 0.5)
            lg.rectangle("fill", loc.x, loc.y, loc.w, loc.h)
        end

        -- White category name
        lg.setColor(1, 1, 1)
        lg.printf(loc.name, loc.x, loc.y, 200, "left")

        -- Calculate and display the score for each category(except Bonus, thats only when ones twos... are scored)
        if sheet:numsScored() or loc.name ~= "Bonus" then

            lg.setColor(0.5, 0.5, 0.5)

            local currentScore = sheet:calculateScore(allDice, loc.name)

            if scoredCategories[loc.name] then
                lg.setColor(1,1,1)
                currentScore = scoredCategories[loc.name]
            end

            lg.printf(currentScore, loc.x + 50, loc.y, 200, "right")
        end
    end
    lg.setColor(1, 1, 1)

    lg.printf("Rerolls left: " .. numRerolls, 50, 370, 200, "left")

    if numRerolls == 0 then
        lg.printf("No rerolls left!", 50, 400, 200, "left")
    end

    lg.printf("Total Score: " .. sheet:getTotalScore(), 50, 430, 200, "left")
end

function love.mousepressed(x, y, button)
    if not hand or not sheet then return end

    if x > 500 and y > 290 and y < 330 then
        return
    end

    if button == 1 then -- left mouse click
        if x > rollButton.x and x < rollButton.x + rollButton.width and
           y > rollButton.y and y < rollButton.y + rollButton.height then
            rollDice()
        end

        -- Check for clicks on score categories
        for i, name in ipairs(categories) do
            local categoryY = 50 + (i - 1) * 40

            if x >= 500 and x <= 750 and y >= categoryY and y <= categoryY + 30 then
                local score = sheet:calculateScore(allDice, name)
                sheet:setScore(allDice, name)
                numRerolls = 3 -- Reset rerolls after scoring

                scoredCategories[name] = score
                
                local heldDice = hand:getHeldDice()
                for i = #heldDice, 1, -1 do
                    hand:moveToReroll(heldDice[i])
                end
                if sheet:numsScored() then
                    sheet:setScore(allDice, "Bonus")
                end
                fixRerollDicePositions()
                rollDice()
                break
            end
        end

        -- Check for clicks on dice
        for die, coords in pairs(diceCoordinates) do
            if x > coords[1] and x < coords[1] + 50 and y > coords[2] and y < coords[2] + 50 then
                moveDie(die)
                break
            end
        end
    end
end

function love.mousemoved(x, y)
    -- Bounds check
    if x < 500 or x > 750 or y < 50 or y > (50 + (#categories - 1) * 40 + 30) or (y>=290 and y<=330) then
        hoveredCategory = nil
        return
    end

    local relativeY = y - 50
    local categoryIndex = math.floor(relativeY / 40) + 1
    
    -- Verify if the category index is valid
    if categoryIndex >= 1 and categoryIndex <= #categories then
        local categoryY = 50 + (categoryIndex - 1) * 40
        if y >= categoryY and y <= categoryY + 30 then
            hoveredCategory = categoryIndex
        else
            hoveredCategory = nil
        end
    else
        hoveredCategory = nil
    end
end
