--- This library is a trivial implementation of ray casting point lights for love2d/LÖVE.
--- It is heavily based on mattdesl's libGDX implementation, described here:
--- https://github.com/mattdesl/lwjgl-basics/wiki/2D-Pixel-Perfect-Shadows

--- Quint: This library was modified and refactored for my own needs.
--- Original version can be found here: https://github.com/dylhunn/simple-love-lights

local class = require("lib/middleclass")

local module = {}

module.Light = class('lighting/Light')

function module.Light:initialize(parameters)
    parameters = parameters or {}

    self.radiance = parameters.radiance or 500.0
    self.maxRadiance = parameters.maxRadiance or self.radiance

    self.red = parameters.red or 255.0
    self.green = parameters.green or 255.0
    self.blue = parameters.blue or 255.0

    self.occludersCanvas = love.graphics.newCanvas(self.maxRadiance, self.maxRadiance)
    self.shadowMapCanvas = love.graphics.newCanvas(self.maxRadiance, 1)
    -- reusing the same canvas because we can; just don't forget to clear it
    self.lightRenderCanvas = self.occludersCanvas
end

function module.Light:serialize()
    return {
        radiance = self.radiance,
    }
end

function module.Light:deserialize(value)
    self.radiance = value.radiance or self.radiance
end

--- SETTERS / GETTERS ---

function module.Light:setRadiance(radiance)
    self.radiance = math.max(0, math.min(radiance, self.maxRadiance))
end

function module.Light:getRadiance()
    return self.radiance
end

function module.Light:setMaxRadiance(maxRadiance)
    local shouldRecreateCanvas = maxRadiance > self.maxRadiance

    self.maxRadiance = maxRadiance
    self.radiance = math.min(self.radiance, self.maxRadiance)

    if shouldRecreateCanvas then
        self.occludersCanvas = love.graphics.newCanvas(self.maxRadiance, self.maxRadiance)
        self.shadowMapCanvas = love.graphics.newCanvas(self.maxRadiance, 1)
        -- reusing the same canvas because we can; just don't forget to clear it
        self.lightRenderCanvas = self.occludersCanvas
    end
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

--- PRIVATE HELPER METHODS STUFF ---

local leftTopLightingBoxPosition = function(self, x, y)
    return x - (self.radiance / 2), y - (self.radiance / 2)
end

--- DRAWING STUFF ---

--- Shader for calculating the 1D shadow map.
local shadowMapShader = love.graphics.newShader("code/components/shaders/shadowMapShader.glsl")

--- Shader for rendering blurred lights and shadows.
local lightRenderShader = love.graphics.newShader("code/components/shaders/lightRenderShader.glsl")

--- Pass in a function that draws all shadow-casting objects to the screen.
function module.Light:update(x, y, drawOccludersFn)
    lightRenderShader:send("resolutionX", self.radiance);
    lightRenderShader:send("canvasSize", self.maxRadiance);
    shadowMapShader:send("resolutionY", self.radiance);
    shadowMapShader:send("canvasSize", self.maxRadiance);

    local previousCanvas = love.graphics.getCanvas()
    local previousShader = love.graphics.getShader()

    -- Upper-left corner of light-casting box.
    local left, top = leftTopLightingBoxPosition(self, x, y)
    local fullQuad = love.graphics.newQuad(0, 0, math.min(self.radiance + 20, self.maxRadiance), self.radiance, self.occludersCanvas:getDimensions())
    local shadowQuad = love.graphics.newQuad(0, 0, self.radiance, 1, self.shadowMapCanvas:getDimensions())

    -- Translating the occluders by the position of the light-casting
    -- box causes only occluders in the box to appear on the canvas.
    self.occludersCanvas:renderTo(love.graphics.clear)
    love.graphics.push()
    love.graphics.origin()
    love.graphics.translate(-left, -top)
    self.occludersCanvas:renderTo(drawOccludersFn)
    love.graphics.pop()

    -- We need to un-apply any scrolling coordinate translation, because
    -- we want to draw the light/shadow effect canvas (and helpers) literally at
    -- (0, 0) on the screen. This didn't apply to the occluders because occluders
    -- on screen should be affected by scrolling translation.
    love.graphics.push()
    love.graphics.origin()

    self.shadowMapCanvas:renderTo(love.graphics.clear)
    love.graphics.setShader(shadowMapShader)
    love.graphics.setCanvas(self.shadowMapCanvas)
    love.graphics.draw(self.occludersCanvas, fullQuad, 0, 0)
    love.graphics.setCanvas()
    love.graphics.setShader()

    self.lightRenderCanvas:renderTo(love.graphics.clear)
    love.graphics.setShader(lightRenderShader)
    love.graphics.setCanvas(self.lightRenderCanvas)
    love.graphics.draw(self.shadowMapCanvas, shadowQuad, 0, 0, 0, 1, self.maxRadiance)
    love.graphics.setCanvas()
    love.graphics.setShader()

    love.graphics.pop()

    love.graphics.setCanvas(previousCanvas)
    love.graphics.setShader(previousShader)
end

function module.Light:draw(x, y)
    local left, top = leftTopLightingBoxPosition(self, x, y)
    local lightBoxQuad = love.graphics.newQuad(0, 0, self.radiance, self.radiance, self.lightRenderCanvas:getDimensions())

    love.graphics.setBlendMode("screen")
    love.graphics.setColor(self.red, self.green, self.blue, 255)
    love.graphics.draw(self.lightRenderCanvas, lightBoxQuad, left, top + self.radiance, 0, 1, -1)
    love.graphics.setBlendMode("alpha")
end

return module
