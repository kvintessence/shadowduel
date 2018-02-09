local class = require("lib/middleclass")
local json = require("lib/json")

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

function module.Position:serialize()
    return {
        x = self.x,
        y = self.y,
        rotation = self.rotation,
    }
end

function module.Position:deserialize(value)
    self.x = value.x or self.x
    self.y = value.y or self.y
    self.rotation = value.rotation or self.rotation
end

return module
