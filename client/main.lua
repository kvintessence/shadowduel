-- Example: Short Example
local simpleLights = require("lib/simpleLights")
local gamera = require("lib/gamera")

local cam = gamera.new(-500,-500,2000,2000)

local drawWorld = function()
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("fill", 200, 200, 30)
    love.graphics.rectangle("fill", 300, 100, 50, 50)
end

-------------------

function love.load()
    simpleLights.addLight(250, 250, 750, 250, 100, 0)
    simpleLights.addLight(450, 150, 1950, 50, 100, 250)
end

function love.update(dt)
	--love.window.setTitle("Light vs. Shadow Engine (FPS:" .. love.timer.getFPS() .. ")")
    cam:setWindow(0,0,love.graphics.getWidth(),love.graphics.getHeight())
    cam:setPosition(love.mouse.getX(), love.mouse.getY())
end

function love.draw()
    --love.graphics.clear(100, 100, 100, 255)

    cam:draw(function(l,t,w,h)
        love.window.setTitle("FPS:" .. love.timer.getFPS() .. ", COORDS: " .. l .. ", " .. t .. ", " .. w .. ", " .. h)
        simpleLights.drawLights(drawWorld, 0, 0)
        --simpleLights.drawLights(drawWorld, -l, -t)
        drawWorld()
    end)
end
