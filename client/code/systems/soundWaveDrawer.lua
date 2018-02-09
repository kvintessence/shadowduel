local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")

local globals = require("code/globals")

local DecayingObject = require("code/components/decayingObject").DecayingObject
local SoundWave = require("code/components/soundWave").SoundWave
local Position = require("code/components/position").Position

local module = {}

module.SoundWaveDrawerSystem = tinyECS.processingSystem(class('systems/soundWaveDrawer'))

function module.SoundWaveDrawerSystem:filter(entity)
    return entity[DecayingObject] and entity[SoundWave] and entity[Position]
end

function module.SoundWaveDrawerSystem:preProcess()
    self.previousLineWidth = love.graphics.getLineWidth()
    love.graphics.setLineWidth(3)
end

function module.SoundWaveDrawerSystem:process(entity, delta)
    local decay = entity[DecayingObject]
    local wave = entity[SoundWave]

    local percentageLeft = decay.lifetimeLeft / decay.lifetimeTotal
    local opacity = 100 * percentageLeft
    local radius = wave.startRadius + (wave.endRadius - wave.startRadius) * (1 - percentageLeft)

    local x, y = entity[Position]:get()

    globals.camera:draw(function(l, t, w, h)
        love.graphics.setColor(255, 255, 255, opacity)
        love.graphics.circle("line", x, y, radius)
        love.graphics.setColor(255, 255, 255)
    end)
end

function module.SoundWaveDrawerSystem:postProcess()
    love.graphics.setLineWidth(self.previousLineWidth)
end

return module
