local class = require("lib/middleclass")

local module = {}

module.ZOrder = class('components/zOrder')

function module.ZOrder:initialize(parameters)
    parameters = parameters or {}
    self.layer = parameters.layer or 0
end

return module
