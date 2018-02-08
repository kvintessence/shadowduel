local class = require("lib/middleclass")

local module = {}

module.DecayingObject = class('components/decayingObject')

function module.DecayingObject:initialize(parameters)
    parameters = parameters or {}
    self.lifetimeTotal = parameters.lifetime or 5
    self.lifetimeLeft = self.lifetimeTotal
end

return module
