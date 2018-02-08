local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")

local globals = require("code/globals")

local Position = require("code/components/position").Position
local ControlledBody = require("code/components/controlledBody").ControlledBody

local module = {}

module.PointCameraAtPlayerSystem = tinyECS.processingSystem(class('systems/pointCameraAtPlayer'))

function module.PointCameraAtPlayerSystem:initialize()
end

function module.PointCameraAtPlayerSystem:filter(entity)
    -- TODO: maybe `player` instead of controlled body?
    return entity[Position] and entity[ControlledBody]
end

function module.PointCameraAtPlayerSystem:process(entity)
    local x, y = entity[Position]:get()
    globals.camera:setPosition(x, y)
end

return module
