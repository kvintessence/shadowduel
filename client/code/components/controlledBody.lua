local class = require("lib/middleclass")

local module = {}

module.ControlledBody = class('components/controlledBody')

function module.ControlledBody:initialize()
    self.running = false
end

return module
