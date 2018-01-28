local component = require("code/ecs/component")
local entity = require("code/ecs/entity")

local module = {}

module.Entity = entity.Entity
module.Component = component.Component

return module
