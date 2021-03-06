local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")

local globals = require("code/globals")

local Position = require("code/components/position").Position
local FootprintSource = require("code/components/footprintSource").FootprintSource
local DecayingObject = require("code/components/decayingObject").DecayingObject
local Image = require("code/components/image").Image
local ZOrder = require("code/components/zOrder").ZOrder
local SoundWave = require("code/components/soundWave").SoundWave
local Player = require("code/components/player").Player

local module = {}

module.FootprintHandler = tinyECS.processingSystem(class('systems/footprintHandler'))

function module.FootprintHandler:initialize()
    self.footprintImage = love.graphics.newImage("assets/footprint.png")
end

function module.FootprintHandler:filter(entity)
    return entity[Position] and entity[FootprintSource]
end

function module.FootprintHandler:onAdd(entity)
    local footprint = entity[FootprintSource]
    local x, y = entity[Position]:get()
    footprint.lastX, footprint.lastY = x, y
end

function module.FootprintHandler:process(entity, delta)
    local footprint = entity[FootprintSource]

    local x, y = entity[Position]:get()
    local lastX, lastY = footprint.lastX, footprint.lastY

    local distance = math.sqrt(math.pow(lastX - x, 2) + math.pow(lastY - y, 2))
    footprint.currentFootprintDistance = footprint.currentFootprintDistance + distance
    footprint.currentSoundDistance = footprint.currentSoundDistance + distance

    if footprint.currentFootprintDistance >= footprint.requiredFootprintDistance then
        local angle = math.atan2((y - lastY), (x - lastX))

        local reverse
        if footprint.reverse then
            reverse = -1
        else
            reverse = 1
        end

        footprint.currentFootprintDistance = 0

        tinyECS.addEntity(self.world, {
            [Position] = Position:new({ x = x, y = y, rotation = angle }),
            [Image] = Image:new({ image = self.footprintImage, scaleX = 0.2, scaleY = 0.2 * reverse }),
            [DecayingObject] = DecayingObject:new({ lifetime = 15 }),
            [ZOrder] = ZOrder:new({ layer = globals.layers.footprints }),
        })
        footprint.reverse = not footprint.reverse
    end

    if entity[Player].running and footprint.currentSoundDistance >= footprint.requiredSoundDistance then
        footprint.currentSoundDistance = 0

        tinyECS.addEntity(self.world, {
            [Position] = Position:new({ x = x, y = y, rotation = angle }),
            [DecayingObject] = DecayingObject:new({ lifetime = 0.5 }),
            [ZOrder] = ZOrder:new({ layer = globals.layers.soundWave }),
            [SoundWave] = SoundWave:new({ startRadius = 0.01, endRadius = 250 }),
        })
        footprint.reverse = not footprint.reverse
    end

    footprint.lastX, footprint.lastY = x, y
end

return module
