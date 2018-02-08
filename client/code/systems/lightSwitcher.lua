local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")

local Light = require("code/components/light").Light
local LightSwitch = require("code/components/lightSwitch").LightSwitch

local module = {}

module.LightSwitcherSystem = tinyECS.processingSystem(class('systems/lightSwitcherSystem'))

function module.LightSwitcherSystem:initialize(parameters)
    self.switchKeyPressed = false
end

function module.LightSwitcherSystem:filter(entity)
    return entity[Light] and entity[LightSwitch]
end

function module.LightSwitcherSystem:process(entity)
    local keyPressed = love.keyboard.isScancodeDown('space')
    local shouldSwitch = (keyPressed and not self.switchKeyPressed)

    if shouldSwitch then
        if entity[LightSwitch].on then
            -- turn off
            entity[LightSwitch].on = false
            entity[Light].radiance = entity[LightSwitch].darkness
        else
            -- turn on
            entity[LightSwitch].on = true
            entity[Light].radiance = entity[LightSwitch].brightness
        end
    end

    self.switchKeyPressed = keyPressed
end

return module
