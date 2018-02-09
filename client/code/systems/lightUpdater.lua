local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")

local worldDrawer = require("code/systems/worldDrawer")

local Light = require("code/components/light").Light
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
            worldDrawer.drawEntity(occluder, true)
        end
    end)
end

return module
