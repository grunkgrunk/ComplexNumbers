local vec = require 'util.vec'

local arrow = {}

function arrow.new(x,y,color,scale)
  return {
    dir = vec.new(x,y),
    color = color,
  }
end

function arrow.draw(a, scale)
  local c,d = a.color, a.dir

  love.graphics.setColor(a.color)
  love.graphics.setLineWidth(3)
  local x,y = d.x*scale, -d.y*scale
  love.graphics.line(0,0, x,y)

  love.graphics.push()
  love.graphics.translate(x,y)
  love.graphics.rotate(math.atan2(y, x) + math.pi/2)
  -- scale the size of the arrow if it's length is small
  local ascale = 1
  local mag = vec.mag(d)
  if mag < 0.5 then
    ascale = (mag+0.5)
  end
  if mag > 0 then
    love.graphics.setLineWidth(2)
    love.graphics.line(0,0, 5*ascale,10*ascale)
    love.graphics.line(0,0, -5*ascale,10*ascale)
  else
    love.graphics.circle('fill', 0,0, 5)
  end
  love.graphics.pop()
end

function arrow.print(a, x,y)
  local d = a.dir
  local tx,ty = math.floor(d.x*10+0.5)/10, math.floor(d.y*10)/10
  -- we should format the string so there is same space between commas
  local txt = "(" .. tx .. ", " .. ty .. ")"
  love.graphics.setColor(a.color)
  love.graphics.print(txt, x,y)
end

return arrow
