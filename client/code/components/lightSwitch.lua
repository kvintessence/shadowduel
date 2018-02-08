local class = require("lib/middleclass")

local module = {}

module.LightSwitch = class('components/lightSwitch')

function module.LightSwitch:initialize(parameters)
    parameters = parameters or {}
    self.darkness = parameters.darkness or 0
    self.brightness = parameters.brightness or 0
    self.on = true
end

return module
