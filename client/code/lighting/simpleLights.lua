--- This library is a trivial implementation of ray casting point lights for love2d/LÖVE.
--- It is heavily based on mattdesl's libGDX implementation, described here:
--- https://github.com/mattdesl/lwjgl-basics/wiki/2D-Pixel-Perfect-Shadows

--- This library was modified and refactored for my own needs.
--- Original version can be found here: https://github.com/dylhunn/simple-love-lights

local class = require("lib/middleclass")

local module = {}

module.Light = class('lighting/Light')

function module.Light:initialize(parameters)
    parameters = parameters or {}

    self.x = parameters.x or 0.0
    self.y = parameters.x or 0.0

    self.radiance = parameters.radiance or 500.0
    self.maxRadiance = parameters.maxRadiance or self.radiance

    self.red = parameters.red or 255.0
    self.green = parameters.green or 255.0
    self.blue = parameters.blue or 255.0

    self.occludersCanvas = love.graphics.newCanvas(self.maxRadiance, self.maxRadiance)
    self.shadowMapCanvas = love.graphics.newCanvas(self.maxRadiance, 1)
    self.lightRenderCanvas = love.graphics.newCanvas(self.maxRadiance, self.maxRadiance)
end

--- SETTERS / GETTERS ---

function module.Light:setPosition(position, y)
    if type(position) == "table" then
        self.x = position[1] or position.x
        self.y = position[2] or position.y
    else
        self.x = position
        self.y = y
    end
end

function module.Light:getPosition()
    return self.x, self.y
end

function module.Light:setRadiance(radiance)
    self.radiance = math.min(radiance, self.maxRadiance)
end

function module.Light:getRadiance()
    return self.radiance
end

function module.Light:setMaxRadiance(maxRadiance)
    self.maxRadiance = maxRadiance
    self.radiance = math.min(self.radiance, self.maxRadiance)
end

function module.Light:getMaxRadiance()
    return self.maxRadiance
end

function module.Light:setColor(color, green, blue)
    if type(position) == "table" then
        self.red = color[1] or color.red
        self.green = color[2] or color.green
        self.blue = color[3] or color.blue
    else
        self.red = color
        self.green = green
        self.blue = blue
    end
end

function module.Light:getColor()
    return self.red, self.green, self.blue
end

--- DRAWING STUFF ---

--- Shader for calculating the 1D shadow map.
local shadowMapShader = love.graphics.newShader("code/lighting/shadowMapShader.glsl")

--- Shader for rendering blurred lights and shadows.
local lightRenderShader = love.graphics.newShader("code/lighting/lightRenderShader.glsl")

--- Pass in a function that draws all shadow-casting objects to the screen.
function module.Light:update(drawOccludersFn)
    self.occludersCanvas:renderTo(function()
        love.graphics.clear()
    end)
    self.shadowMapCanvas:renderTo(function()
        love.graphics.clear()
    end)
    self.lightRenderCanvas:renderTo(function()
        love.graphics.clear()
    end)

    lightRenderShader:send("xresolution", self.radiance);
    lightRenderShader:send("maxResolution", self.maxRadiance);
    shadowMapShader:send("yresolution", self.radiance);
    shadowMapShader:send("maxResolution", self.maxRadiance);

    -- Upper-left corner of light-casting box.
    local x = self.x - (self.radiance / 2)
    local y = self.y - (self.radiance / 2)

    local fullQuad = love.graphics.newQuad(0, 0, math.min(self.radiance + 20, self.maxRadiance), self.radiance, self.occludersCanvas:getDimensions())
    local shadowQuad = love.graphics.newQuad(0, 0, self.radiance, 1, self.shadowMapCanvas:getDimensions())

    -- Translating the occluders by the position of the light-casting
    -- box causes only occluders in the box to appear on the canvas.
    love.graphics.push()
    love.graphics.origin()
    love.graphics.translate(-x, -y)
    self.occludersCanvas:renderTo(drawOccludersFn)
    love.graphics.pop()

    -- We need to un-apply any scrolling coordinate translation, because
    -- we want to draw the light/shadow effect canvas (and helpers) literally at
    -- (0, 0) on the screen. This didn't apply to the occluders because occluders
    -- on screen should be affected by scrolling translation.
    love.graphics.push()
    love.graphics.origin()

    love.graphics.setShader(shadowMapShader)
    love.graphics.setCanvas(self.shadowMapCanvas)
    love.graphics.draw(self.occludersCanvas, fullQuad, 0, 0)
    love.graphics.setCanvas()
    love.graphics.setShader()

    love.graphics.setShader(lightRenderShader)
    love.graphics.setCanvas(self.lightRenderCanvas)
    love.graphics.draw(self.shadowMapCanvas, shadowQuad, 0, 0, 0, 1, self.maxRadiance)
    love.graphics.setCanvas()
    love.graphics.setShader()

    love.graphics.pop()
end

function module.Light:draw()
    -- Upper-left corner of light-casting box.
    local x = self.x - (self.radiance / 2)
    local y = self.y - (self.radiance / 2)

    local fullQuad = love.graphics.newQuad(0, 0, self.radiance, self.radiance, self.lightRenderCanvas:getDimensions())

    love.graphics.setBlendMode("add")
    love.graphics.setColor(self.red, self.green, self.blue, 255)
    love.graphics.draw(self.lightRenderCanvas, fullQuad, x, y + self.radiance, 0, 1, -1)
    love.graphics.setBlendMode("alpha")
end

return module
