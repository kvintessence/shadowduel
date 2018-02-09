local class = require("lib/middleclass")

local module = {}

module.NetworkOutput = class('components/networkOutput')

function module.NetworkOutput:initialize(parameters)
    parameters = parameters or {}
    self.name = parameters.name or nil
end

return module
