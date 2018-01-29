local component = require("code/ecs/component")
local entity = require("code/ecs/entity")
local system = require("code/ecs/system")
local engine = require("code/ecs/engine")

local module = {}

module.Entity = entity.Entity
module.Component = component.Component
module.System = system.System
module.Engine = engine.Engine

module.default = engine.Engine:new()

return module
