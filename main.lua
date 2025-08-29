package.path = "src/?.lua;" .. package.path

local lg = love.graphics
local lm = love.mouse

local Hand = require("hand")
local Scoresheet = require("scoresheet")
local RollButtonUI = require("ui.rollbutton")
local EndScreenUI = require("ui.endScreen")
local HudUI = require("ui.hud")
local CategoryUI = require("ui.categoriesTable")
local DiceHandler = require("ui.diceHandler")
local BoardUI = require("ui.boardUI")
local diceUI = require("ui.diceUI")

local sheet, hand, allDice, diceHandler = nil, nil, nil, nil

local categories = {"Ones", "Twos", "Threes", "Fours", "Fives", "Sixes", "Bonus", "3 of a Kind", "4 of a Kind", "Full House", "Small Straight", "Large Straight", "Yahtzee", "Chance"}
local scoredCategories, currentSheet = {}, {}

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

    diceHandler = DiceHandler.new(hand)

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
    if not hand or not sheet or not diceHandler then return end
    if numRerolls > 0 then
        numRerolls = numRerolls - 1
        hand:rerollDice()

        for _, name in ipairs(categories) do
            currentSheet[name] = sheet:calculateScore(allDice, name)
        end

        -- positions of dice don’t change on reroll, but if you want to be safe:
        diceHandler:fixHeldPositions()
        diceHandler:fixRerollPositions()
    end
end

function love.draw()
    if not hand or not sheet or not diceHandler then return end

    if isSheetCompleted then
        EndScreenUI.draw(sheet, categories)
        return
    end

    -- Draw dice using coordinates from the handler
    diceUI.draw(diceHandler:getCoordinates(), allDice)

    RollButtonUI.draw()
    CategoryUI.draw(hoveredCategory, currentSheet, scoredCategories, sheet)
    HudUI.draw(numRerolls, totalScore)
end

function love.mousepressed(x, y, button)
    if not hand or not sheet or not diceHandler then return end

    if x > CategoryUI.catX and y > CategoryUI.bonusY and y < (CategoryUI.bonusY + 45) then
        return
    end

    if button == 1 then
        if RollButtonUI.hit(x, y) then
            rollDice()
        end

        -- Score category clicks
        for i, name in ipairs(categories) do
            local categoryY = CategoryUI.catY + (i - 1) * 45
            if x >= CategoryUI.catX and x <= (CategoryUI.catX + 250) and y >= categoryY and y <= categoryY + 30 then
                local score = sheet:calculateScore(allDice, name)
                sheet:setScore(allDice, name)
                numRerolls = 3

                scoredCategories[name] = score

                -- Move all held dice down for next roll
                local heldDice = hand:getHeldDice()
                for i = #heldDice, 1, -1 do
                    hand:moveToReroll(heldDice[i])
                end

                if sheet:numsScored() then
                    sheet:setScore(allDice, "Bonus")
                end

                -- Update positions and roll
                diceHandler:fixRerollPositions()
                rollDice()

                isSheetCompleted = sheet:isSheetCompleted()
                totalScore = sheet:getTotalScore()
                break
            end
        end

        -- Dice clicks routed to handler
        diceHandler:onClick(x, y)
    end
end

function love.mousemoved(x, y)
    -- Bounds check
    if x < 950 or x > 1200 or y < 50 or y > (50 + (#categories - 1) * 45 + 30) or (y >= 320 and y <= 365) then
        hoveredCategory = nil
        return
    end

    local relativeY = y - 50
    local categoryIndex = math.floor(relativeY / 45) + 1

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
