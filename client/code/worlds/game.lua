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

local spawnBox = function(x, y, w, h, r)
    tinyECS.addEntity(globals.world, {
        [Position] = Position:new({ x = x, y = y, rotation = r or 0 }),
        [Rectangle] = Rectangle:new({ width = w, height = h }),
        [Occluder] = Occluder:new(),
        [PhysicalBody] = PhysicalBody:new({ type = "static" }),
    })
end

local spawnCircle = function(x, y, r)
    tinyECS.addEntity(globals.world, {
        [Position] = Position:new({ x = x, y = y }),
        [Circle] = Circle:new({ radius = r }),
        [Occluder] = Occluder:new(),
        [PhysicalBody] = PhysicalBody:new({ type = "static" }),
    })
end

local spawnWorldObstacles = function()

    --- CENTER WALLS ---

    spawnBox(800 - 200, 600 - 200, 300 ,50) -- top left H
    spawnBox(800 + 200, 600 - 200, 300 ,50) -- top right H

    spawnBox(800 - 325, 600 - 150, 50, 150) -- top left V
    spawnBox(800 + 325, 600 - 150, 50, 150) -- top right V

    spawnBox(800 - 325, 600 + 100, 50, 150) -- bottom left V
    spawnBox(800 + 325, 600 + 100, 50, 150) -- bottom right V

    spawnBox(800 - 200, 600 + 200, 300, 50) -- bottom left H
    spawnBox(800 + 200, 600 + 200, 300, 50) -- bottom right H

    --- TOP LEFT OBJECTS ---

    spawnCircle(300, 200, 100)
    spawnBox(750, 150, 200, 60, 0.3)
    spawnBox(200, 500, 200, 60, 0.7)

    --- BOTTOM LEFT OBJECTS ---

    spawnCircle(375, 900, 60)
    spawnCircle(600, 1200, 120)
    spawnBox(170, 900, 200, 60, 1.3)

    --- BOTTOM RIGHT OBJECTS ---

    spawnBox(900, 1050, 80, 80, 1.3)
    spawnBox(1100, 1000, 80, 80, 0.3)
    spawnBox(1300, 1050, 80, 80, 0.7)
    spawnBox(1420, 900, 80, 80, 2.7)
    spawnBox(1300, 700, 80, 80, 2.1)
    spawnBox(1570, 750, 80, 80, 2.1)

    --- TOP RIGHT OBJECTS ---

    spawnBox(1450, 150, 60, 60, 0)
    spawnBox(1300, 150, 60, 60, 0)
    spawnBox(1300, 300, 60, 60, 0)
    spawnBox(1450, 300, 60, 60, 0)

end

local coralImage = love.graphics.newImage("assets/obj_lantern.png")

local spawnCoral = function(x, y, radiance, rotation)
    tinyECS.addEntity(globals.world, {
        [Image] = Image:new({ image = coralImage, scale = 0.7 }),
        [Light] = Light:new({ radiance = radiance, maxRadiance = radiance }),
        [Position] = Position:new({ x = x, y = y, rotation = rotation or 0 }),
        [ZOrder] = ZOrder:new({ layer = globals.layers.surroundings }),
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

    spawnCoral(700, 300, 700, 0.8)
    spawnCoral(320, 750, 800, 0.2)
    spawnCoral(1140, 890, 400, 1.3)
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
        [ZOrder] = ZOrder:new({ layer = globals.layers.localPlayer }),

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
        [ZOrder] = ZOrder:new({ layer = globals.layers.otherPlayer }),

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

    spawnPlayers()
end

return {
    create = createWorld,
}
