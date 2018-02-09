local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")
local windfield = require("lib/windfield")

local globals = require("code/globals")

local PhysicalBody = require("code/components/physicalBody").PhysicalBody
local Circle = require("code/components/circle").Circle
local Rectangle = require("code/components/rectangle").Rectangle
local Line = require("code/components/line").Line
local Position = require("code/components/position").Position

local module = {}

module.PhysicsSystem = tinyECS.processingSystem(class('systems/physics'))

function module.PhysicsSystem:initialize()
    self.physicsWorld = windfield.newWorld(0, 0)
end

function module.PhysicsSystem:filter(entity)
    return entity[PhysicalBody] and entity[Position]
end

function module.PhysicsSystem:onAdd(entity)
    local bodyComponent = entity[PhysicalBody]
    local position = entity[Position]

    if entity[Rectangle] then
        local rectangle = entity[Rectangle]
        bodyComponent.collider = self.physicsWorld:newRectangleCollider(position.x - rectangle.width / 2, position.y - rectangle.height / 2, rectangle.width, rectangle.height)
    elseif entity[Circle] then
        local circle = entity[Circle]
        bodyComponent.collider = self.physicsWorld:newCircleCollider(position.x, position.y, circle.radius)
    elseif entity[Line] then
        local line = entity[Line]
        bodyComponent.collider = self.physicsWorld:newLineCollider(line.x1, line.y1, line.x2, line.y2)
    end

    bodyComponent.collider:setType(bodyComponent.type)
    bodyComponent.collider:setLinearDamping(bodyComponent.damping)
    bodyComponent.collider:setAngle(position.rotation)
end

function module.PhysicsSystem:onRemove(entity)
    local bodyComponent = entity[PhysicalBody]
    bodyComponent.collider:destroy()
    bodyComponent.collider = nil
end

function module.PhysicsSystem:preProcess(delta)
    self.physicsWorld:update(delta)
end

function module.PhysicsSystem:process(entity)
    local collider = entity[PhysicalBody].collider
    entity[Position]:set(collider:getX(), collider:getY())
end

function module.PhysicsSystem:postWrap()
    if globals.drawPhysics then
        globals.camera:draw(function() self.physicsWorld:draw() end)
    end
end

return module
