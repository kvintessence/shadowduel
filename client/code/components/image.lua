local class = require("lib/middleclass")

local module = {}

module.Image = class('components/image')

function module.Image:initialize(parameters)
    self.image = parameters.image or love.graphics.newImage(parameters.filename)
    self.scale = parameters.scale or 1
end

return module
