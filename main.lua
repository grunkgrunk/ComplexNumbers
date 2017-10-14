local vec = require "lib.vec"
local arrow = require "lib.arrow"

-- todo: make the size of the window scalable.
-- this requires graphics to be drawn differently

local operations = {
    {sym = "+", fn = "add", args = 2},
    {sym = "-", fn = "sub", args = 2},
    {sym = "×", fn = "mul", args = 2},
    {sym = "/", fn = "div", args = 2},
    {sym = "pow", fn = "pow", args = 2},
    {sym = "sin", fn = "sin", args = 1},
    {sym = "cos", fn = "cos", args = 1},
    {sym = "tan", fn = "tan", args = 1},
    {sym = "csc", fn = "csc", args = 1},
    {sym = "sec", fn = "sec", args = 1},
    {sym = "cot", fn = "cot", args = 1},
    {sym = "sinh", fn = "sinh", args = 1},
    {sym = "cosh", fn = "cosh", args = 1},
    {sym = "tanh", fn = "tanh", args = 1},
    {sym = "csch", fn = "csch", args = 1},
    {sym = "sech", fn = "sech", args = 1},
    {sym = "coth", fn = "coth", args = 1}
}

local operation = 1

function drawcoordsys()
    -- numbers on the number-lines are off
    love.graphics.setColor(149, 165, 166)
    love.graphics.line(-w / 2, 0, w / 2, 0)
    love.graphics.line(0, -h / 2, 0, h / 2)

    love.graphics.setColor(52, 73, 94)
    for ix = 0, w / scale do
        local x = w / 2 - ix * scale
        love.graphics.line(x, -h / 2, x, h / 2)
    end

    -- numbers on the y-axis
    for iy = 0, h / scale do
        local y = h / 2 - iy * scale
        love.graphics.line(-w / 2, y, w / 2, y)
    end

    local margin = 4
    love.graphics.setFont(font)
    love.graphics.setColor(236, 240, 241)
    -- numbers on the x - axis
    for ix = 0, w / scale do
        local lh = scale / 16
        local x = w / 2 - ix * scale
        local txt = math.floor(w / scale - w / scale / 2 - ix)

        if txt ~= 0 then
            love.graphics.line(x, -lh, x, lh)
            love.graphics.print(txt, math.floor(x - font:getWidth(tostring(txt)) / 2), math.floor(lh + margin))
        end
    end

    -- numbers on the y-axis
    for iy = 0, h / scale do
        local lw = scale / 16
        local y = h / 2 - iy * scale
        local txt = -(h / scale - h / scale / 2 - iy)

        if txt ~= 0 then
            love.graphics.line(-lw, y, lw, y)
            love.graphics.print(tostring(txt) .. "i", math.floor(lw + margin), math.floor(y - font:getHeight() / 2))
        end
    end
end

local arrows = {
    arrow.new(1, 1, {230, 126, 34}),
    arrow.new(-1, 1, {39, 174, 96}),
    -- the last arrow is the resulting arrow:
    arrow.new(0, 0, {41, 128, 185})
}

local collision = false
local selected = nil

function love.load()
    love.graphics.setLineStyle("smooth")
    love.mouse.setVisible(false)
    love.window.setMode(800, 800)
    w, h = love.graphics.getDimensions()
    font = love.graphics.newFont("fonts/Roboto-Regular.ttf", 16)
    fontlarge = love.graphics.newFont("fonts/Roboto-Regular.ttf", 32)

    -- shouldnt change this. A lot of the drawing is hard-coded for now.
    scale = 50
    infox, infoy = scale * 4, -scale * 6
end

function love.update(dt)
    mx, my = love.mouse.getPosition()
    mx = (mx - w / 2) / scale
    my = (my - h / 2) / scale

    -- holding shift will round the mouse pos
    if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
        local dx = math.floor(mx * 4 + 0.5) / 4
        local dy = math.floor(my * 4 + 0.5) / 4
        mx = dx
        my = dy
    end

    local m = vec.new(mx, -my)

    -- here we calculate the blue arrow
    -- Should add some animation here
    -- get the first arrow
    local v = arrows[1].dir

    -- use the current operation on all the other numbers in the table, except the last.
    -- the last number is the resulting number, so we want to set that to what we calculate here.
    for i = 2, #arrows - 1 do
        local fn = operations[operation].fn
        v = vec[fn](v, arrows[i].dir)
    end
    arrows[#arrows].dir = v

    if love.mouse.isDown(1) then
        -- select the closest arrow to the mouse
        -- only select it if it's 0.3 coordinate units away from the mosue
        -- don't select the last arrow, because that's the blue answer arrow!
        if not selected then
            local mindist = 10000
            for i = 1, #arrows-1 do
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
        selected.dir = vec.new(m.x, m.y)
    end
end

function love.draw()
    love.graphics.clear(44, 62, 80)
    love.graphics.translate(w / 2, h / 2)
    love.graphics.setLineWidth(0.5)

    drawcoordsys()

    for i = 1, operations[operation].args do
        local a = arrows[i]
        arrow.draw(a, scale)
    end
    arrow.draw(arrows[#arrows], scale)

    -- draw the infobox
    love.graphics.push()
    love.graphics.translate(infox, infoy)
    love.graphics.setColor(0, 0, 0, 10)
    love.graphics.rectangle("fill", 0, 0, scale * 2, scale * 2)
    love.graphics.setColor(0, 0, 0, 50)
    love.graphics.rectangle("line", 0, 0, scale * 2, scale * 2)
    love.graphics.setColor(200, 200, 200)
    love.graphics.line(scale * 0.2, scale, scale * 2 - scale * 0.2, scale)

    love.graphics.setColor(236, 240, 241)
    love.graphics.setFont(fontlarge)
    love.graphics.print(operations[operation].sym, 6, math.floor(scale * 2 - fontlarge:getHeight() + 3))

    love.graphics.setFont(font)
    love.graphics.translate(30, 3)
    local sep = 25
    for i = 1, operations[operation].args do
        local a = arrows[i]
        arrow.print(a, 0, (i - 1) * sep)
    end
    arrow.print(arrows[#arrows], 0, (#arrows - 1) * sep)

    love.graphics.pop()

    if selected ~= nil then
        love.graphics.setColor(selected.color)
    else
        love.graphics.setColor(236, 240, 241)
    end
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", mx * scale, my * scale, 5)
end

function nextoperation()
    operation = operation + 1
    if operation > #operations then
        operation = 1
    end
    -- add some fancy animation
end

function love.keypressed(key, scan, rep)
    if key == "q" or key == "escape" then
        love.event.quit()
    end
    if key == "tab" then
        nextoperation()
    end
end

function love.mousepressed(x, y, btn)
    -- if the mouse is inside the infox,
    if x > w / 2 + infox and x < w / 2 + infox + scale * 2 and y > h / 2 + infoy and y < h / 2 + infoy + scale * 2 then
        nextoperation()
    end
end
