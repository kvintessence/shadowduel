local tinyECS = require("lib/tiny-ecs")

local globals = require("code/globals")

local gameWorld = require("code/worlds/game")

io.stdout:setvbuf('no')

function love.load()
    gameWorld.create()
end

function love.update(dt)
    local fps = "FPS:" .. love.timer.getFPS()
    local systemCount = ", systems: " .. tinyECS.getSystemCount(globals.world)
    local entityCount = ", entities: " .. tinyECS.getEntityCount(globals.world)
    love.window.setTitle(fps .. systemCount .. entityCount)
end

function love.draw()
    globals.world:update(love.timer.getDelta())
end
