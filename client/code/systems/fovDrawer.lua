local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")

local globals = require("code/globals")

local worldDrawer = require("code/systems/worldDrawer")

local Position = require("code/components/position").Position
local Light = require("code/components/light").Light
local Player = require("code/components/player").Player

local module = {}

module.FOVDrawerSystem = tinyECS.processingSystem(class('systems/fovDrawerSystem'))

function module.FOVDrawerSystem:initialize(occludersSystem)
    self.canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    self.occludersSystem = occludersSystem
    self.applyLightShader = love.graphics.newShader("code/components/shaders/applyLight.glsl")
end

function module.FOVDrawerSystem:filter(entity)
    return entity[Position] and entity[Light] and entity[Player] and entity[Player].localPlayer
end

function module.FOVDrawerSystem:preProcess()
    love.graphics.setColor(255, 255, 255)

    local screenWidth, screenHeight = love.graphics.getDimensions()
    local canvasWidth, canvasHeight = self.canvas:getDimensions()

    if screenWidth ~= canvasWidth or screenHeight ~= canvasHeight then
        self.canvas = love.graphics.newCanvas(screenWidth, screenHeight)
    end

    self.previousCanvas = love.graphics.getCanvas()
    self.previousShader = love.graphics.getShader()

    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(0, 0, 0, 0)
end

function module.FOVDrawerSystem:onAddToWorld(world)
    self.fovLight = {
        [Light] = Light:new({ radiance = 2000, maxRadiance = 2000, red = 50, green = 100, blue = 250 }),
        [Position] = Position:new({ x = 450, y = 250 }),
    }
end

function module.FOVDrawerSystem:onRemoveFromWorld(world)
    self.fovLight = nil
end

function module.FOVDrawerSystem:process(entity)
    local lightPosition = entity[Position]
    self.fovLight[Position]:set(lightPosition.x, lightPosition.y)

    self.fovLight[Light]:update(lightPosition.x, lightPosition.y, function()
        for _, occluder in ipairs(self.occludersSystem.entities) do
            worldDrawer.drawEntity(occluder, true)
        end
    end)

    globals.camera:draw(function()
        self.fovLight[Light]:draw(lightPosition.x, lightPosition.y)
    end)
end

function module.FOVDrawerSystem:postProcess()
    love.graphics.setCanvas(self.previousCanvas)
    love.graphics.setShader(self.applyLightShader)

    love.graphics.push()
    love.graphics.origin()

    love.graphics.setColor(0, 0, 0)
    love.graphics.draw(self.canvas, 0, 0)
    love.graphics.setBlendMode("alpha")

    love.graphics.pop()

    love.graphics.setShader(self.previousShader)
end

return module
