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

    self.loveLogo = love.graphics.newImage("assets/love_logo.png")
    self.loveLogoActive = false
    self.loveLogoKeyPressed = false

    self.fovKeyPressed = false
end

function module.AutonomyPresentationSystem:update(delta)
    self:updateMusicState()
    self:updateMusicVolume()
    self:updateLoveLogo()
    self:updateFOV()
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

function module.AutonomyPresentationSystem:updateLoveLogo()
    local loveLogoKeyPressed = love.keyboard.isScancodeDown('l')

    if loveLogoKeyPressed and not self.loveLogoKeyPressed then
        self.loveLogoActive = not self.loveLogoActive
    end

    self.loveLogoKeyPressed = loveLogoKeyPressed

    if self.loveLogoActive then
        love.graphics.clear(255, 255, 255)
        love.graphics.setColor(255, 255, 255)

        local x, y = love.graphics.getWidth(), love.graphics.getHeight()
        local w, h = self.loveLogo:getDimensions()
        love.graphics.draw(self.loveLogo, x / 2 - w / 3, y / 2 - h / 2)
    end
end

function module.AutonomyPresentationSystem:updateFOV()
    local fovKeyPressed = love.keyboard.isScancodeDown('v')

    if fovKeyPressed and not self.fovKeyPressed then
        self.fovKeyPressed = not self.fovKeyPressed
        globals.drawFOV = not globals.drawFOV
    end

    self.fovKeyPressed = fovKeyPressed
end

return module
