local class = require("lib/middleclass")

local module = {}

module.System = class('ecs/System')

function module.System:componentTypes()
    return {}
end

function module.System:update(entities, delta)
    -- do nothing
end

return module
