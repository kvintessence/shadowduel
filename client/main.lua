local tinyECS = require("lib/tiny-ecs")
local gamera = require("lib/gamera")

local globals = require("code/globals")

local DrawWorldSystem = require("code/systems/drawWorld").DrawWorldSystem
local LightUpdaterSystem = require("code/systems/lightUpdater").LightUpdaterSystem
local OccludersSystem = require("code/systems/occluders").OccludersSystem
local PhysicsSystem = require("code/systems/physics").PhysicsSystem
local SecondPlayerFinderSystem = require("code/systems/secondPlayerFinder").SecondPlayerFinderSystem
local BodyControllerSystem = require("code/systems/bodyController").BodyControllerSystem

local Circle = require("code/components/circle").Circle
local Rectangle = require("code/components/rectangle").Rectangle
local Position = require("code/components/position").Position
local Occluder = require("code/components/occluder").Occluder
local Light = require("code/components/light").Light
local Image = require("code/components/image").Image
local PhysicalBody = require("code/components/physicalBody").PhysicalBody
local ControlledBody = require("code/components/controlledBody").ControlledBody

-------------------

io.stdout:setvbuf('no')

function love.load()
    globals.world = tinyECS.world()
    globals.camera = gamera.new(0, 0, 1600, 1200)

    tinyECS.addSystem(globals.world, BodyControllerSystem:new())
    tinyECS.addSystem(globals.world, PhysicsSystem:new())

    local occluders = tinyECS.addSystem(globals.world, OccludersSystem:new())
    tinyECS.addSystem(globals.world, LightUpdaterSystem:new(occluders))
    tinyECS.addSystem(globals.world, DrawWorldSystem:new({ left = 0, top = 0, width = 2000, height = 2000 }))

    --tinyECS.addSystem(globals.world, SecondPlayerFinderSystem:new())

    tinyECS.addEntity(globals.world, {
        [Position] = Position:new({ x = 300, y = 100 }),
        [Circle] = Circle:new({ radius = 25 }),
        [Occluder] = Occluder:new(),
        [PhysicalBody] = PhysicalBody:new({ type = "static" }),
    })

    tinyECS.addEntity(globals.world, {
        [Position] = Position:new({ x = 200, y = 200 }),
        [Rectangle] = Rectangle:new({ width = 50, height = 75 }),
        [Occluder] = Occluder:new(),
    })

    tinyECS.addEntity(globals.world, {
        [Position] = Position:new({ x = 300, y = 300 }),
        [Rectangle] = Rectangle:new({ width = 75, height = 35 }),
        [Occluder] = Occluder:new(),
    })

    tinyECS.addEntity(globals.world, {
        [Light] = Light:new({ radiance = 500, maxRadiance = 950, red = 250, green = 100, blue = 50 }),
        [Position] = Position:new({ x = 250, y = 150 }),
    })

    tinyECS.addEntity(globals.world, {
        [Light] = Light:new({ radiance = 600, maxRadiance = 950, red = 50, green = 255, blue = 150 }),
        [Position] = Position:new({ x = 450, y = 350 }),
    })

    local floorImage = love.graphics.newImage("assets/floor.png")
    local floorImageQuad = love.graphics.newQuad(0, 0, 800, 600, floorImage:getDimensions())
    floorImage:setWrap("repeat", "repeat")

    tinyECS.addEntity(globals.world, {
        [Position] = Position:new({ x = 400, y = 300 }),
        [Image] = Image:new({ image = floorImage, quad = floorImageQuad }),
    })

    tinyECS.addEntity(globals.world, {
        [Light] = Light:new({ radiance = 850, maxRadiance = 950, red = 50, green = 100, blue = 250 }),
        [Position] = Position:new({ x = 450, y = 250 }),
        [Image] = Image:new({ filename = "assets/highwayman.png", scale = 0.2 }),

        [Circle] = Circle:new({ radius = 25 }),
        [PhysicalBody] = PhysicalBody:new({ type = "dynamic" }),
        [ControlledBody] = ControlledBody:new(),
    })
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
