local class = require("lib/middleclass")

local module = {}

module.PhysicalBody = class('components/physicalBody')

function module.PhysicalBody:initialize(parameters)
    parameters = parameters or {}
    self.type = parameters.type or "dynamic"
    self.collider = nil
end

return module
