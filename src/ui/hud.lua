-- src/ui/hud.lua
local lg = love.graphics
local hud = {}

function hud.draw(numRerolls, totalScore)
  lg.printf("Rerolls left: " .. numRerolls, 50, 370, 200, "left")
  if numRerolls == 0 then
    lg.printf("No rerolls left!", 50, 400, 200, "left")
  end
  lg.printf("Total Score: " .. totalScore, 50, 430, 200, "left")
end

return hud
