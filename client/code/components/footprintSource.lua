local class = require("lib/middleclass")

local module = {}

module.FootprintSource = class('components/footprintSource')

function module.FootprintSource:initialize(parameters)
    parameters = parameters or {}
    self.requiredDistance = parameters.requiredDistance or 50
    self.currentDistance = 0
    self.lastX = nil
    self.lastY = nil
end

return module
