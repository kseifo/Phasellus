-- src/ui/category_panel.lua
local lg = love.graphics
local cat = {}

local catLocations = {}
local catX = 950
local catY = 50
local catYSpacing = 45
local bonusY = 320

local categories = {"Ones", "Twos", "Threes", "Fours", "Fives", "Sixes", "Bonus", "3 of a Kind", "4 of a Kind", "Full House", "Small Straight", "Large Straight", "Yahtzee", "Chance"}

cat.catX = 950
cat.catY = 50
cat.catYSpacing = 45
cat.bonusY = 320

for i, name in ipairs(categories) do
  local y = catY + (i - 1) * catYSpacing
  catLocations[i] = { x = catX, y = y, w = 250, h = 30, name = name }
end

function cat.draw(hoveredIdx, currentSheet, scored, sheet)
  for i, loc in ipairs(catLocations) do
    -- hover tint (skip Bonus)
    if hoveredIdx == i and loc.name ~= "Bonus" then
      lg.setColor(0.3, 0.3, 0.3, 0.5)
      lg.rectangle("fill", loc.x, loc.y, loc.w, loc.h)
    end

    -- name
    lg.setColor(1,1,1)
    lg.printf(loc.name, loc.x, loc.y, 200, "left")

    -- value (Bonus appears only after nums scored)
    if loc.name ~= "Bonus" or sheet:numsScored() then
      local shown = scored[loc.name] or currentSheet[loc.name] or 0
      lg.setColor(scored[loc.name] and 1 or 0.5, scored[loc.name] and 1 or 0.5, scored[loc.name] and 1 or 0.5)
      lg.printf(shown, loc.x + 50, loc.y, 200, "right")
    end
  end
  lg.setColor(1,1,1)
end

function cat.getCategoryLocation(index)
  return catLocations[index]
end

return cat
