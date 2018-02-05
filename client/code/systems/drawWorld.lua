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

    self.canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    self.applyLightShader = love.graphics.newShader("code/components/shaders/applyLight.glsl")
end

function module.DrawWorldSystem:filter(entity)
    return entity[Position] and (entity[Circle] or entity[Rectangle] or entity[Light] or entity[Image])
end

function module.DrawWorldSystem:preProcess()
    love.graphics.setColor(255, 255, 255, 255)

    local screenWidth, screenHeight = love.graphics.getDimensions()
    local canvasWidth, canvasHeight = self.canvas:getDimensions()

    if screenWidth ~= canvasWidth or screenHeight ~= canvasHeight then
        self.canvas = love.graphics.newCanvas(screenWidth, screenHeight)
    end

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
            local imageQuad = entity[Image].quad
            local position = entity[Position]

            -- TODO: FIX QUAD POSITION!
            local x = position.x - 0.5 * image.image:getWidth() * image.scale
            local y = position.y - 0.5 * image.image:getHeight() * image.scale

            if imageQuad then
                love.graphics.draw(image.image, imageQuad, x, y, position.rotation, image.scale)
            else
                love.graphics.draw(image.image, x, y, position.rotation, image.scale)
            end
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
    local previousCanvas = love.graphics.getCanvas()
    local previousShader = love.graphics.getShader()

    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(0, 0, 0, 0)  -- ????????

    self.camera:draw(function(l, t, w, h)
        for _, entity in ipairs(self.lightsToDraw) do
            local position = entity[Position]
            entity[Light]:draw(position.x, position.y)
        end
    end)

    love.graphics.setCanvas(previousCanvas)
    love.graphics.setShader(self.applyLightShader)

    love.graphics.push()
    love.graphics.origin()

    --love.graphics.setBlendMode("screen")
    love.graphics.setColor(0, 0, 0)
    love.graphics.draw(self.canvas, 0, 0)
    love.graphics.setBlendMode("alpha")

    love.graphics.pop()

    love.graphics.setShader(previousShader)
end

return module
