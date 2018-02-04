local class = require("lib/middleclass")

local module = {}

module.Position = class('components/position')

function module.Position:initialize(parameters)
    self.x = parameters.x or 0
    self.y = parameters.y or 0
    self.rotation = parameters.rotation or 0
end

function module.Position:set(x, y)
    self.x = x
    self.y = y
end

function module.Position:get()
    return self.x, self.y
end

return module
