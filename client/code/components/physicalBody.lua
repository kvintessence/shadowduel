local class = require("lib/middleclass")

local module = {}

module.PhysicalBody = class('components/physicalBody')

function module.PhysicalBody:initialize(parameters)
    parameters = parameters or {}
    self.type = parameters.type or "dynamic"
    self.damping = parameters.damping or 5.0
    self.collider = nil
end

function module.PhysicalBody:serialize()
    local linearVelocityX, linearVelocityY = self.collider:getLinearVelocity()
    return {
        x = self.collider:getX(),
        y = self.collider:getY(),
        linearVelocityX = linearVelocityX,
        linearVelocityY = linearVelocityY,
    }
end

function module.PhysicalBody:deserialize(value)
    self.collider:setX(value.x or self.collider:getX())
    self.collider:setY(value.y or self.collider:getY())

    local linearVelocityX, linearVelocityY = self.collider:getLinearVelocity()
    self.collider:setLinearVelocity(value.linearVelocityX or linearVelocityX, value.linearVelocityY or linearVelocityY)
end

return module
