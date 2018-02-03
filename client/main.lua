-- Example: Short Example
local simpleLights = require("lib/simpleLights")
local gamera = require("lib/gamera")

--local cam = gamera.new(-500,-500,2000,2000)
local cam = gamera.new(0, 0, 2000, 2000)

local drawWorld = function()
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("fill", 200, 200, 30)
    love.graphics.rectangle("fill", 300, 100, 50, 50)
end

-------------------

function love.keypressed(key, scancode, isrepeat)
    if key == "q" then
        cam:setScale((9.0 / 8.0) * cam:getScale())
    end

    if key == "a" then
        cam:setScale((8.0 / 9.0) * cam:getScale())
    end

    if key == "w" then
        --local size = light2.size
        --simpleLights.clearLights()
        --light2 = simpleLights.addLight(450, 250, size + 25, 50, 100, 250)
        light2.size = light2.size + 25
    end

    if key == "s" then
        --local size = light2.size
        --simpleLights.clearLights()
        --light2 = simpleLights.addLight(450, 250, size - 25, 50, 100, 250)
        light2.size = light2.size - 25
    end
end

function love.load()
    simpleLights.addLight(250, 250, 250, 250, 100, 0)
    light2 = simpleLights.addLight(450, 250, 650, 50, 100, 250)
end

function love.update(dt)
    cam:setWindow(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    --cam:setPosition(love.mouse.getX(), love.mouse.getY())
    light2.x = love.mouse.getX()
    light2.y = love.mouse.getY()
end

function love.draw()
    --love.graphics.clear(100, 100, 100, 255)

    cam:draw(function(l, t, w, h)
        love.window.setTitle("FPS:" .. love.timer.getFPS() .. ", L2: " .. light2.size)
        simpleLights.drawLights(drawWorld, l, t)
        drawWorld()
    end)
end
