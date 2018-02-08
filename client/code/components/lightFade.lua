local class = require("lib/middleclass")

local module = {}

module.LightFade = class('components/lightFade')

function module.LightFade:initialize(parameters)
    parameters = parameters or {}
    self.linearSpeed = parameters.linearSpeed or 100
    self.percentageSpeed = parameters.percentageSpeed or 80
    self.targetRadiance = parameters.targetRadiance or 500
end

return module
