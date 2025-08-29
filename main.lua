package.path = "src/?.lua;" .. package.path

local lg = love.graphics
local lm = love.mouse

local Hand = require("hand")
local Scoresheet = require("scoresheet")

local sheet = nil
local hand = nil
local allDice = nil

local diceCoordinates = {}

local RollButtonUI = require("ui.rollbutton")
local EndScreenUI = require("ui.endScreen")
local HudUI = require("ui.hud")
local CategoryUI = require("ui.categoriesTable")
local DiceHandler = require("ui.diceHandler")
local BoardUI = require("ui.boardUI")
local diceUI = require("ui.diceUI")

local categories = {"Ones", "Twos", "Threes", "Fours", "Fives", "Sixes", "Bonus", "3 of a Kind", "4 of a Kind", "Full House", "Small Straight", "Large Straight", "Yahtzee", "Chance"}
local scoredCategories = {}
local currentSheet = {}

local handCursor = lm.getSystemCursor("hand")
local defaultCursor = lm.getSystemCursor("arrow")

local numRerolls = 0
local hoveredCategory = nil

local isSheetCompleted = false
local totalScore = 0

function love.load()
    love.window.setMode(1280, 720, {resizable=false, fullscreen=false})
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
        currentSheet[name] = sheet:calculateScore(allDice, name)
    end

    numRerolls = 2
end

function love.update(dt)
    if hoveredCategory then
        lm.setCursor(handCursor)
    else
        lm.setCursor(defaultCursor)
    end
end


local function rollDice()
    if not hand or not sheet then return end

    if numRerolls > 0 then
        numRerolls = numRerolls - 1
        hand:rerollDice()
        
        for _, name in ipairs(categories) do
            currentSheet[name] = sheet:calculateScore(allDice, name)
        end
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
    if isSheetCompleted == true then
        EndScreenUI.draw(sheet, categories)
        return
    end

    diceUI.draw(diceCoordinates, allDice)

    RollButtonUI.draw()

    CategoryUI.draw(hoveredCategory, currentSheet, scoredCategories, sheet)

    HudUI.draw(numRerolls, totalScore)
end

function love.mousepressed(x, y, button)
    if not hand or not sheet then return end

    if x > CategoryUI.catX and y > CategoryUI.bonusY and y < (CategoryUI.bonusY+45) then
        return
    end

    if button == 1 then -- left mouse click
        if RollButtonUI.hit(x, y) then
            rollDice()
        end

        -- Check for clicks on score categories
        for i, name in ipairs(categories) do
            local categoryY = CategoryUI.catY + (i - 1) * 45

            if x >= CategoryUI.catX and x <= (CategoryUI.catX+250) and y >= categoryY and y <= categoryY + 30 then
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
                isSheetCompleted = sheet:isSheetCompleted()
                totalScore = sheet:getTotalScore()
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
    if x < 950 or x > 1200 or y < 50 or y > (50 + (#categories - 1) * 45 + 30) or (y>=320 and y<=365) then
        hoveredCategory = nil
        return
    end

    local relativeY = y - 50
    local categoryIndex = math.floor(relativeY / 45) + 1
    
    -- Verify if the category index is valid
    if categoryIndex >= 1 and categoryIndex <= #categories then
        local categoryY = 50 + (categoryIndex - 1) * 45
        if y >= categoryY and y <= categoryY + 30 then
            hoveredCategory = categoryIndex
        else
            hoveredCategory = nil
        end
    else
        hoveredCategory = nil
    end
end
