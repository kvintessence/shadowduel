local class = require("lib/middleclass")

local module = {}

module.SoundWave = class('components/soundWave')

function module.SoundWave:initialize(parameters)
    parameters = parameters or {}
    self.startRadius = parameters.startRadius or nil
    self.endRadius = parameters.endRadius or nil
end

return module
