local class = require("lib/middleclass")

local module = {}

module.Circle = class('components/circle')

function module.Circle:initialize(parameters)
    self.radius = parameters.radius or 50

    self.style = parameters.style or "fill"
    self.lineWidth = parameters.lineWidth or 1
end

return module
