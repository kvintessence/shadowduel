local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")

local Light = require("code/components/light").Light
local Line = require("code/components/line").Line
local Circle = require("code/components/circle").Circle
local Rectangle = require("code/components/rectangle").Rectangle
local Position = require("code/components/position").Position

local module = {}

module.LightUpdaterSystem = tinyECS.processingSystem(class('systems/lightUpdater'))

function module.LightUpdaterSystem:initialize(occludersSystem)
    self.occludersSystem = occludersSystem
end

function module.LightUpdaterSystem:filter(entity)
    return entity[Light] and entity[Position]
end

function module.LightUpdaterSystem:process(entity)
    local lightPosition = entity[Position]

    entity[Light]:update(lightPosition.x, lightPosition.y, function()
        for _, occluder in ipairs(self.occludersSystem.entities) do
            if occluder[Circle] and entity[Position] then
                local circle = occluder[Circle]
                local position = occluder[Position]
                love.graphics.circle("fill", position.x, position.y, circle.radius)
            elseif occluder[Rectangle] and entity[Position] then
                local rectangle = occluder[Rectangle]
                local position = occluder[Position]
                love.graphics.rectangle("fill", position.x - rectangle.width / 2, position.y - rectangle.height / 2, rectangle.width, rectangle.height)
            elseif occluder[Line] then
                local line = occluder[Line]
                love.graphics.line(line.x1, line.y1, line.x2, line.y2)
            end
        end
    end)
end

return module
