local class = require("lib/middleclass")

local module = {}

module.Line = class('components/line')

function module.Line:initialize(parameters)
    self.x1 = parameters.x1 or 0
    self.y1 = parameters.y1 or 0
    self.x2 = parameters.x2 or 100
    self.y2 = parameters.y2 or 100
end

return module
