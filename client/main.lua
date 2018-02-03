local lighting = require("code/lighting/simpleLights")
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
        light2:setRadiance(light2:getRadiance() + 25)
    end

    if key == "s" then
        light2:setRadiance(light2:getRadiance() - 25)
    end
end

function love.load()
    light2 = lighting.Light:new({ x = 450, y = 250, radiance = 850, red = 50, green = 100, blue = 250 })
end

function love.update(dt)
    cam:setWindow(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    --cam:setPosition(love.mouse.getX(), love.mouse.getY())
    light2:setPosition(love.mouse.getX(), love.mouse.getY())
end

function love.draw()
    --love.graphics.clear(100, 100, 100, 255)

    light2:update(drawWorld)

    cam:draw(function(l, t, w, h)
        love.window.setTitle("FPS:" .. love.timer.getFPS() .. ", L2: " .. light2.radiance)
        light2:draw()
        drawWorld()
    end)
end
