local class = require("lib/middleclass")

local module = {}

module.NetworkInput = class('components/networkInput')

function module.NetworkInput:initialize(parameters)
    parameters = parameters or {}
    self.name = parameters.name or nil
end

return module
