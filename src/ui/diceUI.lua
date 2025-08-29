local dHandler = require("src.ui.diceHandler")
local lg = love.graphics

local diceUI = {}

function diceUI.draw(diceCoordinates, dice)
    for _, die in ipairs(dice) do
        lg.draw(dHandler.getDiceImage(die:getValue()), diceCoordinates[die][1], diceCoordinates[die][2])
    end
end

return diceUI