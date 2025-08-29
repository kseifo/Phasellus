local lg = love.graphics

local diceUI = {}
local DiceHandler = {}

function diceUI.new(dHandler)
    DiceHandler = dHandler
end

function diceUI.draw(dice)
    local diceCoordinates = DiceHandler:getCoordinates()

    for _, die in ipairs(dice) do
        lg.draw(DiceHandler:getDiceImage(die:getValue()), diceCoordinates[die][1], diceCoordinates[die][2])
    end
end

return diceUI