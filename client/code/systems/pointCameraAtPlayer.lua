local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")

local globals = require("code/globals")

local Position = require("code/components/position").Position
local Player = require("code/components/player").Player

local module = {}

module.PointCameraAtPlayerSystem = tinyECS.processingSystem(class('systems/pointCameraAtPlayer'))

function module.PointCameraAtPlayerSystem:initialize()
end

function module.PointCameraAtPlayerSystem:filter(entity)
    return entity[Position] and entity[Player] and entity[Player].localPlayer
end

function module.PointCameraAtPlayerSystem:process(entity)
    local x, y = entity[Position]:get()
    globals.camera:setPosition(x, y)
end

return module
