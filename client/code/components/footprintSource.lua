local class = require("lib/middleclass")

local module = {}

module.FootprintSource = class('components/footprintSource')

function module.FootprintSource:initialize(parameters)
    parameters = parameters or {}

    self.requiredFootprintDistance = parameters.requiredFootprintDistance or 50
    self.currentFootprintDistance = 0

    self.requiredSoundDistance = parameters.requiredSoundDistance or 100
    self.currentSoundDistance = 0

    self.lastX = nil
    self.lastY = nil
    self.reverse = false
end

return module
