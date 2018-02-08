local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")

local DecayingObject = require("code/components/decayingObject").DecayingObject
local Image = require("code/components/image").Image

local module = {}

module.DecayingObjectHandlerSystem = tinyECS.processingSystem(class('systems/decayingObjectHandler'))

function module.DecayingObjectHandlerSystem:filter(entity)
    return entity[DecayingObject]
end

function module.DecayingObjectHandlerSystem:process(entity, delta)
    local decay = entity[DecayingObject]
    decay.lifetimeLeft = decay.lifetimeLeft - delta

    if decay.lifetimeLeft <= 0 then
        tinyECS.removeEntity(self.world, entity)
        return
    end

    if entity[Image] then
        entity[Image].opacity = 255 * (decay.lifetimeLeft / decay.lifetimeTotal)
    end
end

return module
