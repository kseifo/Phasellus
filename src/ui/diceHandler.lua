local handler = {}
local lg = love.graphics
local diceImages = {}
for i = 1, 6 do
    diceImages[i] = lg.newImage("/assets/die" .. i .. ".png")
end

function handler.getDiceImage(value)
    return diceImages[value]
end

return handler