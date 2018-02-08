local class = require("lib/middleclass")

local module = {}

module.Player = class('components/player')

function module.Player:initialize(parameters)
    parameters = parameters or {}
    self.localPlayer = parameters.localPlayer or true
    self.running = false
end

return module
