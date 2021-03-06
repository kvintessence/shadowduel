local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")

local globals = require("code/globals")

local Position = require("code/components/position").Position
local FootprintSource = require("code/components/footprintSource").FootprintSource
local DecayingObject = require("code/components/decayingObject").DecayingObject
local Image = require("code/components/image").Image
local ZOrder = require("code/components/zOrder").ZOrder
local SoundWave = require("code/components/soundWave").SoundWave

local module = {}

module.SoundWaveSpawnerSystem = tinyECS.processingSystem(class('systems/SoundWaveSpawnerSystem'))

function module.SoundWaveSpawnerSystem:initialize()
    self.footprintImage = love.graphics.newImage("assets/footprint.png")
end

function module.SoundWaveSpawnerSystem:filter(entity)
    return entity[Position] and entity[FootprintSource]
end

function module.SoundWaveSpawnerSystem:onAdd(entity)
    local footprint = entity[FootprintSource]
    local x, y = entity[Position]:get()
    footprint.lastX, footprint.lastY = x, y
end

function module.SoundWaveSpawnerSystem:process(entity, delta)
    local footprint = entity[FootprintSource]

    local x, y = entity[Position]:get()
    local lastX, lastY = footprint.lastX, footprint.lastY

    local distance = math.sqrt(math.pow(lastX - x, 2) + math.pow(lastY - y, 2))
    footprint.currentDistance = footprint.currentDistance + distance

    if footprint.currentDistance >= footprint.requiredDistance then
        local angle = math.atan2((y - lastY), (x - lastX))

        local reverse
        if footprint.reverse then
            reverse = -1
        else
            reverse = 1
        end

        footprint.currentDistance = 0

        tinyECS.addEntity(self.world, {
            [Position] = Position:new({ x = x, y = y, rotation = angle }),
            [Image] = Image:new({ image = self.footprintImage, scaleX = 0.2, scaleY = 0.2 * reverse }),
            [DecayingObject] = DecayingObject:new({ lifetime = 15 }),
            [ZOrder] = ZOrder:new({ layer = globals.layers.footprints }),
        })
        footprint.reverse = not footprint.reverse
    end

    footprint.lastX, footprint.lastY = x, y
end

return module
