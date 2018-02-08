local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")

local globals = require("code/globals")

local PhysicalBody = require("code/components/physicalBody").PhysicalBody
local Position = require("code/components/position").Position
local ControlledBody = require("code/components/controlledBody").ControlledBody
local Player = require("code/components/player").Player

local module = {}

module.BodyControllerSystem = tinyECS.processingSystem(class('systems/bodyControllerSystem'))

function module.BodyControllerSystem:initialize()
end

function module.BodyControllerSystem:filter(entity)
    return entity[PhysicalBody] and entity[Position] and entity[ControlledBody] and entity[Player]
end

function module.BodyControllerSystem:process(entity, delta)
    local force = 1600

    local vectorX, vectorY = 0, 0

    if love.keyboard.isScancodeDown('d') then
        vectorX = vectorX + 1
    end
    if love.keyboard.isScancodeDown('a') then
        vectorX = vectorX - 1
    end
    if love.keyboard.isScancodeDown('s') then
        vectorY = vectorY + 1
    end
    if love.keyboard.isScancodeDown('w') then
        vectorY = vectorY - 1
    end
    if love.keyboard.isScancodeDown('lshift') or love.keyboard.isScancodeDown('rshift') then
        force = force * 2.5
        entity[Player].running = true
    end

    local collider = entity[PhysicalBody].collider
    collider:setLinearDamping(5.0)
    collider:applyForce(force * vectorX, force * vectorY)

    -- rotation
    local playerX, playerY = collider:getX(), collider:getY()
    local mouseX, mouseY = globals.camera:toWorld(love.mouse.getX(), love.mouse.getY())

    local angle = math.atan2((mouseY - playerY), (mouseX - playerX))
    entity[Position].rotation = angle
end

return module
