local class = require("lib/middleclass")
local gamera = require("lib/gamera")
local tinyECS = require("lib/tiny-ecs")

local Circle = require("code/components/circle").Circle
local Rectangle = require("code/components/rectangle").Rectangle
local Position = require("code/components/position").Position
local Image = require("code/components/image").Image
local Light = require("code/components/light").Light

local module = {}

module.DrawWorldSystem = tinyECS.processingSystem(class('systems/drawWorld'))

function module.DrawWorldSystem:initialize(parameters)
    local left = parameters.left or 0
    local top = parameters.top or 0
    local width = parameters.width or love.graphics.getWidth()
    local height = parameters.height or love.graphics.getHeight()

    self.camera = gamera.new(left, top, width, height)
end

function module.DrawWorldSystem:filter(entity)
    return entity[Position] and (entity[Circle] or entity[Rectangle] or entity[Light] or entity[Image])
end

function module.DrawWorldSystem:preProcess()
    love.graphics.setColor(255, 255, 255, 255)

    self.lightsToDraw = {}
    self.camera:setWindow(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

function module.DrawWorldSystem:process(entity)
    if entity[Light] then
        table.insert(self.lightsToDraw, entity)
    end

    self.camera:draw(function(l, t, w, h)
        if entity[Image] then
            local image = entity[Image]
            local position = entity[Position]

            local x = position.x - 0.5 * image.image:getWidth() * image.scale
            local y = position.y - 0.5 * image.image:getHeight() * image.scale

            love.graphics.draw(image.image, x, y, position.rotation, image.scale)
        elseif entity[Circle] then
            local circle = entity[Circle]
            local position = entity[Position]
            love.graphics.circle("fill", position.x, position.y, circle.radius)
        elseif entity[Rectangle] then
            local rectangle = entity[Rectangle]
            local position = entity[Position]
            love.graphics.rectangle("fill", position.x - rectangle.width / 2, position.y - rectangle.height / 2, rectangle.width, rectangle.height)
        end
    end)
end

function module.DrawWorldSystem:postProcess()
    self.camera:draw(function(l, t, w, h)
        for _, entity in ipairs(self.lightsToDraw) do
            local position = entity[Position]
            entity[Light]:draw(position.x, position.y)
        end
    end)
end

return module
