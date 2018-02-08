local tinyECS = require("lib/tiny-ecs")
local gamera = require("lib/gamera")

local globals = require("code/globals")

local DrawWorldSystem = require("code/systems/drawWorld").DrawWorldSystem
local LightUpdaterSystem = require("code/systems/lightUpdater").LightUpdaterSystem
local LightSwitcherSystem = require("code/systems/lightSwitcher").LightSwitcherSystem
local LightFaderSystem = require("code/systems/lightFader").LightFaderSystem
local OccludersSystem = require("code/systems/occluders").OccludersSystem
local PhysicsSystem = require("code/systems/physics").PhysicsSystem
local SecondPlayerFinderSystem = require("code/systems/secondPlayerFinder").SecondPlayerFinderSystem
local BodyControllerSystem = require("code/systems/bodyController").BodyControllerSystem
local PointCameraAtPlayerSystem = require("code/systems/pointCameraAtPlayer").PointCameraAtPlayerSystem
local FootprintHandler = require("code/systems/footprintHandler").FootprintHandler
local DecayingObjectHandlerSystem = require("code/systems/decayingObjectHandler").DecayingObjectHandlerSystem

local Line = require("code/components/line").Line
local Circle = require("code/components/circle").Circle
local Rectangle = require("code/components/rectangle").Rectangle
local Position = require("code/components/position").Position
local Occluder = require("code/components/occluder").Occluder
local Light = require("code/components/light").Light
local LightSwitch = require("code/components/lightSwitch").LightSwitch
local LightFade = require("code/components/lightFade").LightFade
local Image = require("code/components/image").Image
local PhysicalBody = require("code/components/physicalBody").PhysicalBody
local ControlledBody = require("code/components/controlledBody").ControlledBody
local Player = require("code/components/player").Player
local FootprintSource = require("code/components/footprintSource").FootprintSource

-------------------

local worldWidth, worldHeight = 1600, 1200
local worldGap = 250

local setupCamera = function()
    globals.camera = gamera.new(-worldGap, -worldGap, worldWidth + 2 * worldGap, worldHeight + 2 * worldGap)
end

local spawnWorldWalls = function()
    tinyECS.addEntity(globals.world, {
        [Position] = Position:new({ x = 0, y = 0 }),
        [Line] = Line:new({ x1 = 0, y1 = 0, x2 = worldWidth, y2 = 0 }),
        [Occluder] = Occluder:new(),
        [PhysicalBody] = PhysicalBody:new({ type = "static" }),
    })

    tinyECS.addEntity(globals.world, {
        [Position] = Position:new({ x = 0, y = 0 }),
        [Line] = Line:new({ x1 = 0, y1 = 0, x2 = 0, y2 = worldHeight }),
        [Occluder] = Occluder:new(),
        [PhysicalBody] = PhysicalBody:new({ type = "static" }),
    })

    tinyECS.addEntity(globals.world, {
        [Position] = Position:new({ x = 0, y = 0 }),
        [Line] = Line:new({ x1 = worldWidth, y1 = 0, x2 = worldWidth, y2 = worldHeight }),
        [Occluder] = Occluder:new(),
        [PhysicalBody] = PhysicalBody:new({ type = "static" }),
    })

    tinyECS.addEntity(globals.world, {
        [Position] = Position:new({ x = 0, y = 0 }),
        [Line] = Line:new({ x1 = 0, y1 = worldHeight, x2 = worldWidth, y2 = worldHeight }),
        [Occluder] = Occluder:new(),
        [PhysicalBody] = PhysicalBody:new({ type = "static" }),
    })
end

local spawnWorldObstacles = function()
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
        [PhysicalBody] = PhysicalBody:new({ type = "static" }),
    })

    tinyECS.addEntity(globals.world, {
        [Position] = Position:new({ x = 300, y = 300 }),
        [Rectangle] = Rectangle:new({ width = 75, height = 35 }),
        [Occluder] = Occluder:new(),
        [PhysicalBody] = PhysicalBody:new({ type = "static" }),
    })
end

local spawnWorldVisuals = function()
    --local floorImage = love.graphics.newImage("assets/floor.png")
    local floorImage = love.graphics.newImage("assets/sand.jpg")
    local floorImageQuad = love.graphics.newQuad(0, 0, worldWidth, worldHeight, floorImage:getDimensions())
    floorImage:setWrap("repeat", "repeat")

    tinyECS.addEntity(globals.world, {
        [Position] = Position:new({ x = worldWidth / 2, y = worldHeight / 2 }),
        [Image] = Image:new({ image = floorImage, quad = floorImageQuad }),
    })
end

local spawnWorldLights = function()
    tinyECS.addEntity(globals.world, {
        [Light] = Light:new({ radiance = 500, maxRadiance = 950, red = 250, green = 100, blue = 50 }),
        [Position] = Position:new({ x = 250, y = 150 }),
    })

    tinyECS.addEntity(globals.world, {
        [Light] = Light:new({ radiance = 600, maxRadiance = 950, red = 50, green = 255, blue = 150 }),
        [Position] = Position:new({ x = 450, y = 350 }),
    })
end

local spawnPlayers = function()
    tinyECS.addEntity(globals.world, {
        [Light] = Light:new({ radiance = 850, maxRadiance = 950, red = 50, green = 100, blue = 250 }),
        [LightFade] = LightFade:new({ linearSpeed = 300, percentageSpeed = 300, targetRadiance = 850 }),
        [LightSwitch] = LightSwitch:new({ darkness = 120, brightness = 850 }),

        [Position] = Position:new({ x = 450, y = 250 }),
        [Image] = Image:new({ filename = "assets/player.png", scale = 0.3 }),

        [Circle] = Circle:new({ radius = 25 }),
        [PhysicalBody] = PhysicalBody:new({ type = "dynamic" }),
        [ControlledBody] = ControlledBody:new(),
        [Player] = Player:new({ localPlayer = true }),

        [FootprintSource] = FootprintSource:new({ requiredDistance = 80 }),
    })
end

local createWorld = function()
    globals.world = tinyECS.world()

    tinyECS.addSystem(globals.world, BodyControllerSystem:new())
    tinyECS.addSystem(globals.world, PhysicsSystem:new())
    tinyECS.addSystem(globals.world, PointCameraAtPlayerSystem:new())

    tinyECS.addSystem(globals.world, DecayingObjectHandlerSystem:new())
    tinyECS.addSystem(globals.world, FootprintHandler:new())

    tinyECS.addSystem(globals.world, LightSwitcherSystem:new())
    tinyECS.addSystem(globals.world, LightFaderSystem:new())

    local occluders = tinyECS.addSystem(globals.world, OccludersSystem:new())
    tinyECS.addSystem(globals.world, LightUpdaterSystem:new(occluders))
    tinyECS.addSystem(globals.world, DrawWorldSystem:new({ left = 0, top = 0, width = 2000, height = 2000 }))

    --tinyECS.addSystem(globals.world, SecondPlayerFinderSystem:new())

    setupCamera()

    spawnWorldWalls()
    spawnWorldObstacles()
    spawnWorldVisuals()
    spawnWorldLights()

    spawnPlayers()
end

return {
    create = createWorld,
}
