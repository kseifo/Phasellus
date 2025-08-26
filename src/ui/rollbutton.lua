-- src/ui/roll_button.lua
local lg = love.graphics
local M = {}
local params = { x = 50, y = 300, width = 100, height = 40 }


function M.draw()
  lg.rectangle("line", params.x, params.y, params.width, params.height)
  lg.printf("Roll", params.x, params.y + 10, params.width, "center")
end

function M.hit(x, y)
  return x > params.x and x < params.x + params.width and y > params.y and y < params.y + params.height
end

return M
