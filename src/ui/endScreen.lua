local lg = love.graphics
local screen = {}

function screen.draw(sheet, categories)
    love.graphics.printf("Game Over! Total Score: " .. sheet:getTotalScore(), 100, 200, 700, "left")
    for i, name in ipairs(categories) do
        local categoryY = 50 + (i - 1) * 40

        lg.printf(name, 500, categoryY, 200, "left")
        lg.printf(sheet:getScore(name), 550, categoryY, 200, "right")
    end
end

return screen