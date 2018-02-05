local tinyECS = require("lib/tiny-ecs")

local DrawWorldSystem = require("code/systems/drawWorld").DrawWorldSystem
local LightUpdaterSystem = require("code/systems/lightUpdater").LightUpdaterSystem
local OccludersSystem = require("code/systems/occluders").OccludersSystem

local Circle = require("code/components/circle").Circle
local Rectangle = require("code/components/rectangle").Rectangle
local Position = require("code/components/position").Position
local Occluder = require("code/components/occluder").Occluder
local Light = require("code/components/light").Light
local Image = require("code/components/image").Image

-------------------

function love.keypressed(key, scancode, isrepeat)
    if key == "q" then
        cam:setScale((9.0 / 8.0) * cam:getScale())
    end

    if key == "a" then
        cam:setScale((8.0 / 9.0) * cam:getScale())
    end
end

function love.wheelmoved(x, y)
    light2[Light]:setRadiance(light2[Light]:getRadiance() + 10 * y)
end

function love.load()
    world = tinyECS.world()

    local occluders = tinyECS.addSystem(world, OccludersSystem:new())
    tinyECS.addSystem(world, LightUpdaterSystem:new(occluders))
    tinyECS.addSystem(world, DrawWorldSystem:new({ left = 0, top = 0, width = 2000, height = 2000 }))

    tinyECS.addEntity(world, {
        [Position] = Position:new({ x = 300, y = 100 }),
        [Circle] = Circle:new({ radius = 25 }),
        [Occluder] = Occluder:new(),
    })

    tinyECS.addEntity(world, {
        [Position] = Position:new({ x = 200, y = 200 }),
        [Rectangle] = Rectangle:new({ width = 50, height = 75 }),
        [Occluder] = Occluder:new(),
    })

    tinyECS.addEntity(world, {
        [Position] = Position:new({ x = 300, y = 300 }),
        [Rectangle] = Rectangle:new({ width = 75, height = 35 }),
        [Occluder] = Occluder:new(),
    })

    tinyECS.addEntity(world, {
        [Light] = Light:new({ radiance = 500, maxRadiance = 950, red = 250, green = 100, blue = 50 }),
        [Position] = Position:new({ x = 250, y = 150 }),
    })

    tinyECS.addEntity(world, {
        [Light] = Light:new({ radiance = 600, maxRadiance = 950, red = 50, green = 255, blue = 150 }),
        [Position] = Position:new({ x = 450, y = 350 }),
    })

    light2 = tinyECS.addEntity(world, {
        [Light] = Light:new({ radiance = 850, maxRadiance = 950, red = 50, green = 100, blue = 250 }),
        [Position] = Position:new({ x = 450, y = 250 }),
        [Image] = Image:new({ filename = "assets/highwayman.png", scale = 0.2 }),
    })
end

function love.update(dt)
    light2[Position]:set(love.mouse.getX(), love.mouse.getY())

    local fps = "FPS:" .. love.timer.getFPS()
    local systemCount = ", systems: " .. tinyECS.getSystemCount(world)
    local entityCount = ", entities: " .. tinyECS.getEntityCount(world)
    love.window.setTitle(fps .. systemCount .. entityCount)
end

function love.draw()
    world:update(love.timer.getDelta())
end
