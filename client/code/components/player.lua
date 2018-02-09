local class = require("lib/middleclass")

local module = {}

module.Player = class('components/player')

function module.Player:initialize(parameters)
    parameters = parameters or {}
    self.localPlayer = parameters.localPlayer or false
    self.running = false
end

function module.Player:serialize()
    return {
        running = self.running,
    }
end

function module.Player:deserialize(value)
    self.running = value.running or self.running
end

return module
