local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")

local globals = require("code/globals")

local module = {}

module.AutonomyPresentationSystem = tinyECS.system(class('systems/autonomyPresentation'))

function module.AutonomyPresentationSystem:initialize()
    self.music = love.audio.newSource("assets/hall_soft.ogg")
    self.musicActive = false
    self.musicKeyPressed = false

    self.musicVolume = 0.5
    self.musicVolumeKeyPressed = false
    self.music:setVolume(self.musicVolume)
end

function module.AutonomyPresentationSystem:update(delta)
    self:updateMusicState()
    self:updateMusicVolume()
end

function module.AutonomyPresentationSystem:updateMusicState()
    local musicKeyPressed = love.keyboard.isScancodeDown('m')

    if musicKeyPressed and not self.musicKeyPressed then
        if self.musicActive then
            self.music:pause()
        else
            self.music:play()
        end
        self.musicActive = not self.musicActive
    end

    self.musicKeyPressed = musicKeyPressed
end

function module.AutonomyPresentationSystem:updateMusicVolume()
    if not self.musicVolumeKeyPressed and love.keyboard.isScancodeDown(']') then
        self.musicVolume = math.min(self.musicVolume + 0.1, 1.0)
        self.music:setVolume(self.musicVolume)
    elseif not self.musicVolumeKeyPressed and love.keyboard.isScancodeDown('[') then
        self.musicVolume = math.max(self.musicVolume - 0.1, 0.0)
        self.music:setVolume(self.musicVolume)
    end

    self.musicVolumeKeyPressed = love.keyboard.isScancodeDown(']') or love.keyboard.isScancodeDown('[')
end

return module
