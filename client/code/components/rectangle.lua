local class = require("lib/middleclass")

local module = {}

module.Rectangle = class('components/rectangle')

function module.Rectangle:initialize(parameters)
    self.width = parameters.width or 100
    self.height = parameters.height or 100
end

return module
