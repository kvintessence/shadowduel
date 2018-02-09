local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")

local globals = require("code/globals")

local Circle = require("code/components/circle").Circle
local Rectangle = require("code/components/rectangle").Rectangle
local Position = require("code/components/position").Position
local Image = require("code/components/image").Image
local Light = require("code/components/light").Light
local ZOrder = require("code/components/zOrder").ZOrder
local Line = require("code/components/line").Line

local module = {}

--- shared functions ---

function module.drawEntity(entity, drawPrimitives)
    if entity[Image] then
        local image = entity[Image]
        local imageQuad = entity[Image].quad
        local position = entity[Position]

        local halfWidth = 0.5 * image:getWidth()
        local halfHeight = 0.5 * image:getHeight()

        local x = position.x
        local y = position.y

        if image.opacity then
            love.graphics.setColor(255, 255, 255, image.opacity)
        end

        if imageQuad then
            love.graphics.draw(image.image, imageQuad, x, y, position.rotation, image.scaleX, image.scaleY, halfWidth, halfHeight)
        else
            love.graphics.draw(image.image, x, y, position.rotation, image.scaleX, image.scaleY, halfWidth, halfHeight)
        end

        if image.opacity then
            love.graphics.setColor(255, 255, 255)
        end
    elseif drawPrimitives and entity[Circle] then
        local circle = entity[Circle]
        local position = entity[Position]
        love.graphics.circle("fill", position.x, position.y, circle.radius)
    elseif drawPrimitives and entity[Rectangle] then
        local rectangle = entity[Rectangle]
        local position = entity[Position]
        love.graphics.rectangle("fill", position.x - rectangle.width / 2, position.y - rectangle.height / 2, rectangle.width, rectangle.height)
    elseif drawPrimitives and entity[Line] then
        local line = entity[Line]
        love.graphics.line(line.x1, line.y1, line.x2, line.y2)
    end
end

--- --- --- --- --- ---

module.WorldDrawerSystem = tinyECS.sortedProcessingSystem(class('systems/worldDrawerSystem'))

function module.WorldDrawerSystem:initialize()
    self.canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    self.applyLightShader = love.graphics.newShader("code/components/shaders/applyLight.glsl")
end

function module.WorldDrawerSystem:filter(entity)
    return entity[Position] and (entity[Circle] or entity[Rectangle] or entity[Light] or entity[Image])
end

function module.WorldDrawerSystem:compare(entity1, entity2)
    local order1, order2 = entity1[ZOrder], entity2[ZOrder]
    return (not order1 and order2) or (order1 and order2 and order1.layer < order2.layer)
end

function module.WorldDrawerSystem:preProcess()
    love.graphics.setColor(255, 255, 255)

    local screenWidth, screenHeight = love.graphics.getDimensions()
    local canvasWidth, canvasHeight = self.canvas:getDimensions()

    if screenWidth ~= canvasWidth or screenHeight ~= canvasHeight then
        self.canvas = love.graphics.newCanvas(screenWidth, screenHeight)
    end

    self.lightsToDraw = {}
    globals.camera:setWindow(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

function module.WorldDrawerSystem:process(entity)
    if entity[Light] then
        table.insert(self.lightsToDraw, entity)
    end

    globals.camera:draw(function()
        module.drawEntity(entity)
    end)
end

function module.WorldDrawerSystem:postProcess()
    local previousCanvas = love.graphics.getCanvas()
    local previousShader = love.graphics.getShader()

    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(0, 0, 0, 0)

    globals.camera:draw(function(l, t, w, h)
        for _, entity in ipairs(self.lightsToDraw) do
            local position = entity[Position]
            entity[Light]:draw(position.x, position.y)
        end
    end)

    love.graphics.setCanvas(previousCanvas)
    love.graphics.setShader(self.applyLightShader)

    love.graphics.push()
    love.graphics.origin()

    love.graphics.setColor(12, 0, 40)
    love.graphics.draw(self.canvas, 0, 0)
    love.graphics.setBlendMode("alpha")

    love.graphics.pop()

    love.graphics.setShader(previousShader)
end

return module
