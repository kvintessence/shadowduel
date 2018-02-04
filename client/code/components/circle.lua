local class = require("lib/middleclass")

local module = {}

module.Circle = class('components/circle')

function module.Circle:initialize(parameters)
    self.radius = parameters.radius or 50
end

return module
