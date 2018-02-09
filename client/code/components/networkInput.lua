local class = require("lib/middleclass")

local module = {}

module.NetworkInput = class('components/networkInput')

function module.NetworkInput:initialize(parameters)
    parameters = parameters or {}
    self.name = parameters.name or nil
    self.sync = parameters.sync or {}
end

function module.NetworkInput:componentByName(name)
    for _, component in ipairs(self.sync) do
        if component.name == name then
            return component
        end
    end
end

return module
