local class = require("lib/middleclass")

local module = {}

module.PhysicalBody = class('components/physicalBody')

function module.PhysicalBody:initialize(parameters)
    parameters = parameters or {}
    self.type = parameters.type or "dynamic"
    self.damping = parameters.damping or 5.0
    self.collider = nil
end

return module
