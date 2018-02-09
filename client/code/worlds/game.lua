local tinyECS = require("lib/tiny-ecs")
local gamera = require("lib/gamera")

local globals = require("code/globals")

local WorldDrawerSystem = require("code/systems/worldDrawer").WorldDrawerSystem
local FOVDrawerSystem = require("code/systems/fovDrawer").FOVDrawerSystem
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
local SoundWaveDrawerSystem = require("code/systems/soundWaveDrawer").SoundWaveDrawerSystem
local AutonomyPresentationSystem = require("code/systems/autonomyPresentation").AutonomyPresentationSystem

local NetworkInputReceiverSystem = require("code/systems/networkInputReceiver").NetworkInputReceiverSystem
local NetworkOutputSenderSystem = require("code/systems/networkOutputSender").NetworkOutputSenderSystem

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
local ZOrder = require("code/components/zOrder").ZOrder

local NetworkOutput = require("code/components/networkOutput").NetworkOutput
local NetworkInput = require("code/components/networkInput").NetworkInput

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

    --- CENTER WALLS ---

    -- top left H
    tinyECS.addEntity(globals.world, {
        [Position] = Position:new({ x = 800 - 200, y = 600 - 200 }),
        [Rectangle] = Rectangle:new({ width = 300, height = 50 }),
        [Occluder] = Occluder:new(),
        [PhysicalBody] = PhysicalBody:new({ type = "static" }),
    })

    -- top right H
    tinyECS.addEntity(globals.world, {
        [Position] = Position:new({ x = 800 + 200, y = 600 - 200 }),
        [Rectangle] = Rectangle:new({ width = 300, height = 50 }),
        [Occluder] = Occluder:new(),
        [PhysicalBody] = PhysicalBody:new({ type = "static" }),
    })

    -- top left V
    tinyECS.addEntity(globals.world, {
        [Position] = Position:new({ x = 800 - 325, y = 600 - 150 }),
        [Rectangle] = Rectangle:new({ width = 50, height = 150 }),
        [Occluder] = Occluder:new(),
        [PhysicalBody] = PhysicalBody:new({ type = "static" }),
    })

    -- top right V
    tinyECS.addEntity(globals.world, {
        [Position] = Position:new({ x = 800 + 325, y = 600 - 150 }),
        [Rectangle] = Rectangle:new({ width = 50, height = 150 }),
        [Occluder] = Occluder:new(),
        [PhysicalBody] = PhysicalBody:new({ type = "static" }),
    })

    -- bottom left V
    tinyECS.addEntity(globals.world, {
        [Position] = Position:new({ x = 800 - 325, y = 600 + 100 }),
        [Rectangle] = Rectangle:new({ width = 50, height = 150 }),
        [Occluder] = Occluder:new(),
        [PhysicalBody] = PhysicalBody:new({ type = "static" }),
    })

    -- bottom right V
    tinyECS.addEntity(globals.world, {
        [Position] = Position:new({ x = 800 + 325, y = 600 + 100 }),
        [Rectangle] = Rectangle:new({ width = 50, height = 150 }),
        [Occluder] = Occluder:new(),
        [PhysicalBody] = PhysicalBody:new({ type = "static" }),
    })

    -- bottom left H
    tinyECS.addEntity(globals.world, {
        [Position] = Position:new({ x = 800 - 200, y = 600 + 200 }),
        [Rectangle] = Rectangle:new({ width = 300, height = 50 }),
        [Occluder] = Occluder:new(),
        [PhysicalBody] = PhysicalBody:new({ type = "static" }),
    })

    -- bottom right H
    tinyECS.addEntity(globals.world, {
        [Position] = Position:new({ x = 800 + 200, y = 600 + 200 }),
        [Rectangle] = Rectangle:new({ width = 300, height = 50 }),
        [Occluder] = Occluder:new(),
        [PhysicalBody] = PhysicalBody:new({ type = "static" }),
    })

    --- OTHER ---

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
    local floorImage = love.graphics.newImage("assets/texture_sea.png")
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
    local localPlayer = tinyECS.addEntity(globals.world, {
        [Light] = Light:new({ radiance = 1200, maxRadiance = 1200, red = 50, green = 100, blue = 250 }),
        [LightFade] = LightFade:new({ linearSpeed = 300, percentageSpeed = 300, targetRadiance = 1200 }),
        [LightSwitch] = LightSwitch:new({ darkness = 0, brightness = 1200 }),

        [Position] = Position:new({ x = 800, y = 600 }),
        [Image] = Image:new({ filename = "assets/char_fish.png", scale = 0.5 }),

        [Circle] = Circle:new({ radius = 35 }),
        [PhysicalBody] = PhysicalBody:new({ type = "dynamic" }),
        [ControlledBody] = ControlledBody:new(),
        [Player] = Player:new({ localPlayer = true }),

        [FootprintSource] = FootprintSource:new({ requiredFootprintDistance = 80, requiredSoundDistance = 120 }),
        [ZOrder] = ZOrder:new({ layer = globals.layers.player }),

        [NetworkOutput] = NetworkOutput:new({ name = "anotherPlayer", sync = { Position, PhysicalBody, Player, Light } })
    })

    tinyECS.addEntity(globals.world, {
        [Light] = Light:new({ radiance = 1200, maxRadiance = 1200, red = 50, green = 100, blue = 250 }),

        [Position] = Position:new({ x = 800, y = 600 }),
        [Image] = Image:new({ filename = "assets/char_fish.png", scale = 0.5 }),

        [Circle] = Circle:new({ radius = 35 }),
        [PhysicalBody] = PhysicalBody:new({ type = "dynamic" }),
        [Player] = Player:new({ localPlayer = false }),

        [FootprintSource] = FootprintSource:new({ requiredFootprintDistance = 80, requiredSoundDistance = 120 }),
        [ZOrder] = ZOrder:new({ layer = globals.layers.player }),

        [NetworkInput] = NetworkInput:new({ name = "anotherPlayer", sync = { Position, PhysicalBody, Player, Light } })
    })

    tinyECS.addEntity(globals.world, {
        [Light] = Light:new({ radiance = 160, maxRadiance = 160 }),
        [Position] = Position:new({ x = 450, y = 250 }),
        [PhysicalBody] = localPlayer[PhysicalBody], -- hacky way to add default light
    })
end

local createWorld = function()
    globals.world = tinyECS.world()

    tinyECS.addSystem(globals.world, NetworkInputReceiverSystem:new())
    tinyECS.addSystem(globals.world, NetworkOutputSenderSystem:new())

    tinyECS.addSystem(globals.world, BodyControllerSystem:new())
    tinyECS.addSystem(globals.world, PhysicsSystem:new())
    tinyECS.addSystem(globals.world, PointCameraAtPlayerSystem:new())

    tinyECS.addSystem(globals.world, DecayingObjectHandlerSystem:new())
    tinyECS.addSystem(globals.world, FootprintHandler:new())

    tinyECS.addSystem(globals.world, LightSwitcherSystem:new())
    tinyECS.addSystem(globals.world, LightFaderSystem:new())

    local occluders = tinyECS.addSystem(globals.world, OccludersSystem:new())
    tinyECS.addSystem(globals.world, LightUpdaterSystem:new(occluders))
    tinyECS.addSystem(globals.world, WorldDrawerSystem:new())
    tinyECS.addSystem(globals.world, FOVDrawerSystem:new(occluders))

    tinyECS.addSystem(globals.world, SecondPlayerFinderSystem:new())

    tinyECS.addSystem(globals.world, SoundWaveDrawerSystem:new())
    tinyECS.addSystem(globals.world, AutonomyPresentationSystem:new())

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
