local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")

local Occluder = require("code/components/occluder").Occluder
local Circle = require("code/components/circle").Circle
local Rectangle = require("code/components/rectangle").Rectangle
local Position = require("code/components/position").Position

local module = {}

module.OccludersSystem = tinyECS.system(class('systems/occluders'))

function module.OccludersSystem:filter(entity)
    return entity[Occluder] and entity[Position] and (entity[Circle] or entity[Rectangle])
end

return module
