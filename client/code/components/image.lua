local class = require("lib/middleclass")

local module = {}

module.Image = class('components/image')

function module.Image:initialize(parameters)
    self.image = parameters.image or love.graphics.newImage(parameters.filename)
    self.quad = parameters.quad or nil
    self.scaleX = parameters.scaleX or parameters.scale or 1
    self.scaleY = parameters.scaleY or parameters.scale or 1
    self.opacity = parameters.opacity or nil
end

function module.Image:getWidth()
    if self.quad then
        local x, y, w, h = self.quad:getViewport()
        return w
    end

    return self.image:getWidth()
end

function module.Image:getHeight()
    if self.quad then
        local x, y, w, h = self.quad:getViewport()
        return h
    end

    return self.image:getHeight()
end

function module.Image:getDimensions()
    if self.quad then
        local x, y, w, h = self.quad:getViewport()
        return w, h
    end

    return self.image:getDimensions()
end

return module
