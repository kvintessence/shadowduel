-- This library is a trivial implementation of raycasting point lights for love2d/LÖVE.
-- It is heavily based on mattdesl's libGDX implementation, described here:
--   https://github.com/mattdesl/lwjgl-basics/wiki/2D-Pixel-Perfect-Shadows

-- The light data is stored here.
local lightInfos = {}

----------------
-- PUBLIC API --
----------------

-- Call this function to add a new light; provide the absolute coordinates, size of
-- the illuminated containing box, and color.
function addLight(lx, ly, lsize, lr, lg, lb)

    -- Don't allow multiple lights at the same point.
    for _, li in ipairs(lightInfos) do
        if li.x == lx and li.y == ly then return end
    end

    local newLight = {
        x = lx, y = ly, size = lsize, r = lr, g = lg, b = lb,
        occludersCanvas = love.graphics.newCanvas(lsize, lsize),
        shadowMapCanvas = love.graphics.newCanvas(lsize, 1),
        lightRenderCanvas = love.graphics.newCanvas(lsize, lsize),
    }

    table.insert(lightInfos, newLight)

    return newLight
end

-- Clear all lights.
function clearLights()
    lightInfos = {}
end

-- You must call this from the main draw function, before drawing other objects.
-- Pass in a function that draws all shadow-casting objects to the screen.
-- Also pass in the coordinate transformation from absolute coordinates.
function drawLights(drawOccludersFn, coordTransX, coordTransY)
    for i = 1, #lightInfos do
        drawLight(drawOccludersFn, lightInfos[i], coordTransX, coordTransY)
    end
end

------------------
-- PRIVATE DATA --
------------------


-- Shader for caculating the 1D shadow map.
local shadowMapShader = love.graphics.newShader("code/lighting/shadowMapShader.glsl")

-- Shader for rendering blurred lights and shadows.
local lightRenderShader = love.graphics.newShader("code/lighting/lightRenderShader.glsl")

function drawLight(drawOccludersFn, lightInfo, coordTransX, coordTransY)
    lightInfo.occludersCanvas:renderTo(function()
        love.graphics.clear()
    end)
    lightInfo.shadowMapCanvas:renderTo(function()
        love.graphics.clear()
    end)
    lightInfo.lightRenderCanvas:renderTo(function()
        love.graphics.clear()
    end)

    lightRenderShader:send("xresolution", lightInfo.size);
    shadowMapShader:send("yresolution", lightInfo.size);

    -- Upper-left corner of light-casting box.
    local x = lightInfo.x - (lightInfo.size / 2)-- - coordTransX
    local y = lightInfo.y - (lightInfo.size / 2)-- - coordTransY

    --local fullQuad = love.graphics.newQuad(0, 0, lightInfo.size, lightInfo.size, lightInfo.occludersCanvas:getDimensions())
    --local shadowMapQuad = love.graphics.newQuad(0, 0, lightInfo.size, 1, lightInfo.shadowMapCanvas:getDimensions())

    -- Translating the occluders by the position of the light-casting
    -- box causes only occluders in the box to appear on the canvas.
    love.graphics.push()
    love.graphics.origin()
    love.graphics.translate(-x, -y)
    lightInfo.occludersCanvas:renderTo(drawOccludersFn)
    love.graphics.pop()

    -- We need to un-apply any scrolling coordinate translation, because
    -- we want to draw the light/shadow effect canvas (and helpers) literally at
    -- (0, 0) on the screen. This didn't apply to the occluders because occluders
    -- on screen should be affected by scrolling translation.
    love.graphics.push()
    love.graphics.origin()

    love.graphics.setShader(shadowMapShader)
    love.graphics.setCanvas(lightInfo.shadowMapCanvas)
    love.graphics.draw(lightInfo.occludersCanvas, 0, 0)
    --love.graphics.draw(lightInfo.occludersCanvas, fullQuad, 0, 0)
    love.graphics.setCanvas()
    love.graphics.setShader()

    love.graphics.setShader(lightRenderShader)
    love.graphics.setCanvas(lightInfo.lightRenderCanvas)
    --love.graphics.draw(lightInfo.shadowMapCanvas, shadowMapQuad, 0, 0, 0, 1, lightInfo.size)
    love.graphics.draw(lightInfo.shadowMapCanvas, 0, 0, 0, 1, lightInfo.size)
    love.graphics.setCanvas()
    love.graphics.setShader()

    love.graphics.pop()

    love.graphics.setBlendMode("add")
    love.graphics.setColor(lightInfo.r, lightInfo.g, lightInfo.b, 255)
    --love.graphics.draw(lightInfo.lightRenderCanvas, fullQuad, x, y + lightInfo.size, 0, 1, -1)
    love.graphics.draw(lightInfo.lightRenderCanvas, x, y + lightInfo.size, 0, 1, -1)
    love.graphics.setBlendMode("alpha")
end

return {
    addLight = addLight,
    clearLights = clearLights,
    drawLights = drawLights,
}
