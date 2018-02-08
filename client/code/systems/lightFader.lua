local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")

local Light = require("code/components/light").Light
local LightFade = require("code/components/lightFade").LightFade

local module = {}

module.LightFaderSystem = tinyECS.processingSystem(class('systems/lightFaderSystem'))

function module.LightFaderSystem:initialize(parameters)
end

function module.LightFaderSystem:filter(entity)
    return entity[Light] and entity[LightFade]
end

function module.LightFaderSystem:process(entity, delta)
    local light = entity[Light]
    local lightFade = entity[LightFade]

    local diff = math.abs(light.radiance - lightFade.targetRadiance)

    if diff < 1 then
        return
    end

    local linearDiff = lightFade.linearSpeed * delta
    local percentageDiff = diff * (lightFade.percentageSpeed / 100) * delta

    if light.radiance > lightFade.targetRadiance then
        light.radiance = math.min(light.radiance, light.radiance - percentageDiff - linearDiff)
    else
        light.radiance = math.max(light.radiance, light.radiance + percentageDiff + linearDiff)
    end
end

return module
