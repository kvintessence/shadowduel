local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")

local Occluder = require("code/components/occluder").Occluder

local module = {}

module.OccludersSystem = tinyECS.system(class('systems/occluders'))

function module.OccludersSystem:filter(entity)
    return entity[Occluder]
end

return module
