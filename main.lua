local vec = require 'util.vec'
local arrow = require 'util.arrow'

-- draw the current operation better
-- be able to change the current operation

local operations = {
  {sym='+', fn='add'},
  {sym='-', fn='sub'},
  {sym='×', fn='mul'}
}

local operation = 1

function drawcoordsys()
  -- numbers on the number-lines are off
  love.graphics.setColor(149, 165, 166)
  love.graphics.line(-w/2, 0, w/2, 0)
  love.graphics.line(0, -h/2, 0, h/2)

  love.graphics.setColor(52, 73, 94)
  for ix = 0, w/scale do
    local x = w/2-ix*scale
    love.graphics.line(x, -h/2, x, h/2)
  end

  -- numbers on the y-axis
  for iy = 0, h/scale do
    local y = h/2-iy*scale
    love.graphics.line(-w/2,y,w/2,y)
  end

  local margin = 4
  love.graphics.setColor(236, 240, 241)
  -- numbers on the x - axis
  for ix = 0, w/scale do
    local lh = scale/16
    local x = w/2-ix*scale
    local txt = math.floor(w/scale-w/scale/2-ix)

    if txt ~= 0 then
      love.graphics.line(x, -lh, x, lh)
      love.graphics.print(txt, x - font:getWidth(tostring(txt))/2, lh+margin)
    end
  end

  -- numbers on the y-axis
  for iy = 0, h/scale do
    local lw = scale/16
    local y = h/2-iy*scale
    local txt = -(h/scale-h/scale/2-iy)

    if txt ~= 0 then
      love.graphics.line(-lw,y,lw,y)
      love.graphics.print(tostring(txt) .. "i", lw+margin, y - font:getHeight()/2)
    end
  end
end

-- the last arrow is the resulting arrow
local arrows = {arrow.new(1,1, {230, 126, 34} ), arrow.new(-1, 1, {39, 174, 96}),
arrow.new(0,0, {41, 128, 185})}


local collision = false
local selected = nil

function love.load()
  love.graphics.setLineStyle("smooth")
  love.mouse.setVisible(false)
  love.window.setMode(800, 800)
  w,h = love.graphics.getDimensions()
  font = love.graphics.newFont("fonts/Roboto-Regular.ttf", 16)
  fontlarge = love.graphics.newFont("fonts/Roboto-Regular.ttf", 32)

  scale = 50

end

function love.update(dt)
  mx, my = love.mouse.getPosition()
  mx = (mx - w/2) / scale
  my = (my - h/2) / scale

  -- holding shift will round the mouse pos
  if love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift') then
    local dx = math.floor(mx*4 + 0.5) / 4
    local dy = math.floor(my*4 + 0.5) / 4
    mx = dx
    my = dy
  end

  local m = vec.new(mx,-my)

  -- i have all my arrow objects in
  -- a table so that i can add more if i want to
  local v = arrows[1].dir

  -- add up all numbers except the last - this is the resulting number
  for i=2, #arrows-1 do
    local fn = operations[operation].fn
    v = vec[fn](v, arrows[i].dir)
  end
  arrows[#arrows].dir = v

  if love.mouse.isDown(1) then
    -- select the closest arrow to the mouse
    -- only if its 0.3 coordinate units away from the mosue
    if not selected then
      local mindist = 10000
      for i=1, #arrows do
        local a = arrows[i]
        local d = vec.dst(m, a.dir)
        if d < 0.3 and d < mindist then
          mindist = d
          selected = a
        end
      end
    end
  else
    selected = nil
  end

  if selected ~= nil then
    selected.dir = vec.new(m.x,m.y)
  end


end

function love.draw()
  love.graphics.setFont(font)
  love.graphics.clear(44, 62, 80)
  love.graphics.translate(w/2, h/2)
  love.graphics.setLineWidth(0.5)

  drawcoordsys()

  --love.graphics.setColor(0,0,0)
  --love.graphics.rectangle("fill", -w/2.1,-h/2, scale*2, scale)


  for i=1, #arrows do
    local a = arrows[i]
    arrow.draw(a,scale)
  end

  --arrow.draw(res,scale)

  -- drawing the coordinates
  love.graphics.push()
  love.graphics.translate(scale*4, -scale*4)
  love.graphics.setColor(255, 255, 255, 10)
  love.graphics.rectangle("fill", 0,0, 100, 100)
  love.graphics.translate(25, 10)
  local sep = 25
  for i=1, #arrows do
    local a = arrows[i]
    arrow.print(a, 0,(i-1)*sep)
  end
  --arrow.print(res, 0,(#arrows)*sep)

  love.graphics.setColor(236, 240, 241)
  love.graphics.setFont(fontlarge)
  love.graphics.print(operations[operation].sym, -25, (#arrows-1)*sep - fontlarge:getHeight()/4)
  love.graphics.pop()


  if selected ~= nil then
    love.graphics.setColor(selected.color)
  else
    love.graphics.setColor(255,255,255)
  end
  love.graphics.setLineWidth(2)
  love.graphics.circle('line', mx*scale, my*scale, 5)
end

function love.keypressed(key, scan, rep)
  if key == 'q' or key == 'escape' then love.event.quit() end
  if key == 'tab' then
    operation = operation + 1
    if operation > #operations then
      operation = 1
    end
  end
end
